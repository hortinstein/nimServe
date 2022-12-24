
import asyncdispatch, tables
import std/tables
import sharedtables
import std/oids
import std/strutils

type 
  Task* = object
    taskId*: string
    taskNum*: int
    retrieved*: bool
    complete*: bool
    req*: string
    resp*: string

type
  Resp* = object
    taskId*: string
    resp*: string

# To use the async version of the function, you will need to
# wrap it in a call to runAsync

proc newTask*(taskNum: int, req: string): Task =
  let id = $(genOid())
  Task(taskId:id , taskNum: taskNum, complete: false, req: req, resp: "")

type
  TaskTable* = ref object
    tasks*: Table[string, Task]

proc getUnsentTask*(taskTable: TaskTable): string =
  #iterate through tasks and return the first one that has not been sent
  for taskId in taskTable.tasks.keys:
    if not taskTable.tasks[taskId].retrieved:
      taskTable.tasks[taskId].retrieved = true
      return taskId
  return ""

proc newTaskTable*(): TaskTable =
  return TaskTable(tasks: initTable[string, Task]())

proc addTask*(taskTable: TaskTable, task: Task) =
  var id = task.taskId
  taskTable.tasks[id] = task

proc addTaskResp*(taskTable: TaskTable, resp: Resp) =
  try:
    taskTable.tasks[resp.taskId].resp = resp.resp
  except KeyError: #TODO better error handling
    echo "KeyError adding resp"

proc rmTask*(taskTable: TaskTable, taskId: string) =
  taskTable.tasks.del(taskId)

proc getTaskResp*(taskTable: TaskTable, taskId: string): Future[string] {.async.} =
  var id = taskId
  try:
    while (taskTable.tasks[id].resp == ""):
      await sleepAsync(1000)
  except KeyError: #TODO better error handling
    echo " KeyError gettting resp"
    return ""
  return taskTable.tasks[id].resp