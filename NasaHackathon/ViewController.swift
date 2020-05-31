//
//  ViewController.swift
//  NasaHackathon
//
//  Created by ev3rest on 5/30/20.
//  Copyright © 2020 ev3rest. All rights reserved.
//

import UIKit
import Alamofire
import WebKit

class ViewController: UIViewController{
    @IBOutlet weak var thishashlabel: UILabel!
    @IBOutlet weak var hashlabel: UILabel!
    @IBOutlet weak var infectedbutton: UIButton!
    
    let connection = ConnectivityService()
    private var myuuid: String = ""
    
    weak var timer: Timer?
    weak var checktimer: Timer?
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
        checktimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(check), userInfo: nil, repeats: true)
        brain.checkhashes()
        connection.delegate = self
    }
    @IBAction func infectedhandler(_ sender: Any) {
        brain.posthash(hash: myuuid)
        let alert = UIAlertController(title: "Thanks!", message: "All the people that you contacted with in the past 14 days will be notified without disclosing your identity", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

        self.present(alert, animated: true)
    }
    
    @objc func update(){
        print("update triggered")
        connection.send(hashData: "\(myuuid)")
    }
    @objc func check(){
        print("check triggered")
        if brain.checkhashes(){
            print("Oops")
            let alert = UIAlertController(title: "Hey there!", message: "No need to panic, but we have received a report that one of the people you contacted with in the last 14 days has been infected. It doesn't mean that you are infected, but getting tested will be best!", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "Get tested", style: .cancel, handler: getTested))

            self.present(alert, animated: true)
        }
        else{
            print("We good")
        }
    }
    func getTested(action: UIAlertAction){
        UIApplication.shared.open(URL(string: "https://www.cdc.gov/coronavirus/2019-ncov/symptoms-testing/testing.html")!, options: [:], completionHandler: nil)
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
