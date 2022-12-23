# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

import unittest

import nimServepkg/taskTable

import nimServepkg/taskTable
suite "description for this stuff":
  var tt = newTaskTable()
  var task1 = newTask(1,"task1")
  var task2 = newTask(2,"task2")
  var task3 = newTask(3,"task3")

  setup:
    #echo "run before each test"
    addTask(tt,task1)
    addTask(tt,task2)
    addTask(tt,task3)
  teardown:
    echo "run after each test"
    
  test "testing insert":
    echo tt