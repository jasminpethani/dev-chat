//
//  LocalDatabase.swift
//  dev-chat
//
//  Created by jasmin on 30/12/17.
//  Copyright © 2017 jasmin. All rights reserved.
//

import Foundation
import CoreData

class LocalDatabase {
     static let database = LocalDatabase()
     
     private init() {}
     
     lazy var persistentContainer: NSPersistentContainer = {
          let container = NSPersistentContainer(name: "dev_chat")
          container.loadPersistentStores(completionHandler: { (storeDescription, error) in
               if let error = error as NSError? {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
               }
          })
          return container
     }()
     
     func saveContext () {
          let context = persistentContainer.viewContext
          if context.hasChanges {
               do {
                    try context.save()
               } catch {
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
               }
          }
     }
     
}
