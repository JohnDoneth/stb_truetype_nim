## /////////////////////////////////////////////////////////////////////////////
## /////////////////////////////////////////////////////////////////////////////
## //
## //   INTERFACE
## //
## //

type
  stbtt_buf* {.bycopy.} = object
    data*: ptr cuchar
    cursor*: cint
    size*: cint

type
  stbtt_pack_context* {.bycopy.} = object
    user_allocator_context*: pointer
    pack_info*: pointer
    width*: cint
    height*: cint
    stride_in_bytes*: cint
    padding*: cint
    skip_missing*: cint
    h_oversample*: cuint
    v_oversample*: cuint
    pixels*: ptr cuchar
    nodes*: pointer

type
  stbtt_bakedchar* {.bycopy.} = object
    x0*: cushort
    y0*: cushort
    x1*: cushort
    y1*: cushort               ##  coordinates of bbox in bitmap
    xoff*: cfloat
    yoff*: cfloat
    xadvance*: cfloat

type
  stbtt_aligned_quad* {.bycopy.} = object
    x0*: cfloat
    y0*: cfloat
    s0*: cfloat
    t0*: cfloat                ##  top-left
    x1*: cfloat
    y1*: cfloat
    s1*: cfloat
    t1*: cfloat                ##  bottom-right

type
  stbtt_packedchar* {.bycopy.} = object
    x0*: cushort
    y0*: cushort
    x1*: cushort
    y1*: cushort               ##  coordinates of bbox in bitmap
    xoff*: cfloat
    yoff*: cfloat
    xadvance*: cfloat
    xoff2*: cfloat
    yoff2*: cfloat

type
  stbtt_pack_range* {.bycopy.} = object
    font_size*: cfloat
    first_unicode_codepoint_in_range*: cint ##  if non-zero, then the chars are continuous, and this is the first codepoint
    array_of_unicode_codepoints*: ptr cint ##  if non-zero, then this is an array of unicode codepoints
    num_chars*: cint
    chardata_for_range*: ptr stbtt_packedchar ##  output
    h_oversample*: cuchar
    v_oversample*: cuchar      ##  don't set these, they're used internally

type
  stbtt_fontinfo* {.bycopy.} = object
    userdata*: pointer
    data*: ptr cuchar           ##  pointer to .ttf file
    fontstart*: cint           ##  offset of start of font
    numGlyphs*: cint           ##  number of glyphs, needed for range checking
    loca*: cint
    head*: cint
    glyf*: cint
    hhea*: cint
    hmtx*: cint
    kern*: cint
    gpos*: cint
    svg*: cint                 ##  table locations as offset from start of .ttf
    index_map*: cint           ##  a cmap mapping for our chosen character encoding
    indexToLocFormat*: cint    ##  format needed to map from glyph index to glyph
    cff*: stbtt_buf           ##  cff font data
    charstrings*: stbtt_buf   ##  the charstring index
    gsubrs*: stbtt_buf        ##  global charstring subroutines index
    subrs*: stbtt_buf         ##  private charstring subroutines index
    fontdicts*: stbtt_buf     ##  array of font dicts
    fdselect*: stbtt_buf      ##  map from glyph to fontdict

type
  stbtt_bitmap* {.bycopy.} = object
    w*: cint
    h*: cint
    stride*: cint
    pixels*: ptr cuchar

type
  stbtt_kerningentry* {.bycopy.} = object
    glyph1*: cint              ##  use stbtt_FindGlyphIndex
    glyph2*: cint
    advance*: cint

type
  stbrp_rect* {.bycopy.} = object


type stbtt_vertex* {.bycopy.} = object
    x*: cshort 
    y*: cshort 
    cx*: cshort 
    cy*: cshort
    cx1*: cshort
    cy1*: cshort
    padding*: cuchar


proc stbtt_BakeFontBitmap*(data: ptr cuchar; offset: cint; pixel_height: cfloat;
                          pixels: ptr cuchar; pw: cint; ph: cint; first_char: cint;
                          num_chars: cint; chardata: ptr stbtt_bakedchar): cint {.importc.}
  ##  font location (use offset=0 for plain .ttf)
  ##  height of font in pixels
  ##  bitmap to be filled in
  ##  characters to bake
##  you allocate this, it's num_chars long
##  if return is positive, the first unused row of the bitmap
##  if return is negative, returns the negative of the number of characters that fit
##  if return is 0, no characters fit and no rows were used
##  This uses a very crappy packing.


proc stbtt_GetBakedQuad*(chardata: ptr stbtt_bakedchar; pw: cint; ph: cint;
                        char_index: cint; xpos: ptr cfloat; ypos: ptr cfloat;
                        q: ptr stbtt_aligned_quad; opengl_fillrule: cint) {.importc.}
  ##  same data as above
  ##  character to display
  ##  pointers to current position in screen pixel space
  ##  output: quad to draw
