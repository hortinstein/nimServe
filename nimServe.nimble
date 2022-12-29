# Package

version       = "0.1.0"
author        = "Alex"
description   = "A new awesome nimble package"
license       = "MIT"
srcDir        = "src"
installExt    = @["nim"]
bin           = @["nimReq"]


# Dependencies

requires "puppy"
requires "nim >= 1.6.8"
requires "urlly"
requires "flatty"
requires "zippy"
requires "jester"
