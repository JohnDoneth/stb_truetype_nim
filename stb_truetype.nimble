# Package

version       = "0.1.0"
author        = "JohnDoneth"
description   = "Nim wrapper for stb_truetype"
license       = "MIT"
srcDir        = "src"


# Dependencies

requires "nim >= 1.4.8"

when not defined(release):
    requires "nimPNG >= 0.3.1"
