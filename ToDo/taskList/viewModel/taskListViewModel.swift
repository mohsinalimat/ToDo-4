//
//  taskListViewModel.swift
//  ToDo
//
//  Created by Tuyen Le on 23.04.19.
//  Copyright © 2019 Tuyen Le. All rights reserved.
//

import Foundation

/// format mm/dd/yyyy
func dateString(date: Date) -> String {
    let formatter: DateFormatter = DateFormatter()
    formatter.dateFormat = "MM/dd/yyyy"
    return formatter.string(from: date)
}

func date(date: String) -> Date? {
    let formatter: DateFormatter = DateFormatter()
    formatter.dateFormat = "MM/dd/yyyy"
    return formatter.date(from: date)
}


func getTasks(type: Type) -> [(String, [String])] {
    var tasks: [String: [String]] = [:]

    let taskType = person.taskType.filter { $0.type == type }

    if taskType.count == 0 || taskType.first?.tasks.count == 0 {
        return [(String, [String])]()
    }

    var initialDate: String = dateString(date: taskType.first!.tasks.first!.date!)

    for task in taskType.first!.tasks {
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

func deleteTask(type: Type, taskNameToDelete: String, taskDateToDelete: String) {
    let taskType = person.taskType.filter { $0.type == type }
    let dateToDelete: DateComponents = Calendar.current.dateComponents([.year, .month, .day], from: date(date: taskDateToDelete)!)

    for (index, task) in taskType.first!.tasks.enumerated() {
        let taskDate: DateComponents = Calendar.current.dateComponents([.year, .month, .day], from: task.date!)
        if task.name! == taskNameToDelete
            && taskDate.day! == dateToDelete.day!
            && taskDate.month! == dateToDelete.month!
            && taskDate.year! == dateToDelete.year! {
            taskType.first?.tasks.remove(at: index)
            break
        }
    }
}