##  true if opengl fill rule; false if DX9 or earlier
##  Call GetBakedQuad with char_index = 'character - first_char', and it
##  creates the quad you need to draw and advances the current position.
##
##  The coordinate system used assumes y increases downwards.
##
##  Characters will extend both above and below the current position;
##  see discussion of "BASELINE" above.
##
##  It's inefficient; you might want to c&p it and optimize it.

proc stbtt_GetScaledFontVMetrics*(fontdata: ptr cuchar; index: cint; size: cfloat;
                                 ascent: ptr cfloat; descent: ptr cfloat;
                                 lineGap: ptr cfloat) {.importc.}
##  Query the font vertical metrics without having to create a font first.
## ////////////////////////////////////////////////////////////////////////////
##
##  NEW TEXTURE BAKING API
##
##  This provides options for packing multiple fonts into one atlas, not
##  perfectly but better than nothing.




proc stbtt_PackBegin*(spc: ptr stbtt_pack_context; pixels: ptr cuchar; width: cint;
                     height: cint; stride_in_bytes: cint; padding: cint;
                     alloc_context: pointer): cint {.importc.}
##  Initializes a packing context stored in the passed-in stbtt_pack_context.
##  Future calls using this context will pack characters into the bitmap passed
##  in here: a 1-channel bitmap that is width * height. stride_in_bytes is
##  the distance from one row to the next (or 0 to mean they are packed tightly
##  together). "padding" is the amount of padding to leave between each
##  character (normally you want '1' for bitmaps you'll use as textures with
##  bilinear filtering).
##
##  Returns 0 on failure, 1 on success.

proc stbtt_PackEnd*(spc: ptr stbtt_pack_context) {.importc.}
##  Cleans up the packing context and frees all memory.

template STBTT_POINT_SIZE*(x: untyped): untyped =
  (-(x))

proc stbtt_PackFontRange*(spc: ptr stbtt_pack_context; fontdata: ptr cuchar;
                         font_index: cint; font_size: cfloat;
                         first_unicode_char_in_range: cint;
                         num_chars_in_range: cint;
                         chardata_for_range: ptr stbtt_packedchar): cint {.importc.}
##  Creates character bitmaps from the font_index'th font found in fontdata (use
##  font_index=0 if you don't know what that is). It creates num_chars_in_range
##  bitmaps for characters with unicode values starting at first_unicode_char_in_range
##  and increasing. Data for how to render them is stored in chardata_for_range;
##  pass these to stbtt_GetPackedQuad to get back renderable quads.
##
##  font_size is the full height of the character from ascender to descender,
##  as computed by stbtt_ScaleForPixelHeight. To use a point size as computed
##  by stbtt_ScaleForMappingEmToPixels, wrap the point size in STBTT_POINT_SIZE()
##  and pass that result as 'font_size':
##        ...,                  20 , ... // font max minus min y is 20 pixels tall
##        ..., STBTT_POINT_SIZE(20), ... // 'M' is 20 pixels tall




proc stbtt_PackFontRanges*(spc: ptr stbtt_pack_context; fontdata: ptr cuchar;
                          font_index: cint; ranges: ptr stbtt_pack_range;
                          num_ranges: cint): cint {.importc.}
##  Creates character bitmaps from multiple ranges of characters stored in
##  ranges. This will usually create a better-packed bitmap than multiple
##  calls to stbtt_PackFontRange. Note that you can call this multiple
##  times within a single PackBegin/PackEnd.

proc stbtt_PackSetOversampling*(spc: ptr stbtt_pack_context; h_oversample: cuint;
                               v_oversample: cuint) {.importc.}
##  Oversampling a font increases the quality by allowing higher-quality subpixel
##  positioning, and is especially valuable at smaller text sizes.
##
##  This function sets the amount of oversampling for all following calls to
##  stbtt_PackFontRange(s) or stbtt_PackFontRangesGatherRects for a given
##  pack context. The default (no oversampling) is achieved by h_oversample=1
##  and v_oversample=1. The total number of pixels required is
##  h_oversample*v_oversample larger than the default; for example, 2x2
##  oversampling requires 4x the storage of 1x1. For best results, render
##  oversampled textures with bilinear filtering. Look at the readme in
##  stb/tests/oversample for information about oversampled fonts
##
##  To use with PackFontRangesGather etc., you must set it before calls
##  call to PackFontRangesGatherRects.

