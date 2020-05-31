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
import Alamofire

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
    
    // *END: CoreData Stuff
    
    // *START: API Stuff ----------
    
    // Add your UUID to the DB
    func posthash(hash: String){
        var jsonresult = ""
        let rawdata = ["data": [hash]]
        let encoder = JSONEncoder()
        if let jsonData = try? encoder.encode(rawdata) {
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                jsonresult = jsonString
            }
        }
        let escapedjson = self.escape(string: jsonresult)
        let url = "http://dev.ev3.me:5000/insert_contacts?hashes=\(escapedjson)"
        AF.request(url,
                   method: .post,
                   parameters: [:],
                   encoding: URLEncoding(destination: .queryString)
        ).responseData{ response in
            debugPrint(response)
        }
    }
    func escape(string: String) -> String {
        let allowedCharacters = string.addingPercentEncoding(withAllowedCharacters: CharacterSet(charactersIn: ":=\"#%/<>?@\\^`{|}").inverted) ?? ""
        return allowedCharacters
    }
    
    @objc func checkhashes()-> Bool{
        load()
        var allpeople = [String]()
        var toreturn: Bool = false
        if people.count > 0{
            for x in people{
                allpeople.append(x.committedValues(forKeys: ["uuid"])["uuid"]! as! String)
            }
            var allpeople_string = ""
            for each in allpeople{
                if allpeople_string == ""{
                    allpeople_string = "\(each)"
                }
                else{
                    allpeople_string = "\(allpeople_string)\",\"\(each)"
                }
            }
            
            var jsonresult = ""
            let rawdata = ["data": [allpeople_string]]
            let encoder = JSONEncoder()
            if let jsonData = try? encoder.encode(rawdata) {
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    jsonresult = jsonString
                }
            }
            let escapedjson = self.escape(string: jsonresult)
            let url = "http://dev.ev3.me:5000/check_contacts?hashes=\(escapedjson)"
            print(url)
            AF.request(url,
                       method: .post,
                       parameters: [:],
                       encoding: URLEncoding(destination: .queryString)
            ).responseJSON{ response in
                switch response.result {
                case let .success(value):
                    let jsonData = value as! [String:Any]
                    if jsonData["response"] as! String != "No risk"{
                        toreturn = true
                    }
                case let .failure(error):
                    print(error)
                }
            }
        }
        return toreturn
    }
}


extension Dictionary {
    func percentEncoded() -> Data? {
        return map { key, value in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
        .data(using: .utf8)
    }
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="

        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}
