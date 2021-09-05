# init for value initializers
# new for reference initializers

{.compile: "src/stb_truetype/wrapper.c".}

import stb_truetype/wrapper
import options

type 
  Font* = object
    ## Represents loaded TrueType font data.
    raw: stbtt_fontinfo

  SDF* = ref object
    ## Signed Distance Field data.
    ## 
    ## This is a wrapper around the SDF data returned from SDF functions that 
    ## automatically frees the SDF when it goes out of scope.
    raw: ptr cuchar 
    width*, height*, xoff*, yoff*: int

  VMetrics* = object
    ##  ascent is the coordinate above the baseline the font extends; descent
    ##  is the coordinate below the baseline the font extends (i.e. it is typically negative)
    ##  lineGap is the spacing between one row's descent and the next row's ascent...
    ##  so you should advance the vertical position by "ascent - descent + lineGap"
    ##    these are expressed in unscaled coordinates, so you must multiply by
    ##    the scale factor for a given size
    ascent*: int
    descent*: int
    lineGap*: int

  HMetrics* = object
    ##  leftSideBearing is the offset from the current horizontal position to the left edge of the character
    ##  advanceWidth is the offset from the current horizontal position to the next horizontal position
    ##    these are expressed in unscaled coordinates
    advanceWidth*: int
    leftSideBearing*: int

proc finalizer(sdf: SDF) =
  stbtt_FreeSDF(sdf.raw, nil)

proc initFont*(data: openArray[cuchar]): Option[Font] =
  ## Loads a font from bytes containing TTF font data.
  ## 
  ## - Returns `Some(Font)` if the font was loaded successfully.
  ## - Returns `None` if the font could not be loaded.
  var font: Font
  result = case stbtt_InitFont(font.raw.addr, data[0].unsafeAddr, 0):
    of 0: Font.none
    else: some(font)

proc getNumberOfFonts*(data: openArray[cuchar]): int =
  ##  This function will determine the number of fonts in a font file.  TrueType
  ##  collection (.ttc) files may contain multiple fonts, while TrueType font
  ##  (.ttf) files only contain one font. The number of fonts can be used for
  ##  indexing with the previous function where the index is between zero and one
  ##  less than the total fonts. If an error occurs, -1 is returned.
  stbtt_GetNumberOfFonts(data[0].unsafeAddr).int

proc getFontOffsetForIndex*(data: openArray[cuchar]; index: int): int =
  ##  Each .ttf/.ttc file may have more than one font. Each font has a sequential
  ##  index number starting from 0. Call this function to get the font offset for
  ##  a given index; it returns -1 if the index is out of range. A regular .ttf
  ##  file will only define one font and it always be at offset 0, so it will
  ##  return '0' for index 0, and -1 for all other indices.
  ##  The following structure is defined publicly so you can declare one on
  ##  the stack or as a global or etc, but you should treat it as opaque.
  stbtt_GetFontOffsetForIndex(data[0].unsafeAddr, index.cint).int

proc getFontVMetrics*(font: Font): VMetrics =
  ##  ascent is the coordinate above the baseline the font extends; descent
  ##  is the coordinate below the baseline the font extends (i.e. it is typically negative)
  ##  lineGap is the spacing between one row's descent and the next row's ascent...
  ##  so you should advance the vertical position by "ascent - descent + lineGap"
  ##    these are expressed in unscaled coordinates, so you must multiply by
  ##    the scale factor for a given size
  var ascent, descent, lineGap: cint
  stbtt_GetFontVMetrics(
    font.raw.unsafeAddr, 
    ascent.addr, 
    descent.addr, 
    lineGap.addr
  )
  VMetrics(
    ascent: ascent, 
    descent: descent, 
    lineGap: lineGap
  )

proc getGlyphKernAdvance*(font: Font, glyph1: int; glyph2: int): int =
  ## An additional amount to add to the 'advance' value between ch1 and ch2
  stbtt_GetGlyphKernAdvance(font.raw.unsafeAddr, glyph1.cint, glyph2.cint).int

proc getGlyphHMetrics*(font: Font, glyph: int): HMetrics =
  ##  leftSideBearing is the offset from the current horizontal position to the left edge of the character
  ##  advanceWidth is the offset from the current horizontal position to the next horizontal position
  ##    these are expressed in unscaled coordinates
  var advanceWidth, leftSideBearing: cint
  stbtt_GetGlyphHMetrics(
    font.raw.unsafeAddr,
    glyph.cint,
    advanceWidth.addr,
    leftSideBearing.addr
  )
  HMetrics(
    advanceWidth: advanceWidth.int,
    leftSideBearing: leftSideBearing.int
  )

proc isGlyphEmpty*(font: Font, glyph: int): bool =
  ## Returns false if nothing is drawn for this glyph.
  stbtt_IsGlyphEmpty(font.raw.unsafeAddr, glyph.cint).bool

proc getGlyphSDF*(
  font: Font, 
  scale: float, 
  glyph_index: int, 
  padding: int, 
  onedge_value: uint8, 
  pixel_dist_scale: float,
  ): Option[SDF] =
  var 
    raw: ptr cuchar
    width, height, xoff, yoff: cint

  raw = stbtt_GetGlyphSDF(
    font.raw.unsafeAddr,
    scale.cfloat,
    glyph_index.cint,
    padding.cint,
    onedge_value.cuchar,
    pixel_dist_scale.cfloat,
    width.addr,
    height.addr,
    xoff.addr,
    yoff.addr,
  )
  if raw == nil:
    none(SDF)
  else:
    var sdf: SDF
    new(sdf, finalizer)
    sdf = SDF(
      raw: raw,
      width: width.int,
      height: height.int,
      xoff: xoff.int,
      yoff: yoff.int
    )
    some(sdf)

