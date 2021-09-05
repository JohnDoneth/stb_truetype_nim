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
    y1*: cushort
    xoff*: cfloat
    yoff*: cfloat
    xadvance*: cfloat

type
  stbtt_aligned_quad* {.bycopy.} = object
    x0*: cfloat
    y0*: cfloat
    s0*: cfloat
    t0*: cfloat
    x1*: cfloat
    y1*: cfloat
    s1*: cfloat
    t1*: cfloat

type
  stbtt_packedchar* {.bycopy.} = object
    x0*: cushort
    y0*: cushort
    x1*: cushort
    y1*: cushort
    xoff*: cfloat
    yoff*: cfloat
    xadvance*: cfloat
    xoff2*: cfloat
    yoff2*: cfloat

type
  stbtt_pack_range* {.bycopy.} = object
    font_size*: cfloat
    first_unicode_codepoint_in_range*: cint
    array_of_unicode_codepoints*: ptr cint
    num_chars*: cint
    chardata_for_range*: ptr stbtt_packedchar
    h_oversample*: cuchar
    v_oversample*: cuchar

type
  stbtt_fontinfo* {.bycopy.} = object
    userdata*: pointer
    data*: ptr cuchar
    fontstart*: cint
    numGlyphs*: cint
    loca*: cint
    head*: cint
    glyf*: cint
    hhea*: cint
    hmtx*: cint
    kern*: cint
    gpos*: cint
    svg*: cint
    index_map*: cint
    indexToLocFormat*: cint
    cff*: stbtt_buf
    charstrings*: stbtt_buf
    gsubrs*: stbtt_buf
    subrs*: stbtt_buf
    fontdicts*: stbtt_buf
    fdselect*: stbtt_buf

type
  stbtt_bitmap* {.bycopy.} = object
    w*: cint
    h*: cint
    stride*: cint
    pixels*: ptr cuchar

type
  stbtt_kerningentry* {.bycopy.} = object
    glyph1*: cint
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
                          pixels: ptr cuchar; pw: cint; ph: cint;
                              first_char: cint;
                          num_chars: cint;
                              chardata: ptr stbtt_bakedchar): cint {.importc.}

proc stbtt_GetBakedQuad*(chardata: ptr stbtt_bakedchar; pw: cint; ph: cint;
                        char_index: cint; xpos: ptr cfloat; ypos: ptr cfloat;
                        q: ptr stbtt_aligned_quad; opengl_fillrule: cint) {.importc.}

proc stbtt_GetScaledFontVMetrics*(fontdata: ptr cuchar; index: cint; size: cfloat;
                                 ascent: ptr cfloat; descent: ptr cfloat;
                                 lineGap: ptr cfloat) {.importc.}

proc stbtt_PackBegin*(spc: ptr stbtt_pack_context; pixels: ptr cuchar; width: cint;
                     height: cint; stride_in_bytes: cint; padding: cint;
                     alloc_context: pointer): cint {.importc.}

proc stbtt_PackEnd*(spc: ptr stbtt_pack_context) {.importc.}

template STBTT_POINT_SIZE*(x: untyped): untyped =
  (-(x))
proc stbtt_PackFontRange*(spc: ptr stbtt_pack_context; fontdata: ptr cuchar;
                         font_index: cint; font_size: cfloat;
                         first_unicode_char_in_range: cint;
                         num_chars_in_range: cint;
                         chardata_for_range: ptr stbtt_packedchar): cint {.importc.}

proc stbtt_PackFontRanges*(spc: ptr stbtt_pack_context; fontdata: ptr cuchar;
                          font_index: cint; ranges: ptr stbtt_pack_range;
                          num_ranges: cint): cint {.importc.}

proc stbtt_PackSetOversampling*(spc: ptr stbtt_pack_context; h_oversample: cuint;
                               v_oversample: cuint) {.importc.}

proc stbtt_PackSetSkipMissingCodepoints*(spc: ptr stbtt_pack_context;
    skip: cint) {.importc.}

proc stbtt_GetPackedQuad*(chardata: ptr stbtt_packedchar; pw: cint; ph: cint;
                         char_index: cint; xpos: ptr cfloat; ypos: ptr cfloat;
                         q: ptr stbtt_aligned_quad; align_to_integer: cint) {.importc.}

