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

    convenience init(name: String, date: Date) {
        self.init()
        self.name = name
        self.date = date
    }
}
