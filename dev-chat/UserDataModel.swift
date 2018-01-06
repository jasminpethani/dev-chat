//
//  UserDataModel.swift
//  dev-chat
//
//  Created by jasmin on 31/12/17.
//  Copyright © 2017 jasmin. All rights reserved.
//

import Foundation
import SwiftyJSON
import Firebase

class UserDataModel {
     var username:String
     var email:String
     var dateOfBirth: Date?
     var password: String
     var userId:String
     var photoUrl: URL?
     
     var friends:[String]!
    
    init() {
        userId = ""
        username = ""
        password = ""
        email = ""
        friends = []
    }
    
     convenience init(dict: JSON) {
          self.init()
          self.username = dict["username"].stringValue
          self.email = dict["email"].stringValue
          self.friends = dict["friends"].arrayObject as? [String] ?? []
     }
     
     var isFriendOfCurrentUser: Bool {
          if !friends.isEmpty {
               if let userId = AuthenticateService.manager.currentUser?.uid {
                    return friends.contains(userId)
               }
          }
          return false
     }
     
     
     var isCurrentUser: Bool {
          if let userId = AuthenticateService.manager.currentUser?.uid {
               return self.userId == userId
          }
          return false
     }
    
    var dictionary: [String: Any]! {
        let df = DateFormatter()
        df.dateStyle =  .medium
        return [
            "userName": username,
            "email": email,
            "dateOfBirth": df.string(from: dateOfBirth!)
        ]
    }
}
