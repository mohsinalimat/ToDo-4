//
//  ToDoList.swift
//  ToDo
//
//  Created by Tuyen Le on 24.03.19.
//  Copyright © 2019 Tuyen Le. All rights reserved.
//


import RealmSwift

enum Type: String {
    case Personal
    case Work
    case Home
    case Grocery
    case Travel
    case Other
}

let realm = try! Realm()

final class TaskType: Object {
    @objc private dynamic var typeEnum: String = Type.Personal.rawValue
    @objc dynamic var numOfCompletedTask: Int = 0
    @objc dynamic var totalTask: Int {
        get {
            if tasks.count == 0 {
                return 0
            }
            return tasks.count + numOfCompletedTask
        }
    }
    
    @objc dynamic var percentage: Int {
        get {
            if totalTask == 0 {
                return 100
            }
            return Int(CGFloat(numOfCompletedTask) / CGFloat(totalTask) * 100)
        }
    }
    
    var tasks: List<Task> = List<Task>()
    
    var type: Type {
        get {
            return Type(rawValue: typeEnum)!
        }
        set {
            typeEnum = newValue.rawValue
        }
    }

    convenience init(type: Type) {
        self.init()
        self.type = type
    }
}

final class Task: Object {
    @objc dynamic var name: String?
    @objc dynamic var date: Date?
    @objc dynamic var id: String?

    convenience init(name: String, date: Date, id: String) {
        self.init()
        self.name = name
        self.date = date
        self.id = id
    }
}
