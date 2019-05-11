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
    
    var recentlyAddedTask: Task? {
        return taskType.tasks.last
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
    
    /// reset completed task to 0
    func resetCompletedTask() {
        taskType.numOfCompletedTask = 0
    }
    
    /// format mm/dd/yyyy in string
    func dateString(date: Date) -> String {
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.string(from: date)
    }
    
    /// format mm/dd/yyyy in date component
    func date(date: String) -> Date? {
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.date(from: date)
    }
}
