# This is just an example to get you started. A typical hybrid package
# uses this file as the main entry point of the application.

import puppy
import flatty
import nimServepkg/taskTable

when isMainModule:
  while true:
    let task = fetch("http://127.0.0.1:8080")
    echo task 
    let dec = task.fromFlatty(Task)
    
    echo task.req
    let body = Resp(taskId: task.taskId, resp: "Hello World")
    
    let response = post(
        "http://127.0.0.1:8080",
        @[("Content-Type", "application/json")],
        toFlatty(body)
    )

    echo response.code
    echo response.headers
    echo response.body.len