proc stbtt_PackSetSkipMissingCodepoints*(spc: ptr stbtt_pack_context; skip: cint) {.importc.}
##  If skip != 0, this tells stb_truetype to skip any codepoints for which
##  there is no corresponding glyph. If skip=0, which is the default, then
##  codepoints without a glyph recived the font's "missing character" glyph,
##  typically an empty box by convention.

proc stbtt_GetPackedQuad*(chardata: ptr stbtt_packedchar; pw: cint; ph: cint;
                         char_index: cint; xpos: ptr cfloat; ypos: ptr cfloat;
                         q: ptr stbtt_aligned_quad; align_to_integer: cint) {.importc.}
  ##  same data as above
  ##  character to display
  ##  pointers to current position in screen pixel space
  ##  output: quad to draw
proc stbtt_PackFontRangesGatherRects*(spc: ptr stbtt_pack_context;
                                     info: ptr stbtt_fontinfo;
                                     ranges: ptr stbtt_pack_range;
                                     num_ranges: cint; rects: ptr stbrp_rect): cint {.importc.}
proc stbtt_PackFontRangesPackRects*(spc: ptr stbtt_pack_context;
                                   rects: ptr stbrp_rect; num_rects: cint) {.importc.}
proc stbtt_PackFontRangesRenderIntoRects*(spc: ptr stbtt_pack_context;
    info: ptr stbtt_fontinfo; ranges: ptr stbtt_pack_range; num_ranges: cint;
    rects: ptr stbrp_rect): cint {.importc.}
##  Calling these functions in sequence is roughly equivalent to calling
##  stbtt_PackFontRanges(). If you more control over the packing of multiple
##  fonts, or if you want to pack custom data into a font texture, take a look
##  at the source to of stbtt_PackFontRanges() and create a custom version
##  using these functions, e.g. call GatherRects multiple times,
##  building up a single array of rects, then call PackRects once,
##  then call RenderIntoRects repeatedly. This may result in a
##  better packing than calling PackFontRanges multiple times
##  (or it may not).
##  this is an opaque structure that you shouldn't mess with which holds
##  all the context needed from PackBegin to PackEnd.


## ////////////////////////////////////////////////////////////////////////////
##
##  FONT LOADING
##
##

proc stbtt_GetNumberOfFonts*(data: ptr cuchar): cint {.importc.}
##  This function will determine the number of fonts in a font file.  TrueType
##  collection (.ttc) files may contain multiple fonts, while TrueType font
##  (.ttf) files only contain one font. The number of fonts can be used for
##  indexing with the previous function where the index is between zero and one
##  less than the total fonts. If an error occurs, -1 is returned.

proc stbtt_GetFontOffsetForIndex*(data: ptr cuchar; index: cint): cint {.importc.}
##  Each .ttf/.ttc file may have more than one font. Each font has a sequential
##  index number starting from 0. Call this function to get the font offset for
##  a given index; it returns -1 if the index is out of range. A regular .ttf
##  file will only define one font and it always be at offset 0, so it will
##  return '0' for index 0, and -1 for all other indices.
##  The following structure is defined publicly so you can declare one on
##  the stack or as a global or etc, but you should treat it as opaque.




proc stbtt_InitFont*(info: ptr stbtt_fontinfo; data: ptr cuchar; offset: cint): cint {.importc.}
##  Given an offset into the file that defines a font, this function builds
##  the necessary cached info for the rest of the system. You must allocate
##  the stbtt_fontinfo yourself, and stbtt_InitFont will fill it out. You don't
##  need to do anything special to free it, because the contents are pure
##  value data with no additional data structures. Returns 0 on failure.
## ////////////////////////////////////////////////////////////////////////////
##
##  CHARACTER TO GLYPH-INDEX CONVERSIOn

proc stbtt_FindGlyphIndex*(info: ptr stbtt_fontinfo; unicode_codepoint: cint): cint {.importc.}
##  If you're going to perform multiple operations on the same character
##  and you want a speed-up, call this function with the character you're
##  going to process, then use glyph-based functions instead of the
##  codepoint-based functions.
##  Returns 0 if the character codepoint is not defined in the font.
## ////////////////////////////////////////////////////////////////////////////
##
##  CHARACTER PROPERTIES
##

proc stbtt_ScaleForPixelHeight*(info: ptr stbtt_fontinfo; pixels: cfloat): cfloat {.importc.}
##  computes a scale factor to produce a font whose "height" is 'pixels' tall.
##  Height is measured as the distance from the highest ascender to the lowest
##  descender; in other words, it's equivalent to calling stbtt_GetFontVMetrics
##  and computing:
##        scale = pixels / (ascent - descent)
##  so if you prefer to measure height by the ascent only, use a similar calculation.

