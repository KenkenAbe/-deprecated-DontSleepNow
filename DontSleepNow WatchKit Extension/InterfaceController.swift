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
import HealthKit


class InterfaceController: WKInterfaceController, WKExtensionDelegate, WCSessionDelegate{
    
    fileprivate var wcBackgroundTasks: [WKWatchConnectivityRefreshBackgroundTask] = []
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    let healthStore: HKHealthStore = HKHealthStore()
    
    
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
    let heartRateUnit = HKUnit(from: "count/min")
    // HealthStoreへのクエリ
    var heartRateQuery: HKQuery?
    
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        print("起動しました")
        
        
        if (WCSession.isSupported()) {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
        
        WKExtension.shared().delegate = self
        
        guard HKHealthStore.isHealthDataAvailable() else {
            return
        }
        
        // アクセス許可をユーザに求める
       
        
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
    
    func Get() {
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
            }
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        
        print("アクティブではなくなりました")
        
        
        
    }
    
    
    @IBAction func Start() {
        if (WCSession.default.isReachable) {
            let message = ["action" : "start"]
            WCSession.default.sendMessage(message, replyHandler: { (replyDict) -> Void in
                print(replyDict)
            }, errorHandler: { (error) -> Void in
                print(error)
            }
                
            )}

    }
    let heartRateType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
    
    private func createStreamingQuery() -> HKQuery {
        let predicate = HKQuery.predicateForSamples(withStart: Date(), end: nil)
        
        // HKAnchoredObjectQueryだと他のアプリケーションによる更新を検知することができる
        let query = HKAnchoredObjectQuery(type: heartRateType, predicate: predicate, anchor: nil, limit: Int(HKObjectQueryNoLimit)) { (query, samples, deletedObjects, anchor, error) -> Void in
            self.addSamples(samples: samples)
    
        }
        // Handler登録、上でやってるからいらないかも...
        query.updateHandler = { (query, samples, deletedObjects, anchor, error) -> Void in
            self.addSamples(samples: samples)
        }
        
        return query
    }
    
    private func addSamples(samples: [HKSample]?) {
        guard let samples = samples as? [HKQuantitySample] else {
            return
        }
        guard let quantity = samples.last?.quantity else {
            return
        }
        print("\(quantity.doubleValue(for: heartRateUnit))")
    }
    
    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        for task in backgroundTasks {
            if let task = task as? WKWatchConnectivityRefreshBackgroundTask {
                // タスクが完了するまで、WKWatchConnectivityRefreshBackgroundTask への参照を保持しておく
                // タスクの保持は開発者の責務 (WWDC 16 のセッション 218 で言及)
                self.wcBackgroundTasks.append(task)
            }
        }
    }
    
   
    
}
