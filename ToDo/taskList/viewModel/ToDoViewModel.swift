//
//  taskListViewModel.swift
//  ToDo
//
//  Created by Tuyen Le on 23.04.19.
//  Copyright © 2019 Tuyen Le. All rights reserved.
//

import Foundation

class ToDoViewModel {
    private let taskType: TaskType
    
    init(taskType: Type) {
        self.taskType = person.taskType.filter { $0.type == taskType }.first!
    }
    
    /// number of tasks
    var tasksCount: Int {
        return taskType.tasks.count
    }
    
    /// task completed percentage
    var tasksCompletedPercentage: Int {
        return taskType.percentage
    }
    
    var tasks: [(String, [String])] {
        var tasks: [String: [String]] = [:]

        if taskType.tasks.count == 0 {
            return [(String, [String])]()
        }
        
        var initialDate: String = dateString(date: taskType.tasks.first!.date!)
        
        for task in taskType.tasks {
            let taskDate: String = dateString(date: task.date!)
            if taskDate != initialDate {
                initialDate = taskDate
            }
            
            if tasks[taskDate] == nil {
                tasks[taskDate] = [String]()
            }
            tasks[taskDate]!.append(task.name!)
        }
        
        return tasks.sorted(by: { $0.key < $1.key })
    }
    
    /// delete tasks
    func deleteTask(taskNameToDelete: String, taskDateToDelete: String) {
        let dateToDelete: DateComponents = Calendar.current.dateComponents([.year, .month, .day], from: date(date: taskDateToDelete)!)
        
        for (index, task) in taskType.tasks.enumerated() {
            let taskDate: DateComponents = Calendar.current.dateComponents([.year, .month, .day], from: task.date!)
            if task.name! == taskNameToDelete
                && taskDate.day! == dateToDelete.day!
                && taskDate.month! == dateToDelete.month!
                && taskDate.year! == dateToDelete.year! {
                taskType.tasks.remove(at: index)
                taskType.numOfCompletedTask += 1
                break
            }
        }
    }
    
    /// reset completed task
    func resetCompletedTask() {
        taskType.numOfCompletedTask = 0
    }
    
    /// format mm/dd/yyyy
    func dateString(date: Date) -> String {
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.string(from: date)
    }
    
    /// format mm/dd/yyyy
    func date(date: String) -> Date? {
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.date(from: date)
    }
}


//func dateString(date: Date) -> String {
//    let formatter: DateFormatter = DateFormatter()
//    formatter.dateFormat = "MM/dd/yyyy"
//    return formatter.string(from: date)
//}
//
//
//func date(date: String) -> Date? {
//    let formatter: DateFormatter = DateFormatter()
//    formatter.dateFormat = "MM/dd/yyyy"
//    return formatter.date(from: date)
//}
//
//func getTasksCount(type: Type) -> Int {
//    let taskType = person.taskType.filter { $0.type == type }
//    return taskType.first!.tasks.count
//}
//
//func getTasksCompletedPercentage(type: Type) -> Int {
//    let taskType = person.taskType.filter { $0.type == type }
//    return taskType.first!.percentage
//}
//
//func resetCompletedTask(type: Type) {
//    let taskType = person.taskType.filter { $0.type == type }
//    taskType.first!.numOfCompletedTask = 0
//}
//
//
//func getTasks(type: Type) -> [(String, [String])] {
//    var tasks: [String: [String]] = [:]
//
//    let taskType = person.taskType.filter { $0.type == type }
//
//    if taskType.count == 0 || taskType.first?.tasks.count == 0 {
//        return [(String, [String])]()
//    }
//
//    var initialDate: String = dateString(date: taskType.first!.tasks.first!.date!)
//
//    for task in taskType.first!.tasks {
//        let taskDate: String = dateString(date: task.date!)
//        if taskDate != initialDate {
//            initialDate = taskDate
//        }
//
//        if tasks[taskDate] == nil {
//            tasks[taskDate] = [String]()
//        }
//        tasks[taskDate]!.append(task.name!)
//    }
//
//    return tasks.sorted(by: { $0.key < $1.key })
//}
//
//func deleteTask(type: Type, taskNameToDelete: String, taskDateToDelete: String) {
//    let taskType = person.taskType.filter { $0.type == type }
//    let dateToDelete: DateComponents = Calendar.current.dateComponents([.year, .month, .day], from: date(date: taskDateToDelete)!)
//
//    for (index, task) in taskType.first!.tasks.enumerated() {
//        let taskDate: DateComponents = Calendar.current.dateComponents([.year, .month, .day], from: task.date!)
//        if task.name! == taskNameToDelete
//            && taskDate.day! == dateToDelete.day!
//            && taskDate.month! == dateToDelete.month!
//            && taskDate.year! == dateToDelete.year! {
//            taskType.first?.tasks.remove(at: index)
//            taskType.first?.numOfCompletedTask += 1
//            break
//        }
//    }
//}
