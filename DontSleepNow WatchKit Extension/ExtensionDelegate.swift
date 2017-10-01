//
//  ExtensionDelegate.swift
//  DontSleepNow WatchKit Extension
//
//  Created by KentaroAbe on 2017/09/29.
//  Copyright © 2017年 KentaroAbe. All rights reserved.
//

import WatchKit
import WatchConnectivity
import CoreMotion

class ExtensionDelegate: NSObject, WKExtensionDelegate,WCSessionDelegate {
    let motionManager = CMMotionManager()
    let queue = OperationQueue()
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void)
    {
        // 処理
        let shori = message["action"] as! String
        
        print(shori)
        if (shori == "catch"){
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
                    
                    let reply:Dictionary = ["Result1":pointX,"Result2":pointY]
                    
                    replyHandler(reply)
                }
            }
        }
        
        if (shori == "Alert"){
            WKInterfaceDevice.current().play(WKHapticType.failure)
            replyHandler(["Result":"OK"] as! [String : Any])
        }
        
        if (WCSession.default.isReachable) {
            let message = ["action" : "wait"]
            WCSession.default.sendMessage(message, replyHandler: { (replyDict) -> Void in
                
            }, errorHandler: { (error) -> Void in
                print(error)
            }
                
            )}
        
        
    }
    

    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
        
        if (WCSession.isSupported()) {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        // Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
        for task in backgroundTasks {
            // Use a switch statement to check the task type
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                // Be sure to complete the background task once you’re done.
                backgroundTask.setTaskCompletedWithSnapshot(false)
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                // Snapshot tasks have a unique completion call, make sure to set your expiration date
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                // Be sure to complete the connectivity task once you’re done.
                connectivityTask.setTaskCompletedWithSnapshot(false)
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                // Be sure to complete the URL session task once you’re done.
                urlSessionTask.setTaskCompletedWithSnapshot(false)
            default:
                // make sure to complete unhandled task types
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }

}
