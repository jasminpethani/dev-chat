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


enum TypeError: Error {
     case snapNotAvail
}


final class FireDatabaseService {
     static  let manager = FireDatabaseService()
     internal let db = Database.database().reference()
     
     private init() {}
    
     var currentUser: Firebase.User? {
          return Auth.auth().currentUser
     }
}
 

extension FireDatabaseService {
     
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
     
     func fetchCurrentUser() -> Promise<UserDataModel> {
          return Promise(resolvers: { (accept, reject) in
               guard let fromUserId = FireDatabaseService.manager.currentUser?.uid else { return }
               self.db.child(Roots.users).child(fromUserId).observeSingleEvent(of: .value, with: { (snapshot) in
                    if let dict = snapshot.value as? [String: Any], snapshot.exists() {
                         accept( UserDataModel(dict: JSON(dict)) )
                    } else {
                         reject(TypeError.snapNotAvail)
                    }
               })
          })
     }
}


// Friend Request management

extension FireDatabaseService {
     
     enum RequestStatus: Int {
          case received = 0
          case sent
          case done
     }
     
     private func observeFriendRequest(request: FriendRequest) {
           db.child(Roots.friendRequests).observeSingleEvent(of: .childAdded, with: { [unowned self] (snapshot) in
               let ref = self.db.child(Roots.users)
                    ref.child("\(request.toUser)/" + Roots.Users.incomingRequests).setValue([snapshot.key])
                    ref.child("\(request.fromUser)/" + Roots.Users.outgoingRequests).setValue([snapshot.key])
          })
     }
     
     func saveFriendRequest(request: FriendRequest) {
          db.child(Roots.friendRequests).childByAutoId().setValue(request.dictionary())
          observeFriendRequest(request: request)
     }
     
     // TODO: fetch all requests of currentUser's incoming/outgoing objects
     
     func fetchRequests(requestIds: [String]) {
          
     }
     
     // What requests received and what're sent by current users
     func fetchFriendRequests(status: FireDatabaseService.RequestStatus = .received) -> Promise<[FriendRequest]> {
          return Promise(resolvers: { (accept, reject) in
               guard let fromUserId = FireDatabaseService.manager.currentUser?.uid else { return }
               let ref = db.child(Roots.friendRequests)
               if case .received = status {
                    ref.queryOrdered(byChild: Roots.Requests.toID).queryEqual(toValue: fromUserId)
               } else if case .sent = status {
                    ref.queryOrdered(byChild: Roots.Requests.fromID).queryEqual(toValue: fromUserId)
               }
               ref.queryOrdered(byChild: Roots.Requests.status).queryEqual(toValue: status.rawValue)
                    .observeSingleEvent(of: .value, with: { (snapshot) in
                         if snapshot.exists() {
                              var friends = [FriendRequest]()
                              for s in snapshot.children where snapshot.hasChildren() {
                                   let snap = s as! DataSnapshot
                                   let dict  = JSON(snap.value as! [String:Any])
                                   let status = RequestStatus(rawValue: dict[Roots.Requests.status].intValue)!
                                   let f = FriendRequest(toUserId: dict[Roots.Requests.toID].stringValue, status: status)
                                   friends.append(f)
                              }
                              accept(friends)
                         } else {
                              reject(TypeError.snapNotAvail)
                         }
                    })
          })
     }
}


// Fetching users managing

extension FireDatabaseService {
     
     func fetchAllUser() -> Promise<[UserDataModel]> {
          return Promise(resolvers: { (success, reject) in
               db.child(Roots.users).observeSingleEvent(of: .value) { (snapshot) in
                    if snapshot.exists() && snapshot.hasChildren() {
                         let users = snapshot.children.map({ (s) -> UserDataModel in
                              let snap = s as! DataSnapshot
                              let json = JSON(snap.value as! [String: Any])
                              let user =  UserDataModel(dict: json)
                              user.userId = snap.key
                              return user
                         })
                         
                         success(users)
                    } else {
                         reject("Reject" as! Error)
                    }
               }
          })
     }
     
     func uploadProfilePicture(fileUrl: URL, completion: @escaping (URL?) -> Void) {
          guard let userId = FireDatabaseService.manager.currentUser?.uid else { return }
          
          let meta = StorageMetadata()
          meta.contentType = "image/png"
          
          let storage = Storage.storage().reference(forURL: "profileImages")
          let uploadTask = storage.child("\(userId)/profile.png").putFile(from: fileUrl, metadata: meta) { (meta, error) in
               if error == nil {
                    completion(meta?.downloadURL())
               } else {
                    debugPrint("Error: no uploaded file \(error!.localizedDescription)")
               }
          }
          
          uploadTask.resume()
     }
     
     func downloadProfilePicture() -> Promise<URL?> {
          return Promise(resolvers: { (success, reject) in
               guard let userId = FireDatabaseService.manager.currentUser?.uid else { return }
               let storage = Storage.storage().reference(forURL: "profileImages")
               storage.child("\(userId)/profile.png").downloadURL { (url, error) in
                    if error == nil {
                         success(url)
                    }else {
                         reject(error!)
                    }
               }
          })
     }
}



