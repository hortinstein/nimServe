
import asyncdispatch, tables
import std/tables
import sharedtables
import std/oids
import std/strutils

type 
  Task* = object
    taskId*: string
    taskNum*: int
    complete*: bool
    req*: string
    resp*: string

# To use the async version of the function, you will need to
# wrap it in a call to runAsync

proc newTask*(taskNum: int, req: string): Task =
  let id = $(genOid())
  Task(taskId:id , taskNum: taskNum, complete: false, req: req, resp: "")

type
  TaskTable* = object
    tasks*: SharedTable[string, Task]

proc newTaskTable*(): TaskTable =
  var table: SharedTable[string, Task]   
  init(table)
  return TaskTable(tasks: table)


proc addTask*(taskTable: var TaskTable, task: Task) =
  var id = task.taskId
  taskTable.tasks[id] = task

proc addTaskResp*(taskTable: var TaskTable, taskId: string, resp: string) =
  try:
    taskTable.tasks.mget(taskId).resp = resp
  except KeyError: #TODO better error handling
    echo "KeyError adding resp"

proc rmTask*(taskTable: var TaskTable, task: Task) =
  taskTable.tasks.del($task.taskId)

proc getTaskResp*(taskTable: var TaskTable, taskId: string): Future[string] {.async.} =
  var id = taskId
  try:
    while (taskTable.tasks.mget(id).resp == ""):
      await sleepAsync(1000)
  except KeyError: #TODO better error handling
    echo " KeyError gettting resp"
    return ""
  return taskTable.tasks.mget(id).resp