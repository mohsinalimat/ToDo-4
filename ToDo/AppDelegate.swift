//
//  AppDelegate.swift
//  ToDo
//
//  Created by Tuyen Le on 26.03.19.
//  Copyright © 2019 Tuyen Le. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if !granted {
                print("authorization not granted")
            }
        }
        return true
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
        guard let homeController = (window?.rootViewController as? UINavigationController)?.topViewController as? HomeController else { return }
        let tasksToDo = homeController.totalTaskToDoToday
        
        if tasksToDo == 0 {
            homeController.taskReminderLabel.text = "Hello, \nThere are no more tasks left to do."
        } else {
            homeController.taskReminderLabel.text = "Hello, \nYou have \(tasksToDo) tasks to do today."
        }
        Network.getQuoteOfDay { quote in
            homeController.quoteLabel.text = quote
            if homeController.quoteLabel.superview == nil {
                homeController.view.addSubview(homeController.quoteLabel)
                homeController.quoteLabel.sizeToFit()
            }
        }
    }
}

