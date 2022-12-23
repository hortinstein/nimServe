# This is just an example to get you started. A typical hybrid package
# uses this file as the main entry point of the application.

import nimServepkg/submodule
import nimServepkg/taskTable

import asyncdispatch, asynchttpserver, uri, urlly, zippy

proc serveTasks(taskTable: TaskTable) {.async.} =
  proc cb(req: Request) {.async.} =
    echo "got request ", $req
    case req.reqMethod
    of HttpGet:
      if req.url.path == "/":
        await req.respond(Http200, "ok")
        return
    of HttpPost:
      if req.url.path == "/":
        echo req.headers
        if req.headers["Content-Length"] == "":
          await req.respond(Http200, "missing content-length header")
        else:
          await req.respond(Http200, req.body)
        
          echo req.body
        return
    else:
      discard
    await req.respond(Http404, "Not found.")

  let server = newAsyncHttpServer()
  waitFor server.serve(Port(8080), cb)


when isMainModule:
  let tskTable = newTaskTable() 
  discard serveTasks(tskTable)
  echo(getWelcomeMessage())
