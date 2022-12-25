import unittest
import tables
import nimServepkg/taskTable
import asyncdispatch, asynchttpserver, uri, urlly, zippy, flatty

proc serveTasks(tt: TaskTable) {.thread.} =
  proc cb(req: Request, tt: TaskTable) {.async.} =
    echo "got request ", $req
    case req.reqMethod
    of HttpGet:
      if req.url.path == "/":
        let taskId = getUnsentTask(tt)
        echo "sending taskId:",taskId
        if taskId != "":
          await req.respond(Http200, toFlatty(tt.tasks[taskId]))
        else:
          await req.respond(Http200, "")
        return
    of HttpPost:
      if req.url.path == "/":
        echo req.headers
        echo req.body
        let resp = req.body.fromFlatty(Resp)
        #echo resp.taskId
        return
    else:
      discard
    await req.respond(Http404, "Not found.")

  let server = newAsyncHttpServer()
  
  waitFor server.serve(
    Port(8080), 
    proc (req: Request): Future[void] = cb(req, tt)
  )

suite "tests the creation of a task queue":
  var tt = newTaskTable()
  let t1 = newTask(1,"test1")
  let t2 = newTask(2,"test2")
  let t3 = newTask(3,"test3")

  var t: Thread[TaskTable]
  createThread[TaskTable](t,serveTasks, tt)

  setup:
    addTask(tt,t1)
    addTask(tt,t2)
    addTask(tt,t3)    
  # teardown:

  test "test task1":
    echo "test1"
    addTask(tt,t1)

  test "test task2":
    addTask(tt,t2)
  
  test "test task3":
    addTask(tt,t3)
  joinThread(t)
  echo "suite teardown: run once after the tests"
