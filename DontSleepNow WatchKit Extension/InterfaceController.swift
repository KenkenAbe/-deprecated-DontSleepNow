//
//  InterfaceController.swift
//  DontSleepNow WatchKit Extension
//
//  Created by KentaroAbe on 2017/09/29.
//  Copyright © 2017年 KentaroAbe. All rights reserved.
//

import WatchKit
import Foundation
import CoreMotion
import WatchConnectivity


class InterfaceController: WKInterfaceController, WKExtensionDelegate, WCSessionDelegate{
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    
    let motionManager = CMMotionManager()
    let queue = OperationQueue()

    @IBOutlet var xString: WKInterfaceLabel!
    @IBOutlet var yString: WKInterfaceLabel!
    @IBOutlet var zString: WKInterfaceLabel!

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        WKExtension.shared().delegate = self
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        print("起動しました")
        let fireDate = Date(timeIntervalSinceNow: 10.0)
        
        WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: fireDate,
                                                       userInfo: nil,
                                                       scheduledCompletion: { (error) in
                                                        if (error == nil) {
                                                            print("success!")
                                                            WKInterfaceDevice.current().play(WKHapticType.click)
                                                        }
        })
        
        if (WCSession.isSupported()) {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
        
    }
    
    func session(session: WCSession, didReceiveMessage message: [String: AnyObject], replyHandler: ([String: AnyObject]) -> Void) {
        guard let parentMessage = message["fromParent"] as? String else { return }
        // Watchのラベルにテキストを表示（Helloと表示される）
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        
    }
    
    
    
    @IBAction func Start() {
        if !motionManager.isDeviceMotionAvailable {
            print("Device Motion is not available.")
            return
        }
        motionManager.startDeviceMotionUpdates(to: queue) { (deviceMotion: CMDeviceMotion?, error: Error?) in
            if error != nil {
                print("Encountered error: \(error!)")
            }
            
            if deviceMotion != nil {
                print("gravity = \(deviceMotion!.gravity)")
                self.motionManager.stopDeviceMotionUpdates()

            }
        }
        
        
    }
    
    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        for task : WKRefreshBackgroundTask in backgroundTasks {
            // ...
            
            if task is WKApplicationRefreshBackgroundTask {
                // 何らかの処理を行う
                // ...
                
                
                
                // タスクを完了にする
                task.setTaskCompleted()
            }
            
            // ...
        }
    }
    
}