proc stbtt_ScaleForMappingEmToPixels*(info: ptr stbtt_fontinfo; pixels: cfloat): cfloat {.importc.}
##  computes a scale factor to produce a font whose EM size is mapped to
##  'pixels' tall. This is probably what traditional APIs compute, but
##  I'm not positive.

proc stbtt_GetFontVMetrics*(info: ptr stbtt_fontinfo; ascent: ptr cint;
                           descent: ptr cint; lineGap: ptr cint) {.importc.}
##  ascent is the coordinate above the baseline the font extends; descent
##  is the coordinate below the baseline the font extends (i.e. it is typically negative)
##  lineGap is the spacing between one row's descent and the next row's ascent...
##  so you should advance the vertical position by "*ascent - *descent + *lineGap"
##    these are expressed in unscaled coordinates, so you must multiply by
##    the scale factor for a given size

proc stbtt_GetFontVMetricsOS2*(info: ptr stbtt_fontinfo; typoAscent: ptr cint;
                              typoDescent: ptr cint; typoLineGap: ptr cint): cint {.importc.}
##  analogous to GetFontVMetrics, but returns the "typographic" values from the OS/2
##  table (specific to MS/Windows TTF files).
##
##  Returns 1 on success (table present), 0 on failure.

proc stbtt_GetFontBoundingBox*(info: ptr stbtt_fontinfo; x0: ptr cint; y0: ptr cint;
                              x1: ptr cint; y1: ptr cint) {.importc.}
##  the bounding box around all possible characters

proc stbtt_GetCodepointHMetrics*(info: ptr stbtt_fontinfo; codepoint: cint;
                                advanceWidth: ptr cint; leftSideBearing: ptr cint) {.importc.}
##  leftSideBearing is the offset from the current horizontal position to the left edge of the character
##  advanceWidth is the offset from the current horizontal position to the next horizontal position
##    these are expressed in unscaled coordinates

proc stbtt_GetCodepointKernAdvance*(info: ptr stbtt_fontinfo; ch1: cint; ch2: cint): cint {.importc.}
##  an additional amount to add to the 'advance' value between ch1 and ch2

proc stbtt_GetCodepointBox*(info: ptr stbtt_fontinfo; codepoint: cint; x0: ptr cint;
                           y0: ptr cint; x1: ptr cint; y1: ptr cint): cint {.importc.}
##  Gets the bounding box of the visible part of the glyph, in unscaled coordinates

proc stbtt_GetGlyphHMetrics*(info: ptr stbtt_fontinfo; glyph_index: cint;
                            advanceWidth: ptr cint; leftSideBearing: ptr cint) {.importc.}
proc stbtt_GetGlyphKernAdvance*(info: ptr stbtt_fontinfo; glyph1: cint; glyph2: cint): cint {.importc.}
proc stbtt_GetGlyphBox*(info: ptr stbtt_fontinfo; glyph_index: cint; x0: ptr cint;
                       y0: ptr cint; x1: ptr cint; y1: ptr cint): cint {.importc.}
##  as above, but takes one or more glyph indices for greater efficiency




proc stbtt_GetKerningTableLength*(info: ptr stbtt_fontinfo): cint {.importc.}
proc stbtt_GetKerningTable*(info: ptr stbtt_fontinfo; table: ptr stbtt_kerningentry;
                           table_length: cint): cint  {.importc.}
##  Retrieves a complete list of all of the kerning pairs provided by the font
##  stbtt_GetKerningTable never writes more than table_length entries and returns how many entries it did write.
##  The table will be sorted by (a.glyph1 == b.glyph1)?(a.glyph2 < b.glyph2):(a.glyph1 < b.glyph1)
## ////////////////////////////////////////////////////////////////////////////
##
##  GLYPH SHAPES (you probably don't need these, but they have to go before
##  the bitmaps for C declaration-order reasons)
##

## !!!Ignored construct:  # STBTT_vmove  you can predefine these to use different values (but why?) enum [NewLine] { STBTT_vmove = 1 , STBTT_vline , STBTT_vcurve , STBTT_vcubic } ;
## Error: expected '{'!!!

## !!!Ignored construct:  # stbtt_vertex  you can predefine this to use different values \
##  (we share this with other code at RAD) # stbtt_vertex_type short  can't use stbtt_int16 because that's not visible in the header file typedef struct [NewLine] { stbtt_vertex_type x , y , cx , cy , cx1 , cy1 ; unsigned char type , padding ; } stbtt_vertex ;
## Error: identifier expected, but got: [NewLine]!!!

proc stbtt_IsGlyphEmpty*(info: ptr stbtt_fontinfo; glyph_index: cint): cint {.importc.}
##  returns non-zero if nothing is drawn for this glyph

