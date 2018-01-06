//
//  FriendRequest.swift
//  dev-chat
//
//  Created by jasmin on 06/01/18.
//  Copyright © 2018 jasmin. All rights reserved.
//

import Foundation

final class FriendRequest {
     var fromUser: String
     var toUser : String
     var status: FireDatabaseService.RequestStatus
     
     init() {
          fromUser = FireDatabaseService.manager.currentUser?.uid ?? ""
          toUser = ""
          status = .sent
     }
     
     convenience init(toUserId: String, status: FireDatabaseService.RequestStatus) {
          self.init()
          self.toUser = toUserId
          self.status = status
     }
     
     func dictionary() -> [String: Any] {
          return [
               Roots.Requests.fromID: self.fromUser,
               Roots.Requests.toID: self.toUser,
               Roots.Requests.status: self.status.rawValue
          ]
     }
}
