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
    @objc dynamic var profileImage: Data?
    var taskType: List<TaskType> = List<TaskType>()
    
    convenience init(firstName: String, lastName: String, middleName: String, profileImage: Data?) {
        self.init()
        self.firstName = firstName
        self.lastName = lastName
        self.middleName = middleName
        self.profileImage = profileImage
    }
}

var person: Person {
    do {
        if realm.objects(Person.self).count == 0 {
            try realm.write {
                let newPerson: Person = Person(firstName: "Tuyen", lastName: "Le", middleName: "Dinh", profileImage: nil)
                realm.add(newPerson)
            }
        }
    } catch let error {
        print("login error: ", error.localizedDescription)
    }
    return realm.objects(Person.self).first! // TODO: will not actually grab first and need to check against login authentication
}
