# Package

version       = "0.1.0"
author        = "Alex"
description   = "A new awesome nimble package"
license       = "MIT"
srcDir        = "src"
installExt    = @["nim"]
bin           = @["nimServe"]


# Dependencies

requires "nim >= 1.6.8"
requires "urlly"
requires "zippy"