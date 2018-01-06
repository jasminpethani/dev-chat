//
//  UserService.swift
//  dev-chat
//
//  Created by jasmin on 06/01/18.
//  Copyright © 2018 jasmin. All rights reserved.
//

import Foundation
import Firebase
//import PromiseKit
import SwiftyJSON

enum RequestStatus: Int {
     case received = 0
     case sent
     case done
}

class UserService {
     static let manager = UserService()
     private let db = Database.database().reference()
     private init() {}
     
     func updateRequest(to: String, status: RequestStatus) {
          if let from = AuthenticateService.manager.currentUser?.uid {
               db.child("friendRequests").observeSingleEvent(of: .childAdded, with: {[unowned self] (snapshot) in
                    self.db.child("users").child("\(from)/requests").setValue([snapshot.key])
               })
               let dict = ["from" : from, "to": to, "status": status.rawValue] as [String : Any]
               db.child("friendRequests").childByAutoId().setValue(dict)
          }
     }
}

extension UserService {
     
     func fetchAllUser(completion: @escaping ([UserDataModel]) -> Void) {
          db.child("users").observeSingleEvent(of: .value) { (snapshot) in
               if snapshot.exists() && snapshot.hasChildren() {
                    let users = snapshot.children.map({ (s) -> UserDataModel in
                         let snap = s as! DataSnapshot
                         let json = JSON(snap.value as! [String: Any])
                         let user =  UserDataModel(dict: json)
                         user.userId = snap.key
                         return user
                    })
                    
                    completion(users)
               }
          }
     }
     
     func uploadProfilePicture(fileUrl: URL, completion: @escaping (URL?) -> Void) {
          guard let userId = AuthenticateService.manager.currentUser?.uid else { return }
          
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
     
     func downloadProfilePicture(completion: @escaping (URL?) -> Void) {
          guard let userId = AuthenticateService.manager.currentUser?.uid else { return }
          let storage = Storage.storage().reference(forURL: "profileImages")
          storage.child("\(userId)/profile.png").downloadURL { (url, error) in
               if error == nil {
                    completion(url)
               }else {
                    debugPrint(error!.localizedDescription)
               }
          }
     }
}
