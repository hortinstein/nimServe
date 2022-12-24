# This is just an example to get you started. A typical hybrid package
# uses this file as the main entry point of the application.

import puppy

when isMainModule:
  while true:
    echo fetch("http://127.0.0.1:8080")
    let body = "{\"json\":true}"

    let response = post(
        "http://127.0.0.1:8080",
        @[("Content-Type", "application/json")],
        body
    )
    echo response.code
    echo response.headers
    echo response.body.len