proc getCodepointSDF*(
  font: Font, 
  scale: float, 
  codepoint: int, 
  padding: int, 
  onedge_value: uint8, 
  pixel_dist_scale: float,
  ): Option[SDF] =
  ## These functions compute a discretized SDF field for a single character, suitable for storing
  ## in a single-channel texture, sampling with bilinear filtering, and testing against
  ## larger than some threshold to produce scalable fonts.
  ##        info              --  the font
  ##        scale             --  controls the size of the resulting SDF bitmap, same as it would be creating a regular bitmap
  ##        glyph/codepoint   --  the character to generate the SDF for
  ##        padding           --  extra "pixels" around the character which are filled with the distance to the character (not 0),
  ##                                 which allows effects like bit outlines
  ##        onedge_value      --  value 0-255 to test the SDF against to reconstruct the character (i.e. the isocontour of the character)
  ##        pixel_dist_scale  --  what value the SDF should increase by when moving one SDF "pixel" away from the edge (on the 0..255 scale)
  ##                                 if positive, > onedge_value is inside; if negative, < onedge_value is inside
  ##        width,height      --  output height & width of the SDF bitmap (including padding)
  ##        xoff,yoff         --  output origin of the character
  ##        return value      --  a 2D array of bytes 0..255, width*height in size
  ##
  ## pixel_dist_scale & onedge_value are a scale & bias that allows you to make
  ## optimal use of the limited 0..255 for your application, trading off precision
  ## and special effects. SDF values outside the range 0..255 are clamped to 0..255.
  ##
  ## Example:
  ##      scale = stbtt_ScaleForPixelHeight(22)
  ##      padding = 5
  ##      onedge_value = 180
  ##      pixel_dist_scale = 180/5.0 = 36.0
  ##
  ##      This will create an SDF bitmap in which the character is about 22 pixels
  ##      high but the whole bitmap is about 22+5+5=32 pixels high. To produce a filled
  ##      shape, sample the SDF at each pixel and fill the pixel if the SDF value
  ##      is greater than or equal to 180/255. (You'll actually want to antialias,
  ##      which is beyond the scope of this example.) Additionally, you can compute
  ##      offset outlines (e.g. to stroke the character border inside & outside,
  ##      or only outside). For example, to fill outside the character up to 3 SDF
  ##      pixels, you would compare against (180-36.0*3)/255 = 72/255. The above
  ##      choice of variables maps a range from 5 pixels outside the shape to
  ##      2 pixels inside the shape to 0..255; this is intended primarily for apply
  ##      outside effects only (the interior range is needed to allow proper
  ##      antialiasing of the font at smaller sizes)
  ##
  ## The function computes the SDF analytically at each SDF pixel, not by e.g.
  ## building a higher-res bitmap and approximating it. In theory the quality
  ## should be as high as possible for an SDF of this size & representation, but
  ## unclear if this is true in practice (perhaps building a higher-res bitmap
  ## and computing from that can allow drop-out prevention).
  ##
  ## The algorithm has not been optimized at all, so expect it to be slow
  ## if computing lots of characters or very large sizes.
  var 
    raw: ptr cuchar
    width, height, xoff, yoff: cint

  raw = stbtt_GetCodepointSDF(
    font.raw.unsafeAddr,
    scale.cfloat,
    codepoint.cint,
    padding.cint,
    onedge_value.cuchar,
    pixel_dist_scale.cfloat,
    width.addr,
    height.addr,
    xoff.addr,
    yoff.addr,
  )
  if raw == nil:
    none(SDF)
  else:
    var sdf: SDF
    new(sdf, finalizer)
    sdf = SDF(
      raw: raw,
      width: width.int,
      height: height.int,
      xoff: xoff.int,
      yoff: yoff.int
    )
    some(sdf)

iterator pixels*(sdf: SDF): uint8 =
  ## Safe iterator over the pixel data in the SDF buffer.
  let raw = cast[ptr UncheckedArray[cuchar]](sdf.raw)
  for item in toOpenArray(raw, 0, sdf.width * sdf.height):
    yield cast[uint8](item)
  
proc scaleForPixelHeight*(font: Font, pixels: float): float =
  ##  computes a scale factor to produce a font whose "height" is 'pixels' tall.
  ##  Height is measured as the distance from the highest ascender to the lowest
  ##  descender; in other words, it's equivalent to calling stbtt_GetFontVMetrics
  ##  and computing:
  ##        scale = pixels / (ascent - descent)
  ##  so if you prefer to measure height by the ascent only, use a similar calculation.
  stbtt_ScaleForPixelHeight(font.raw.unsafeAddr, pixels.cfloat).float

proc findGlyphIndex*(font: Font, unicode_codepoint: int): int =
  ##  If you're going to perform multiple operations on the same character
  ##  and you want a speed-up, call this function with the character you're
  ##  going to process, then use glyph-based functions instead of the
  ##  codepoint-based functions.
  ##  Returns 0 if the character codepoint is not defined in the font.
  stbtt_FindGlyphIndex(font.raw.unsafeAddr, unicode_codepoint.cint).int
