//
//  Brain.swift
//  NasaHackathon
//
//  Created by ev3rest on 5/30/20.
//  Copyright © 2020 ev3rest. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class Brain{
    var container: NSPersistentContainer!
    var people: [NSManagedObject] = []
    
    // *START: CoreData Stuff ----------
    
    func load(){
        //1
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "People")
        
        //3
        do {
            people = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func save(uuid: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
        else {
            return
        }
        // 1
        let managedContext = appDelegate.persistentContainer.viewContext
        managedContext.mergePolicy =  NSMergeByPropertyObjectTrumpMergePolicy
        // 2
        let entity = NSEntityDescription.entity(forEntityName: "People", in: managedContext)!
        let person = NSManagedObject(entity: entity, insertInto: managedContext)
        // 3
        person.setValue(uuid, forKeyPath: "uuid")
        // 4
        do {
            try managedContext.save()
            people.append(person)
        }
        catch let error as NSError
        {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
}
