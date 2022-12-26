import unittest
import tables
import nimServepkg/taskTable
import asyncdispatch, asynchttpserver, uri, urlly, zippy, flatty

proc serveTasks(tt: TaskTable, server: AsyncHttpServer) {.thread.} =
  # Define a nested proc that will handle incoming requests
  proc cb(req: Request, tt: TaskTable,server: AsyncHttpServer) {.async.} =
    # Use a case statement to handle different request methods
    case req.reqMethod
    # If the request method is an HTTP GET
    of HttpGet:
      # If the request URL path is "/"
      if req.url.path == "/":
        # Get the task ID for an unsent task
        let taskId = getUnsentTask(tt)
        # If a task was returned
        if taskId != "":
          # Send the task data in the response
          echo "sending taskId:",taskId
          await req.respond(Http200, toFlatty(tt.tasks[taskId]))
          # Mark the task as retrieved
          assert (tt.tasks[taskId].retrieved == true) 
        # If no tasks are available
        else:
          echo "no tasks rdy"
          # Send an empty response
          await req.respond(Http200, "")
        return
    # If the request method is an HTTP POST
    of HttpPost:
      # If the request URL path is "/"
      if req.url.path == "/":
        # Get the response data from the request body
        let resp = req.body.fromFlatty(Resp)
        echo "resp: ", resp
        # Add the response to the task table
        addTaskResp(tt, resp)
        echo tt.tasks
        # Send an empty response
        await req.respond(Http200, "")
        return
    # If the request method is neither an HTTP GET nor an HTTP POST
    else:
      # Discard the request
      discard
    # Send an HTTP 404 response with the message "Not found."
    await req.respond(Http404, "Not found.")

  # If the server is ready to accept requests
  if server.shouldAcceptRequest():
    # Wait for the server to accept a request and pass it to the cb proc
    waitFor server.acceptRequest(
      proc (req: Request): Future[void] = cb(req, tt,server)
    )
    # Wait for the server to accept another request and pass it to the cb proc
    waitFor server.acceptRequest(
      proc (req: Request): Future[void] = cb(req, tt,server)
    )
    

suite "test the retrieval of tasks and response adding":
  var tt = newTaskTable()
  let t1 = newTask(1,"test1")
  let t2 = newTask(2,"test2")
  
  test "getting an unsent task":
    addTask(tt,t1)
    let id = getUnsentTask(tt)
    assert (id == t1.taskId)
    assert (true == tt.tasks[t1.taskId].retrieved)
  test "testing what happens when there are no unsent tasks":
    let id = getUnsentTask(tt)
    assert (id == "")    
  test "testing adding a response":
    let r1 = Resp(taskId: t1.taskId, resp: "resp1")
    addTaskResp(tt, r1)
    assert (tt.tasks[t1.taskId].resp == "resp1")
    let f = waitFor getTaskResp(tt,r1.taskId)
    assert ( f == "resp1")
  test "testing adding another item to the tt":
    addTask(tt,t2)
    let id = getUnsentTask(tt)
    assert (id == t2.taskId)
 
suite "tests the creation of a task queue":
  var tt = newTaskTable()
  let t1 = newTask(1,"test1")
  let t2 = newTask(2,"test2")
  let t3 = newTask(3,"test3")
  let server = newAsyncHttpServer()
  server.listen(Port(8080))
  addTask(tt,t1)
  addTask(tt,t2)
  addTask(tt,t3)    

  # setup:
  # teardown:

  test "test task1":
    echo "test1"
    serveTasks(tt,server)

  test "test task2":
    serveTasks(tt,server)

  test "test task3":
    serveTasks(tt,server)

  # joinThread(t)
  echo "suite teardown: run once after the tests"
