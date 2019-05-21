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
    
    var tasks: [(String, [Task])] {
        var tasks: [String: [Task]] = [:]

        if taskType.tasks.count == 0 {
            return [(String, [Task])]()
        }
        
        var initialDate: String = dateString(date: taskType.tasks.first!.date!)
        
        for task in taskType.tasks {
            let taskDate: String = dateString(date: task.date!)
            if taskDate != initialDate {
                initialDate = taskDate
            }
            
            if tasks[taskDate] == nil {
                tasks[taskDate] = [Task]()
            }
            tasks[taskDate]!.append(task)
        }
        
        return tasks.sorted(by: { $0.key < $1.key })
    }
    
    /// save date
    func saveTimer(hour: Int, minute: Int) {
        do {
            try realm.write {
                var dateComponent = Calendar.current.dateComponents([.year, .month, .day], from: recentlyAddedTask!.date!)
                if hour == 24 {
                    dateComponent.setValue(0, for: .hour)
                } else {
                    dateComponent.setValue(hour, for: .hour)
                }

                dateComponent.setValue(minute, for: .minute)

                recentlyAddedTask?.date = Calendar(identifier: .gregorian).date(from: dateComponent)
            }
        } catch let error {
            print(error)
        }
    }
    
    /// save new task
    func saveTask(_ newTask: Task) {
        do {
            try realm.write {
                taskType.tasks.append(newTask)
            }
        } catch let error {
            print(error)
        }
    }
    
    /// delete tasks
    func deleteTask(_ taskToDelete: Task) {
        do {
            try realm.write {
                let taskNameToDelete: String = taskToDelete.name!
                let dateToDelete: DateComponents = Calendar.current.dateComponents([.year, .month, .day], from: taskToDelete.date!)
                
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
        } catch let error {
            print(error)
        }
    }
    
    /// reset completed task to 0
    func resetCompletedTask() {
        do {
            try realm.write {
                taskType.numOfCompletedTask = 0
            }
        } catch let error {
            print(error)
        }
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