proc stbtt_GetCodepointShape*(info: ptr stbtt_fontinfo; unicode_codepoint: cint;
                             vertices: ptr ptr stbtt_vertex): cint {.importc.}
proc stbtt_GetGlyphShape*(info: ptr stbtt_fontinfo; glyph_index: cint;
                         vertices: ptr ptr stbtt_vertex): cint {.importc.}
##  returns # of vertices and fills *vertices with the pointer to them
##    these are expressed in "unscaled" coordinates
##
##  The shape is a series of contours. Each one starts with
##  a STBTT_moveto, then consists of a series of mixed
##  STBTT_lineto and STBTT_curveto segments. A lineto
##  draws a line from previous endpoint to its x,y; a curveto
##  draws a quadratic bezier from previous endpoint to
##  its x,y, using cx,cy as the bezier control point.

proc stbtt_FreeShape*(info: ptr stbtt_fontinfo; vertices: ptr stbtt_vertex) {.importc.}
##  frees the data allocated above

proc stbtt_FindSVGDoc*(info: ptr stbtt_fontinfo; gl: cint): ptr cuchar {.importc.}
proc stbtt_GetCodepointSVG*(info: ptr stbtt_fontinfo; unicode_codepoint: cint;
                           svg: cstringArray): cint {.importc.}
proc stbtt_GetGlyphSVG*(info: ptr stbtt_fontinfo; gl: cint; svg: cstringArray): cint {.importc.}
##  fills svg with the character's SVG data.
##  returns data size or 0 if SVG not found.
## ////////////////////////////////////////////////////////////////////////////
##
##  BITMAP RENDERING
##

proc stbtt_FreeBitmap*(bitmap: ptr cuchar; userdata: pointer) {.importc.}
##  frees the bitmap allocated below

proc stbtt_GetCodepointBitmap*(info: ptr stbtt_fontinfo; scale_x: cfloat;
                              scale_y: cfloat; codepoint: cint; width: ptr cint;
                              height: ptr cint; xoff: ptr cint; yoff: ptr cint): ptr cuchar {.importc.}
##  allocates a large-enough single-channel 8bpp bitmap and renders the
##  specified character/glyph at the specified scale into it, with
##  antialiasing. 0 is no coverage (transparent), 255 is fully covered (opaque).
##  *width & *height are filled out with the width & height of the bitmap,
##  which is stored left-to-right, top-to-bottom.
##
##  xoff/yoff are the offset it pixel space from the glyph origin to the top-left of the bitmap

proc stbtt_GetCodepointBitmapSubpixel*(info: ptr stbtt_fontinfo; scale_x: cfloat;
                                      scale_y: cfloat; shift_x: cfloat;
                                      shift_y: cfloat; codepoint: cint;
                                      width: ptr cint; height: ptr cint;
                                      xoff: ptr cint; yoff: ptr cint): ptr cuchar {.importc.}
##  the same as stbtt_GetCodepoitnBitmap, but you can specify a subpixel
##  shift for the character

proc stbtt_MakeCodepointBitmap*(info: ptr stbtt_fontinfo; output: ptr cuchar;
                               out_w: cint; out_h: cint; out_stride: cint;
                               scale_x: cfloat; scale_y: cfloat; codepoint: cint) {.importc.}
##  the same as stbtt_GetCodepointBitmap, but you pass in storage for the bitmap
##  in the form of 'output', with row spacing of 'out_stride' bytes. the bitmap
##  is clipped to out_w/out_h bytes. Call stbtt_GetCodepointBitmapBox to get the
##  width and height and positioning info for it first.

proc stbtt_MakeCodepointBitmapSubpixel*(info: ptr stbtt_fontinfo;
                                       output: ptr cuchar; out_w: cint; out_h: cint;
                                       out_stride: cint; scale_x: cfloat;
                                       scale_y: cfloat; shift_x: cfloat;
                                       shift_y: cfloat; codepoint: cint) {.importc.}
##  same as stbtt_MakeCodepointBitmap, but you can specify a subpixel
##  shift for the character

proc stbtt_MakeCodepointBitmapSubpixelPrefilter*(info: ptr stbtt_fontinfo;
    output: ptr cuchar; out_w: cint; out_h: cint; out_stride: cint; scale_x: cfloat;
    scale_y: cfloat; shift_x: cfloat; shift_y: cfloat; oversample_x: cint;
    oversample_y: cint; sub_x: ptr cfloat; sub_y: ptr cfloat; codepoint: cint) {.importc.}
##  same as stbtt_MakeCodepointBitmapSubpixel, but prefiltering
##  is performed (see stbtt_PackSetOversampling)