proc stbtt_PackFontRangesGatherRects*(spc: ptr stbtt_pack_context;
                                     info: ptr stbtt_fontinfo;
                                     ranges: ptr stbtt_pack_range;
                                     num_ranges: cint;
                                         rects: ptr stbrp_rect): cint {.importc.}
proc stbtt_PackFontRangesPackRects*(spc: ptr stbtt_pack_context;
                                   rects: ptr stbrp_rect; num_rects: cint) {.importc.}
proc stbtt_PackFontRangesRenderIntoRects*(spc: ptr stbtt_pack_context;
    info: ptr stbtt_fontinfo; ranges: ptr stbtt_pack_range; num_ranges: cint;
    rects: ptr stbrp_rect): cint {.importc.}

proc stbtt_GetNumberOfFonts*(data: ptr cuchar): cint {.importc.}

proc stbtt_GetFontOffsetForIndex*(data: ptr cuchar; index: cint): cint {.importc.}

proc stbtt_InitFont*(info: ptr stbtt_fontinfo; data: ptr cuchar;
    offset: cint): cint {.importc.}

proc stbtt_FindGlyphIndex*(info: ptr stbtt_fontinfo;
    unicode_codepoint: cint): cint {.importc.}

proc stbtt_ScaleForPixelHeight*(info: ptr stbtt_fontinfo;
    pixels: cfloat): cfloat {.importc.}

proc stbtt_ScaleForMappingEmToPixels*(info: ptr stbtt_fontinfo;
    pixels: cfloat): cfloat {.importc.}

proc stbtt_GetFontVMetrics*(info: ptr stbtt_fontinfo; ascent: ptr cint;
                           descent: ptr cint; lineGap: ptr cint) {.importc.}

proc stbtt_GetFontVMetricsOS2*(info: ptr stbtt_fontinfo; typoAscent: ptr cint;
                              typoDescent: ptr cint;
                                  typoLineGap: ptr cint): cint {.importc.}

proc stbtt_GetFontBoundingBox*(info: ptr stbtt_fontinfo; x0: ptr cint; y0: ptr cint;
                              x1: ptr cint; y1: ptr cint) {.importc.}

proc stbtt_GetCodepointHMetrics*(info: ptr stbtt_fontinfo; codepoint: cint;
                                advanceWidth: ptr cint;
                                    leftSideBearing: ptr cint) {.importc.}

proc stbtt_GetCodepointKernAdvance*(info: ptr stbtt_fontinfo; ch1: cint;
    ch2: cint): cint {.importc.}

proc stbtt_GetCodepointBox*(info: ptr stbtt_fontinfo; codepoint: cint; x0: ptr cint;
                           y0: ptr cint; x1: ptr cint; y1: ptr cint): cint {.importc.}

proc stbtt_GetGlyphHMetrics*(info: ptr stbtt_fontinfo; glyph_index: cint;
                            advanceWidth: ptr cint;
                                leftSideBearing: ptr cint) {.importc.}
proc stbtt_GetGlyphKernAdvance*(info: ptr stbtt_fontinfo; glyph1: cint;
    glyph2: cint): cint {.importc.}
proc stbtt_GetGlyphBox*(info: ptr stbtt_fontinfo; glyph_index: cint; x0: ptr cint;
                       y0: ptr cint; x1: ptr cint; y1: ptr cint): cint {.importc.}

proc stbtt_GetKerningTableLength*(info: ptr stbtt_fontinfo): cint {.importc.}
proc stbtt_GetKerningTable*(info: ptr stbtt_fontinfo; table: ptr stbtt_kerningentry;
                           table_length: cint): cint {.importc.}

proc stbtt_IsGlyphEmpty*(info: ptr stbtt_fontinfo; glyph_index: cint): cint {.importc.}

proc stbtt_GetCodepointShape*(info: ptr stbtt_fontinfo; unicode_codepoint: cint;
                             vertices: ptr ptr stbtt_vertex): cint {.importc.}
proc stbtt_GetGlyphShape*(info: ptr stbtt_fontinfo; glyph_index: cint;
                         vertices: ptr ptr stbtt_vertex): cint {.importc.}

proc stbtt_FreeShape*(info: ptr stbtt_fontinfo; vertices: ptr stbtt_vertex) {.importc.}

proc stbtt_FindSVGDoc*(info: ptr stbtt_fontinfo; gl: cint): ptr cuchar {.importc.}
proc stbtt_GetCodepointSVG*(info: ptr stbtt_fontinfo; unicode_codepoint: cint;
                           svg: cstringArray): cint {.importc.}
