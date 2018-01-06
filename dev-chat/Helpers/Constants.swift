// Firebase Roots

struct Roots {
     private init() {}
     
     static let friendRequests = "friendRequests"
     static let users = "users"
     static let chats = "chats"

     struct Users {
          static let email = "email"
          static let username = "username"
          static let photoUrl = "photoUrl"
          static let dateOfBirth = "dateOfBirth"
          static let incomingRequests  = "incomingRequests"
          static let outgoingRequests = "outgoingRequests"
     }
     
     struct Chat {
          static let messageType = "messageType"
          static let senderId = "senderId"
          static let receiverId = "receiverId"
          static let message = "message"
     }
     
     struct Requests {
          static let fromID = "from"
          static let toID = "to"
          static let status = "status"
     }
}

