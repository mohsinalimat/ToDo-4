//
//  taskListViewModel.swift
//  ToDo
//
//  Created by Tuyen Le on 23.04.19.
//  Copyright © 2019 Tuyen Le. All rights reserved.
//

import Foundation


func getTasks(type: Type) -> [String: [String]] {
    var tasks: [String: [String]] = [:]

    let taskType = person.taskType.filter { $0.type == type }
    let formatter: DateFormatter = DateFormatter()
    formatter.dateFormat = "MM/dd/yyyy"
    
    if taskType.count == 0 || taskType.first?.tasks.count == 0 {
        return tasks
    }

    var initialDate: String = formatter.string(from: taskType.first!.tasks.first!.date!)

    for task in taskType.first!.tasks {
        let taskDate: String = formatter.string(from: task.date!)
        if taskDate != initialDate {
            initialDate = taskDate
        }

        if tasks[taskDate] == nil {
            tasks[taskDate] = [String]()
        }
        tasks[taskDate]!.append(task.name!)
    }
    
    return tasks
}

func sortTaskByDate(tasks: [String: [String]], task: Task) {
    // TODO: sort
}