proc stbtt_GetGlyphSVG*(info: ptr stbtt_fontinfo; gl: cint;
    svg: cstringArray): cint {.importc.}

proc stbtt_FreeBitmap*(bitmap: ptr cuchar; userdata: pointer) {.importc.}

proc stbtt_GetCodepointBitmap*(info: ptr stbtt_fontinfo; scale_x: cfloat;
                              scale_y: cfloat; codepoint: cint; width: ptr cint;
                              height: ptr cint; xoff: ptr cint;
                                  yoff: ptr cint): ptr cuchar {.importc.}

proc stbtt_GetCodepointBitmapSubpixel*(info: ptr stbtt_fontinfo; scale_x: cfloat;
                                      scale_y: cfloat; shift_x: cfloat;
                                      shift_y: cfloat; codepoint: cint;
                                      width: ptr cint; height: ptr cint;
                                      xoff: ptr cint;
                                          yoff: ptr cint): ptr cuchar {.importc.}

proc stbtt_MakeCodepointBitmap*(info: ptr stbtt_fontinfo; output: ptr cuchar;
                               out_w: cint; out_h: cint; out_stride: cint;
                               scale_x: cfloat; scale_y: cfloat;
                                   codepoint: cint) {.importc.}

proc stbtt_MakeCodepointBitmapSubpixel*(info: ptr stbtt_fontinfo;
                                       output: ptr cuchar; out_w: cint;
                                           out_h: cint;
                                       out_stride: cint; scale_x: cfloat;
                                       scale_y: cfloat; shift_x: cfloat;
                                       shift_y: cfloat; codepoint: cint) {.importc.}

proc stbtt_MakeCodepointBitmapSubpixelPrefilter*(info: ptr stbtt_fontinfo;
    output: ptr cuchar; out_w: cint; out_h: cint; out_stride: cint;
        scale_x: cfloat;
    scale_y: cfloat; shift_x: cfloat; shift_y: cfloat; oversample_x: cint;
    oversample_y: cint; sub_x: ptr cfloat; sub_y: ptr cfloat;
        codepoint: cint) {.importc.}

proc stbtt_GetCodepointBitmapBox*(font: ptr stbtt_fontinfo; codepoint: cint;
                                 scale_x: cfloat; scale_y: cfloat;
                                     ix0: ptr cint;
                                 iy0: ptr cint; ix1: ptr cint; iy1: ptr cint) {.importc.}

proc stbtt_GetCodepointBitmapBoxSubpixel*(font: ptr stbtt_fontinfo;
    codepoint: cint;scale_x: cfloat; scale_y: cfloat; shift_x: cfloat;
        shift_y: cfloat; ix0: ptr cint;
    iy0: ptr cint; ix1: ptr cint; iy1: ptr cint) {.importc.}

proc stbtt_GetGlyphBitmap*(info: ptr stbtt_fontinfo; scale_x: cfloat; scale_y: cfloat;
                          glyph: cint; width: ptr cint; height: ptr cint;
                          xoff: ptr cint; yoff: ptr cint): ptr cuchar {.importc.}
proc stbtt_GetGlyphBitmapSubpixel*(info: ptr stbtt_fontinfo; scale_x: cfloat;
                                  scale_y: cfloat; shift_x: cfloat;
                                      shift_y: cfloat;
                                  glyph: cint; width: ptr cint;
                                      height: ptr cint;
                                  xoff: ptr cint; yoff: ptr cint): ptr cuchar {.importc.}
proc stbtt_MakeGlyphBitmap*(info: ptr stbtt_fontinfo; output: ptr cuchar; out_w: cint;
                           out_h: cint; out_stride: cint; scale_x: cfloat;
                           scale_y: cfloat; glyph: cint) {.importc.}
proc stbtt_MakeGlyphBitmapSubpixel*(info: ptr stbtt_fontinfo; output: ptr cuchar;
                                   out_w: cint; out_h: cint; out_stride: cint;
                                   scale_x: cfloat; scale_y: cfloat;
                                   shift_x: cfloat; shift_y: cfloat;
                                       glyph: cint) {.importc.}
