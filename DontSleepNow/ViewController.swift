//
//  ViewController.swift
//  DontSleepNow
//
//  Created by KentaroAbe on 2017/09/29.
//  Copyright © 2017年 KentaroAbe. All rights reserved.
//

import UIKit
import WatchConnectivity
import UserNotifications
import NotificationCenter
import HealthKit
import AudioToolbox
import CoreMotion

class ViewController: UIViewController, WCSessionDelegate, UNUserNotificationCenterDelegate {
    
    var currentX = 0.0
    var currentY = 0.0
    
    let motionManager = CMMotionManager()
    let queue = OperationQueue()
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void)
    {
        // 処理
        let shori = message["action"] as! String
        
        print(shori)
        
        if (shori == "start"){

        }
        
        
    }
   
    @IBAction func Button(_ sender: Any) {
        UIScreen.main.brightness = CGFloat(0.0);//0~1
        for i in 1...200{
            /*if (WCSession.default.isReachable) {
                let message = ["action" : "catch"]
                WCSession.default.sendMessage(message, replyHandler: { (replyDict) -> Void in
                    print(replyDict)
                    let reply1 = replyDict["Result1"] as! Double
                    let reply2 = replyDict["Result2"] as! Double
                    if (i <= 2){
                        self.currentX = reply1
                        self.currentY = reply2
                    }else{
                        let Val1 = reply1
                        let Val2 = reply2
                        
                        print("\(Val1)/\(Val2)")
                        
                        if (abs(Val1)-abs(self.currentX) <= 0.05 && abs(Val2)-abs(self.currentY) <= 0.05){
                            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                            if (WCSession.default.isReachable) {
                                let message = ["action" : "Alert"]
                                WCSession.default.sendMessage(message, replyHandler: { (replyDict) -> Void in
                                    print(replyDict)
                                    
                                }, errorHandler: { (error) -> Void in
                                    print(error)
                                }
                                    
                                )}
                        }
                    }
                    
                }, errorHandler: { (error) -> Void in
                    print(error)
                }
                    
                )}else*/
                if !motionManager.isDeviceMotionAvailable {
                    print("Device Motion is not available.")
                    return
                }
                
                motionManager.startDeviceMotionUpdates(to: queue) { (deviceMotion: CMDeviceMotion?, error: Error?) in
                    if error != nil {
                        print("Encountered error: \(error!)")
                    }
                    
                    if deviceMotion != nil {
                        print("attitude = \(deviceMotion!.attitude)")
                        print("gravity = \(deviceMotion!.gravity)")
                        print("rotationRate = \(deviceMotion!.rotationRate)")
                        print("userAcceleration = \(deviceMotion!.userAcceleration)")
                        
                        let pointX = deviceMotion?.gravity.x
                        let pointY = deviceMotion?.gravity.y
                        
                        if (i <= 2){
                            self.currentX = (deviceMotion?.gravity.x)!
                            self.currentY = (deviceMotion?.gravity.y)!
                        }else{
                            let Val1 = deviceMotion?.gravity.x
                            let Val2 = deviceMotion?.gravity.y
                            
                            print("\(Val1)/\(Val2)")
                            
                            if (abs(Val1!)-abs(self.currentX) <= 0.05 && abs(Val2!)-abs(self.currentY) <= 0.05){
                                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                                
                            }
                        }
                        self.motionManager.stopDeviceMotionUpdates()
                    }
                }
            
           // }
            sleep(UInt32(15))
            
        }
        UIScreen.main.brightness = CGFloat(1.0);//0~1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if (WCSession.isSupported()) {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
        
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

