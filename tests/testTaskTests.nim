import unittest
import tables
import nimServepkg/taskTable
import asyncdispatch, asynchttpserver, uri, urlly, zippy, flatty

proc serveTasks(tt: TaskTable, server: AsyncHttpServer) {.thread.} =
  proc cb(req: Request, tt: TaskTable,server: AsyncHttpServer) {.async.} =
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

  if server.shouldAcceptRequest():
    waitFor server.acceptRequest(proc (req: Request): Future[void] = cb(req, tt,server))

suite "tests the creation of a task queue":
  var tt = newTaskTable()
  let t1 = newTask(1,"test1")
  let t2 = newTask(2,"test2")
  let t3 = newTask(3,"test3")
  let server = newAsyncHttpServer()
  server.listen(Port(8080))
  
  # var t: Thread[TaskTable]
  # createThread[TaskTable](t,serveTasks, tt)

  setup:
    addTask(tt,t1)
    addTask(tt,t2)
    addTask(tt,t3)    
  # teardown:

  test "test task1":
    echo "test1"
    addTask(tt,t1)
    serveTasks(tt,server)

  test "test task2":
    addTask(tt,t2)
    serveTasks(tt,server)

  test "test task3":
    addTask(tt,t3)
    serveTasks(tt,server)

  # joinThread(t)
  echo "suite teardown: run once after the tests"
