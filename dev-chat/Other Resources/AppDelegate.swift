//
//  AppDelegate.swift
//  dev-chat
//
//  Created by jasmin on 30/12/17.
//  Copyright © 2017 jasmin. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

     var window: UIWindow?


     func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
          
          // Firebase setup
          FirebaseApp.configure()
          setApplicationRootController()
        
        
          return true
     }

     func applicationWillTerminate(_ application: UIApplication) {
         LocalDatabase.database.saveContext()
     }
    
    
    
    func setApplicationRootController() {
        if FireDatabaseService.manager.currentUser != nil {
            if let rootController = UIStoryboard(name: "Chat", bundle: nil).instantiateInitialViewController() {
                window?.rootViewController = rootController
            }
        } else {
            if let viewController_ = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() {
                window?.rootViewController = viewController_
            }
        }
    }
}

