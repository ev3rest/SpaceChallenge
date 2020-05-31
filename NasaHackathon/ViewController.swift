//
//  ViewController.swift
//  NasaHackathon
//
//  Created by ev3rest on 5/30/20.
//  Copyright © 2020 ev3rest. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController{
    @IBOutlet weak var thishashlabel: UILabel!
    @IBOutlet weak var hashlabel: UILabel!
    @IBOutlet weak var infectedbutton: UIButton!
    
    let connection = ConnectivityService()
    private var myuuid: String = ""
    
    weak var timer: Timer?
    let brain = Brain()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard
        if defaults.object(forKey: "myUUID") == nil{
            print("NEW")
            myuuid = UUID().uuidString
            defaults.set(myuuid, forKey: "myUUID")
        }
        else{
            print("OLD")
            myuuid = (defaults.object(forKey: "myUUID") as? String)!
        }
        thishashlabel.text = myuuid
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(update), userInfo: nil, repeats: true)
        connection.delegate = self
    }
    @IBAction func infectedhandler(_ sender: Any) {
        brain.posthash(hash: myuuid)
    }
    
    @objc func update(){
        print("update triggered")
        connection.send(hashData: "\(myuuid)")
    }
}

extension ViewController : HashServiceDelegate {

    func connectedDevicesChanged(manager: ConnectivityService, connectedDevices: [String]) {
        OperationQueue.main.addOperation {
            print("Connections: \(connectedDevices)")
        }
    }

    func hashChanged(manager: ConnectivityService, hashData: String) {
        OperationQueue.main.addOperation {
            print("Received \(hashData)")
            self.hashlabel.text = hashData
            self.brain.save(uuid: hashData)
            self.brain.load()
        }
    }

}
