import 
  nimPNG, 
  options, 
  sequtils, 
  stb_truetype, 
  strformat,
  unittest

## Constants

const 
  FONT_DATA = slurp("./Roboto-Regular.ttf")
  IMAGE_DIRECTORY = "tests/images/"

## Test Utilities

proc `=~` *(x, y: float): bool =
  ## Checks if floats are the same up to a certain precision.
  ## https://github.com/nim-lang/Nim/issues/7504#issuecomment-378833169
  const eps = 1.0e-5 ## Epsilon used for float comparisons.
  abs(x - y) < eps

proc checkImage(name: string, data: openArray[uint8], width, height: int) =
  ## Compares an image to an existing image to prevent regression.
  let filename = IMAGE_DIRECTORY & name
  let image = loadPNG(filename, PNGColorType.LCT_GREY, 8)

  if image == nil:
    stdout.write(fmt("Image not found for test: {name} at {filename}. Saving a new image."))
    discard savePNG(filename, data, PNGColorType.LCT_GREY, 8, width, height)
  else:
    check image.height == height
    check image.width == width

    # Not entirely sure why the subrange is required but there's an extra
    # integer on the end we want to ignore.
    check cast[seq[uint8]](image.data) == data[0..data.len - 2]

## Tests

suite "initFont":
  test "loads a TTF font from bytes.":
    check initFont(FONT_DATA).isSome()

  test "returns none when the a TTF font could not be loaded.":
    check initFont(@[0.cuchar]).isNone()

suite "getNumberOfFonts":
  test "returns the number of fonts found in TTF data.":
    check getNumberOfFonts(FONT_DATA) == 1

suite "getFontOffsetForIndex":
  test "returns the font offset for a given index.":
    check getFontOffsetForIndex(FONT_DATA, 0) == 0

suite "scaleForPixelHeight":
  test "returns the scale to use for a given pixel height.":
    let font = initFont(FONT_DATA).get()
    check font.scaleForPixelHeight(22) =~ 0.00916

suite "getGlyphKernAdvance":
  test "returns the kerning advance to use for a given glyph.":
    let font = initFont(FONT_DATA).get()

    check font.getGlyphKernAdvance(
      font.findGlyphIndex('k'.cint), 
      font.findGlyphIndex('e'.cint)
    ) == -20

    check font.getGlyphKernAdvance(
      font.findGlyphIndex('z'.cint), 
      font.findGlyphIndex('o'.cint)
    ) == -16

    check font.getGlyphKernAdvance(
      font.findGlyphIndex('a'.cint), 
      font.findGlyphIndex('b'.cint)
    ) == 0

suite "getGlyphHMetrics":
  test "returns HMetrics for a given glyph index.":
    let font = initFont(FONT_DATA).get()

    check font.getGlyphHMetrics(
      font.findGlyphIndex('a'.cint),
    ) == HMetrics(advanceWidth: 1114, leftSideBearing: 109)

    check font.getGlyphHMetrics(
      font.findGlyphIndex('z'.cint),
    ) == HMetrics(advanceWidth: 1015, leftSideBearing: 88)

suite "isGlyphEmpty":
  test "returns true for glyphs that do not contain draw data.":
    let 
      font = initFont(FONT_DATA).get()
      glyph = font.findGlyphIndex('a'.cint)

    check font.isGlyphEmpty(glyph) == false

  test "returns false for glyphs that contain draw data.":
    let 
      font = initFont(FONT_DATA).get()
      emptyGlyph = font.findGlyphIndex(0.cint)

    check font.isGlyphEmpty(emptyGlyph) == true

suite "getFontVMetrics":
  test "returns VMetrics for a given font.":
    let font = initFont(FONT_DATA).get()
    check font.getFontVMetrics() == VMetrics(ascent: 1900, descent: -500, lineGap: 0)

suite "findGlyphIndex":
  test "returns a glyph index for a given unicode codepoint.":
    let font = initFont(FONT_DATA).get()
    check font.findGlyphIndex('z'.cint) == 94

suite "getCodepointSDF":
  test "creates an SDF image for a given codepoint.":
    let 
      font = initFont(FONT_DATA).get()
      scale = font.scaleForPixelHeight(50)
      padding = 5
      onedge_value = 180.uint8
      pixel_dist_scale = (180/5.0)
      sdf = font.getCodepointSDF(
        scale,
        'c'.int,
        padding, 
        onedge_value, 
        pixel_dist_scale
      ).get()
      pixels = toSeq(sdf.pixels())

    check sdf.width.int == 30
    check sdf.height.int == 34
    check sdf.xoff.int == -4
    check sdf.yoff.int == -28
    check pixels.len == sdf.width.int * sdf.height.int + 1
    checkImage("test1.png", pixels, sdf.width.int, sdf.height.int)

suite "getGlyphSDF":
  test "creates an SDF image for a given glyph.":
    let 
      font = initFont(FONT_DATA).get()
      scale = font.scaleForPixelHeight(50)
      padding = 5
      onedge_value = 180.uint8
      pixel_dist_scale = (180/5.0)
      sdf = font.getGlyphSDF(
        scale,
        font.findGlyphIndex('a'.int),
        padding, 
        onedge_value, 
        pixel_dist_scale
      ).get()
      pixels = toSeq(sdf.pixels())

    check sdf.width.int == 29
    check sdf.height.int == 34
    check sdf.xoff.int == -3
    check sdf.yoff.int == -28
    check pixels.len == sdf.width.int * sdf.height.int + 1
    checkImage("test2.png", pixels, sdf.width.int, sdf.height.int)