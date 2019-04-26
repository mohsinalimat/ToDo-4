//
//  Person.swift
//  ToDo
//
//  Created by Tuyen Le on 07.04.19.
//  Copyright © 2019 Tuyen Le. All rights reserved.
//

import RealmSwift

final class Person: Object {
    @objc dynamic var firstName: String?
    @objc dynamic var lastName: String?
    @objc dynamic var middleName: String?
    var taskType: List<TaskType> = List<TaskType>()
    
    convenience init(firstName: String, lastName: String, middleName: String) {
        self.init()
        self.firstName = firstName
        self.lastName = lastName
        self.middleName = middleName
    }
}

var person: Person {
    return realm.objects(Person.self).first! // TODO: will not actually grab first and need to check against login authentication
}