proc stbtt_GetCodepointBitmapBox*(font: ptr stbtt_fontinfo; codepoint: cint;
                                 scale_x: cfloat; scale_y: cfloat; ix0: ptr cint;
                                 iy0: ptr cint; ix1: ptr cint; iy1: ptr cint) {.importc.}
##  get the bbox of the bitmap centered around the glyph origin; so the
##  bitmap width is ix1-ix0, height is iy1-iy0, and location to place
##  the bitmap top left is (leftSideBearing*scale,iy0).
##  (Note that the bitmap uses y-increases-down, but the shape uses
##  y-increases-up, so CodepointBitmapBox and CodepointBox are inverted.)

proc stbtt_GetCodepointBitmapBoxSubpixel*(font: ptr stbtt_fontinfo; codepoint: cint;
    scale_x: cfloat; scale_y: cfloat; shift_x: cfloat; shift_y: cfloat; ix0: ptr cint;
    iy0: ptr cint; ix1: ptr cint; iy1: ptr cint) {.importc.}
##  same as stbtt_GetCodepointBitmapBox, but you can specify a subpixel
##  shift for the character
##  the following functions are equivalent to the above functions, but operate
##  on glyph indices instead of Unicode codepoints (for efficiency)

proc stbtt_GetGlyphBitmap*(info: ptr stbtt_fontinfo; scale_x: cfloat; scale_y: cfloat;
                          glyph: cint; width: ptr cint; height: ptr cint;
                          xoff: ptr cint; yoff: ptr cint): ptr cuchar {.importc.}
proc stbtt_GetGlyphBitmapSubpixel*(info: ptr stbtt_fontinfo; scale_x: cfloat;
                                  scale_y: cfloat; shift_x: cfloat; shift_y: cfloat;
                                  glyph: cint; width: ptr cint; height: ptr cint;
                                  xoff: ptr cint; yoff: ptr cint): ptr cuchar {.importc.}
proc stbtt_MakeGlyphBitmap*(info: ptr stbtt_fontinfo; output: ptr cuchar; out_w: cint;
                           out_h: cint; out_stride: cint; scale_x: cfloat;
                           scale_y: cfloat; glyph: cint) {.importc.}
proc stbtt_MakeGlyphBitmapSubpixel*(info: ptr stbtt_fontinfo; output: ptr cuchar;
                                   out_w: cint; out_h: cint; out_stride: cint;
                                   scale_x: cfloat; scale_y: cfloat;
                                   shift_x: cfloat; shift_y: cfloat; glyph: cint) {.importc.}
proc stbtt_MakeGlyphBitmapSubpixelPrefilter*(info: ptr stbtt_fontinfo;
    output: ptr cuchar; out_w: cint; out_h: cint; out_stride: cint; scale_x: cfloat;
    scale_y: cfloat; shift_x: cfloat; shift_y: cfloat; oversample_x: cint;
    oversample_y: cint; sub_x: ptr cfloat; sub_y: ptr cfloat; glyph: cint) {.importc.}
proc stbtt_GetGlyphBitmapBox*(font: ptr stbtt_fontinfo; glyph: cint; scale_x: cfloat;
                             scale_y: cfloat; ix0: ptr cint; iy0: ptr cint;
                             ix1: ptr cint; iy1: ptr cint) {.importc.}
proc stbtt_GetGlyphBitmapBoxSubpixel*(font: ptr stbtt_fontinfo; glyph: cint;
                                     scale_x: cfloat; scale_y: cfloat;
                                     shift_x: cfloat; shift_y: cfloat;
                                     ix0: ptr cint; iy0: ptr cint; ix1: ptr cint;
                                     iy1: ptr cint) {.importc.}
##  @TODO: don't expose this structure


##  rasterize a shape with quadratic beziers into a bitmap

proc stbtt_Rasterize*(result: ptr stbtt_bitmap; flatness_in_pixels: cfloat;
                     vertices: ptr stbtt_vertex; num_verts: cint; scale_x: cfloat;
                     scale_y: cfloat; shift_x: cfloat; shift_y: cfloat; x_off: cint;
                     y_off: cint; invert: cint; userdata: pointer) {.importc.}
  ##  1-channel bitmap to draw into
  ##  allowable error of curve in pixels
  ##  array of vertices defining shape
  ##  number of vertices in above array
  ##  scale applied to input vertices
  ##  translation applied to input vertices
  ##  another translation applied to input
  ##  if non-zero, vertically flip shape
##  context for to STBTT_MALLOC
## ////////////////////////////////////////////////////////////////////////////
##
##  Signed Distance Function (or Field) rendering

proc stbtt_FreeSDF*(bitmap: ptr cuchar; userdata: pointer) {.importc.}
##  frees the SDF bitmap allocated below

