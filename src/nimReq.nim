# This is just an example to get you started. A typical hybrid package
# uses this file as the main entry point of the application.

import puppy
import flatty
import nimServepkg/taskTable

import asyncdispatch

when isMainModule:
  while true:
    try: 
      echo "get task"
      let task = fetch("http://127.0.0.1:8080/")
      echo task 
      let dec = task.fromFlatty(Task)
      
      echo dec.req
      let body = Resp(taskId: dec.taskId, resp: "COMPLETE")
    
      echo "post response"
      
      let response = post(
          "http://127.0.0.1:8080",
          @[("Content-Type", "application/json")],
          toFlatty(body)
      )   
    except PuppyError:
      waitFor sleepAsync(1000)
      continue

   