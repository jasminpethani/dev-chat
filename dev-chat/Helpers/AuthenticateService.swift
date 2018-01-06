//
//  FirebaseDatabaseManager.swift
//  dev-chat
//
//  Created by jasmin on 31/12/17.
//  Copyright © 2017 jasmin. All rights reserved.
//

import Foundation
import Firebase
import PromiseKit
import SwiftyJSON


class AuthenticateService {
     static  let manager = AuthenticateService()
     private let db = Database.database().reference()
    
    
     private init() {}
    
     var currentUser: Firebase.User? {
          return Auth.auth().currentUser
     }
    
    func logOut() -> Promise<Bool> {
        return Promise<Bool>(resolvers: { (accept, reject) in
            do {
                try Auth.auth().signOut()
                accept(true)
            } catch {
                reject(error)
            }
        })
    }
    
}
 

extension AuthenticateService {
     
     func loginIntoFirebase(with username: String, password: String) -> Promise<Firebase.User> {
          return Promise(resolvers: { (accept, reject) in
               Auth.auth().signIn(withEmail: username, password: password) { (user, error) in
                    if error == nil {
                         accept(user!)
                    } else {
                         reject(error!)
                    }
               }
          })
     }
     
     func forgotPassword(email: String) -> Promise<Bool> {
          return Promise(resolvers: { (accept, reject) in
               Auth.auth().sendPasswordReset(withEmail: email) { (error) in
                    if error == nil {
                         accept(true)
                    } else {
                         reject(error!)
                    }
               }
          })
     }
     
    func registerUser(model: UserDataModel) -> Promise<Bool> {
          return Promise(resolvers: { (accept, reject) in
               Auth.auth().createUser(withEmail: model.email, password: model.password) { (user, error) in
                    if error == nil {
                        self.db.child("users/\(user!.uid)").setValue(model.dictionary)
                        let promise =  self.loginIntoFirebase(with: model.email, password: model.password)
                        
                        promise.then(execute: { (user) -> Void in
                            accept(true)
                        }).catch(execute: { (error) in
                            reject(error)
                        })
                    } else {
                        reject(error!)
                    }
               }
          })
     }
     
}