proc stbtt_MakeGlyphBitmapSubpixelPrefilter*(info: ptr stbtt_fontinfo;
    output: ptr cuchar; out_w: cint; out_h: cint; out_stride: cint;
        scale_x: cfloat;
    scale_y: cfloat; shift_x: cfloat; shift_y: cfloat; oversample_x: cint;
    oversample_y: cint; sub_x: ptr cfloat; sub_y: ptr cfloat; glyph: cint) {.importc.}
proc stbtt_GetGlyphBitmapBox*(font: ptr stbtt_fontinfo; glyph: cint; scale_x: cfloat;
                             scale_y: cfloat; ix0: ptr cint; iy0: ptr cint;
                             ix1: ptr cint; iy1: ptr cint) {.importc.}
proc stbtt_GetGlyphBitmapBoxSubpixel*(font: ptr stbtt_fontinfo; glyph: cint;
                                     scale_x: cfloat; scale_y: cfloat;
                                     shift_x: cfloat; shift_y: cfloat;
                                     ix0: ptr cint; iy0: ptr cint;
                                         ix1: ptr cint;
                                     iy1: ptr cint) {.importc.}

proc stbtt_Rasterize*(result: ptr stbtt_bitmap; flatness_in_pixels: cfloat;
                     vertices: ptr stbtt_vertex; num_verts: cint;
                         scale_x: cfloat;
                     scale_y: cfloat; shift_x: cfloat; shift_y: cfloat;
                         x_off: cint;
                     y_off: cint; invert: cint; userdata: pointer) {.importc.}

proc stbtt_FreeSDF*(bitmap: ptr cuchar; userdata: pointer) {.importc.}

proc stbtt_GetGlyphSDF*(info: ptr stbtt_fontinfo; scale: cfloat; glyph: cint;
                       padding: cint; onedge_value: cuchar;
                       pixel_dist_scale: cfloat; width: ptr cint;
                           height: ptr cint;
                       xoff: ptr cint; yoff: ptr cint): ptr cuchar {.importc.}
proc stbtt_GetCodepointSDF*(info: ptr stbtt_fontinfo; scale: cfloat; codepoint: cint;
                           padding: cint; onedge_value: cuchar;
                           pixel_dist_scale: cfloat; width: ptr cint;
                           height: ptr cint; xoff: ptr cint;
                               yoff: ptr cint): ptr cuchar {.importc.}

proc stbtt_FindMatchingFont*(fontdata: ptr cuchar; name: cstring;
    flags: cint): cint {.importc.}

const
  STBTT_MACSTYLE_DONTCARE* = 0
  STBTT_MACSTYLE_BOLD* = 1
  STBTT_MACSTYLE_ITALIC* = 2
  STBTT_MACSTYLE_UNDERSCORE* = 4
  STBTT_MACSTYLE_NONE* = 8

proc stbtt_CompareUTF8toUTF16_bigendian*(s1: cstring; len1: cint; s2: cstring;
                                        len2: cint): cint {.importc.}

proc stbtt_GetFontNameString*(font: ptr stbtt_fontinfo; length: ptr cint;
                             platformID: cint; encodingID: cint;
                                 languageID: cint;
                             nameID: cint): cstring {.importc.}

const
  STBTT_PLATFORM_ID_UNICODE* = 0
  STBTT_PLATFORM_ID_MAC* = 1
  STBTT_PLATFORM_ID_ISO* = 2
  STBTT_PLATFORM_ID_MICROSOFT* = 3

const
  STBTT_UNICODE_EID_UNICODE_1_0* = 0
  STBTT_UNICODE_EID_UNICODE_1_1* = 1
  STBTT_UNICODE_EID_ISO_10646* = 2
  STBTT_UNICODE_EID_UNICODE_2_0_BMP* = 3
  STBTT_UNICODE_EID_UNICODE_2_0_FULL* = 4

const
  STBTT_MS_EID_SYMBOL* = 0
  STBTT_MS_EID_UNICODE_BMP* = 1
  STBTT_MS_EID_SHIFTJIS* = 2
  STBTT_MS_EID_UNICODE_FULL* = 10

const
  STBTT_MAC_EID_ROMAN* = 0
  STBTT_MAC_EID_ARABIC* = 4
  STBTT_MAC_EID_JAPANESE* = 1
  STBTT_MAC_EID_HEBREW* = 5
  STBTT_MAC_EID_CHINESE_TRAD* = 2
  STBTT_MAC_EID_GREEK* = 6
  STBTT_MAC_EID_KOREAN* = 3
  STBTT_MAC_EID_RUSSIAN* = 7

const

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

const
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