proc stbtt_GetGlyphSDF*(info: ptr stbtt_fontinfo; scale: cfloat; glyph: cint;
                       padding: cint; onedge_value: cuchar;
                       pixel_dist_scale: cfloat; width: ptr cint; height: ptr cint;
                       xoff: ptr cint; yoff: ptr cint): ptr cuchar {.importc.}
proc stbtt_GetCodepointSDF*(info: ptr stbtt_fontinfo; scale: cfloat; codepoint: cint;
                           padding: cint; onedge_value: cuchar;
                           pixel_dist_scale: cfloat; width: ptr cint;
                           height: ptr cint; xoff: ptr cint; yoff: ptr cint): ptr cuchar {.importc.}
##  These functions compute a discretized SDF field for a single character, suitable for storing
##  in a single-channel texture, sampling with bilinear filtering, and testing against
##  larger than some threshold to produce scalable fonts.
##         info              --  the font
##         scale             --  controls the size of the resulting SDF bitmap, same as it would be creating a regular bitmap
##         glyph/codepoint   --  the character to generate the SDF for
##         padding           --  extra "pixels" around the character which are filled with the distance to the character (not 0),
##                                  which allows effects like bit outlines
##         onedge_value      --  value 0-255 to test the SDF against to reconstruct the character (i.e. the isocontour of the character)
##         pixel_dist_scale  --  what value the SDF should increase by when moving one SDF "pixel" away from the edge (on the 0..255 scale)
##                                  if positive, > onedge_value is inside; if negative, < onedge_value is inside
##         width,height      --  output height & width of the SDF bitmap (including padding)
##         xoff,yoff         --  output origin of the character
##         return value      --  a 2D array of bytes 0..255, width*height in size
##
##  pixel_dist_scale & onedge_value are a scale & bias that allows you to make
##  optimal use of the limited 0..255 for your application, trading off precision
##  and special effects. SDF values outside the range 0..255 are clamped to 0..255.
##
##  Example:
##       scale = stbtt_ScaleForPixelHeight(22)
##       padding = 5
##       onedge_value = 180
##       pixel_dist_scale = 180/5.0 = 36.0
##
##       This will create an SDF bitmap in which the character is about 22 pixels
##       high but the whole bitmap is about 22+5+5=32 pixels high. To produce a filled
##       shape, sample the SDF at each pixel and fill the pixel if the SDF value
##       is greater than or equal to 180/255. (You'll actually want to antialias,
##       which is beyond the scope of this example.) Additionally, you can compute
##       offset outlines (e.g. to stroke the character border inside & outside,
##       or only outside). For example, to fill outside the character up to 3 SDF
##       pixels, you would compare against (180-36.0*3)/255 = 72/255. The above
##       choice of variables maps a range from 5 pixels outside the shape to
##       2 pixels inside the shape to 0..255; this is intended primarily for apply
##       outside effects only (the interior range is needed to allow proper
##       antialiasing of the font at *smaller* sizes)
##
##  The function computes the SDF analytically at each SDF pixel, not by e.g.
##  building a higher-res bitmap and approximating it. In theory the quality
##  should be as high as possible for an SDF of this size & representation, but
##  unclear if this is true in practice (perhaps building a higher-res bitmap
##  and computing from that can allow drop-out prevention).
##
##  The algorithm has not been optimized at all, so expect it to be slow
##  if computing lots of characters or very large sizes.
## ////////////////////////////////////////////////////////////////////////////
##
##  Finding the right font...
##
##  You should really just solve this offline, keep your own tables
##  of what font is what, and don't try to get it out of the .ttf file.
##  That's because getting it out of the .ttf file is really hard, because
##  the names in the file can appear in many possible encodings, in many
##  possible languages, and e.g. if you need a case-insensitive comparison,
##  the details of that depend on the encoding & language in a complex way
##  (actually underspecified in truetype, but also gigantic).
##
##  But you can use the provided functions in two possible ways:
##      stbtt_FindMatchingFont() will use *case-sensitive* comparisons on
##              unicode-encoded names to try to find the font you want;
##              you can run this before calling stbtt_InitFont()
##
##      stbtt_GetFontNameString() lets you get any of the various strings
##              from the file yourself and do your own comparisons on them.
##              You have to have called stbtt_InitFont() first.

proc stbtt_FindMatchingFont*(fontdata: ptr cuchar; name: cstring; flags: cint): cint {.importc.}
##  returns the offset (not index) of the font that matches, or -1 if none
##    if you use STBTT_MACSTYLE_DONTCARE, use a font name like "Arial Bold".
##    if you use any other flag, use a font name like "Arial"; this checks
##      the 'macStyle' header field; i don't know if fonts set this consistently

