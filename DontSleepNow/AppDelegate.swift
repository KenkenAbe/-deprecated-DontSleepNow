//
//  AppDelegate.swift
//  DontSleepNow
//
//  Created by KentaroAbe on 2017/09/29.
//  Copyright © 2017年 KentaroAbe. All rights reserved.
//

import UIKit
import Firebase
import NotificationCenter
import UserNotifications
import HealthKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let healthStore = HKHealthStore()


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        
        UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in if granted {print("通知許可")}
        }
        if #available(iOS 10.0, *){
            /** iOS10以上 **/
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .badge, .sound]) {granted, error in
                if error != nil {
                    // エラー時の処理
                    return
                }
                if granted {
                    // デバイストークンの要求
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        } else {
            /** iOS8以上iOS10未満 **/
            //通知のタイプを設定したsettingを用意
            let setting = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            //通知のタイプを設定
            application.registerUserNotificationSettings(setting)
            //DevoceTokenを要求
            UIApplication.shared.registerForRemoteNotifications()
        }
        application.registerForRemoteNotifications()
        
        return true
    }
    
    func applicationShouldRequestHealthAuthorization(application: UIApplication) {
        guard HKHealthStore.isHealthDataAvailable() else {
            return
        }
        
        let dataTypes = Set([HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!])
        healthStore.requestAuthorization(toShare: nil, read: dataTypes, completion: { (result, error) -> Void in
        })
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        print("通知を受信しました")
    }
    
    func application(_ application: UIApplication,performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult)-> Void) {
        
        print("実行されました")
        
        completionHandler(UIBackgroundFetchResult.newData)
    }


}