const
  STBTT_MACSTYLE_DONTCARE* = 0
  STBTT_MACSTYLE_BOLD* = 1
  STBTT_MACSTYLE_ITALIC* = 2
  STBTT_MACSTYLE_UNDERSCORE* = 4
  STBTT_MACSTYLE_NONE* = 8

proc stbtt_CompareUTF8toUTF16_bigendian*(s1: cstring; len1: cint; s2: cstring;
                                        len2: cint): cint {.importc.}
##  returns 1/0 whether the first string interpreted as utf8 is identical to
##  the second string interpreted as big-endian utf16... useful for strings from next func

proc stbtt_GetFontNameString*(font: ptr stbtt_fontinfo; length: ptr cint;
                             platformID: cint; encodingID: cint; languageID: cint;
                             nameID: cint): cstring {.importc.}
##  returns the string (which may be big-endian double byte, e.g. for unicode)
##  and puts the length in bytes in *length.
##
##  some of the values for the IDs are below; for more see the truetype spec:
##      http://developer.apple.com/textfonts/TTRefMan/RM06/Chap6name.html
##      http://www.microsoft.com/typography/otspec/name.htm

const                         ##  platformID
  STBTT_PLATFORM_ID_UNICODE* = 0
  STBTT_PLATFORM_ID_MAC* = 1
  STBTT_PLATFORM_ID_ISO* = 2
  STBTT_PLATFORM_ID_MICROSOFT* = 3

const                         ##  encodingID for STBTT_PLATFORM_ID_UNICODE
  STBTT_UNICODE_EID_UNICODE_1_0* = 0
  STBTT_UNICODE_EID_UNICODE_1_1* = 1
  STBTT_UNICODE_EID_ISO_10646* = 2
  STBTT_UNICODE_EID_UNICODE_2_0_BMP* = 3
  STBTT_UNICODE_EID_UNICODE_2_0_FULL* = 4

const                         ##  encodingID for STBTT_PLATFORM_ID_MICROSOFT
  STBTT_MS_EID_SYMBOL* = 0
  STBTT_MS_EID_UNICODE_BMP* = 1
  STBTT_MS_EID_SHIFTJIS* = 2
  STBTT_MS_EID_UNICODE_FULL* = 10

const                         ##  encodingID for STBTT_PLATFORM_ID_MAC; same as Script Manager codes
  STBTT_MAC_EID_ROMAN* = 0
  STBTT_MAC_EID_ARABIC* = 4
  STBTT_MAC_EID_JAPANESE* = 1
  STBTT_MAC_EID_HEBREW* = 5
  STBTT_MAC_EID_CHINESE_TRAD* = 2
  STBTT_MAC_EID_GREEK* = 6
  STBTT_MAC_EID_KOREAN* = 3
  STBTT_MAC_EID_RUSSIAN* = 7

const ##  languageID for STBTT_PLATFORM_ID_MICROSOFT; same as LCID...
     ##  problematic because there are e.g. 16 english LCIDs and 16 arabic LCIDs
  STBTT_MS_LANG_ENGLISH* = 0x0409
  STBTT_MS_LANG_ITALIAN* = 0x0410
  STBTT_MS_LANG_CHINESE* = 0x0804
  STBTT_MS_LANG_JAPANESE* = 0x0411
  STBTT_MS_LANG_DUTCH* = 0x0413
  STBTT_MS_LANG_KOREAN* = 0x0412
  STBTT_MS_LANG_FRENCH* = 0x040c
  STBTT_MS_LANG_RUSSIAN* = 0x0419
  STBTT_MS_LANG_GERMAN* = 0x0407
  STBTT_MS_LANG_SPANISH* = 0x0409
  STBTT_MS_LANG_HEBREW* = 0x040d
  STBTT_MS_LANG_SWEDISH* = 0x041D

const                         ##  languageID for STBTT_PLATFORM_ID_MAC
  STBTT_MAC_LANG_ENGLISH* = 0
  STBTT_MAC_LANG_JAPANESE* = 11
  STBTT_MAC_LANG_ARABIC* = 12
  STBTT_MAC_LANG_KOREAN* = 23
  STBTT_MAC_LANG_DUTCH* = 4
  STBTT_MAC_LANG_RUSSIAN* = 32
  STBTT_MAC_LANG_FRENCH* = 1
  STBTT_MAC_LANG_SPANISH* = 6
  STBTT_MAC_LANG_GERMAN* = 2
  STBTT_MAC_LANG_SWEDISH* = 5
  STBTT_MAC_LANG_HEBREW* = 10
  STBTT_MAC_LANG_CHINESE_SIMPLIFIED* = 33
  STBTT_MAC_LANG_ITALIAN* = 3
  STBTT_MAC_LANG_CHINESE_TRAD* = 19
