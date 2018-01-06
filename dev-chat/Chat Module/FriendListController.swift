//
//  FriendListController.swift
//  dev-chat
//
//  Created by jasmin on 31/12/17.
//  Copyright © 2017 jasmin. All rights reserved.
//

import UIKit

class FriendListController: UIViewController {
    
    // TODO: list of friends and unfriends list
    // TODO: with pagination things upto 10 to 20 users
    
    @IBOutlet weak var segment: UISegmentedControl!
    
    @IBOutlet weak var friendsTableView: UITableView!
    
    fileprivate var users: [UserDataModel] = []
    fileprivate var otherUsers = [UserDataModel]()
    fileprivate var friends = [UserDataModel]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
     
        fetchAllServerUsers()
     
        friendsTableView.separatorStyle = .none
        friendsTableView.estimatedRowHeight = 80
     
        segment.selectedSegmentIndex = 0
        segment.addTarget(self, action: #selector(FriendListController.segmentChanged(_:)), for: .valueChanged)
    }
     
     fileprivate func fetchAllServerUsers() {
          let group = DispatchGroup()
          
          group.enter()
          FireDatabaseService.manager.fetchAllUser().then(execute: { (users) -> Void in
               if !users.isEmpty {
                    self.friends = users.filter {  return $0.isFriendOfCurrentUser   }
                    self.otherUsers = users.filter { return !$0.isCurrentUser &&  !$0.isFriendOfCurrentUser }
                    group.leave()
               }
          }).catch (execute: { (error) -> Void in
               fatalError(error.localizedDescription)
          })
          
          
          group.enter()
          FireDatabaseService.manager.fetchFriendRequests(status: .sent).then(on: DispatchQueue.main, execute: { (friendRequests) -> Void in
               for (i, o) in self.otherUsers.enumerated() where !self.otherUsers.isEmpty {
                    for f in friendRequests where o.userId == f.toUser {
                          _ = self.otherUsers.remove(at: i)
                    }
               }
               
               group.leave()
          }).catch(execute: { e -> Void in
               if case TypeError.snapNotAvail = e {
                    group.leave()
               }
          })
          
          group.notify(queue: DispatchQueue.main) {
               print("loading everthing")
               self.segmentChanged(self.segment)
          }
     }
     
     
     @objc func segmentChanged(_ sender: UISegmentedControl) {
          self.users = (sender.selectedSegmentIndex == 0) ? self.friends : self.otherUsers
          defer {
               friendsTableView.reloadData()
          }
     }
     
     @IBAction func topLeftBtnPressed(_ sender: Any) {
          let alert = UIAlertController(title: "Select Option", message: "", preferredStyle: UIAlertControllerStyle.actionSheet)
          let profileAction = UIAlertAction(title: "Profile", style: UIAlertActionStyle.default, handler: { (action) -> Void in
               let profileController = self.storyboard?.instantiateViewController(withIdentifier: "ProfileViewController")
               self.navigationController?.pushViewController(profileController!, animated: true)
          })
          
          alert.message = nil
          alert.addAction(profileAction)
          alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
          self.present(alert, animated: true, completion: nil)
     }
     
   
    @IBAction func logoutButton(_ sender: Any) {
        FireDatabaseService.manager.logOut().then(on: DispatchQueue.main, execute: { (isLoggout) -> Void in
            debugPrint("isLoggedOut: \(isLoggout)")
            (UIApplication.shared.delegate as! AppDelegate).setApplicationRootController()
            
        }).catch (execute: { (error) in
            fatalError(error.localizedDescription)
        })
    }
}


// MARK:- TableView delegate and datasource methods

extension FriendListController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          if segment.selectedSegmentIndex == 0  {
               let cell = tableView.dequeueReusableCell(withIdentifier: FriendCell.reusableIdentifier, for: indexPath) as! FriendCell
               let user = users[indexPath.row]
               cell.configure(user: user)
               return cell
          } else {
               let cell = tableView.dequeueReusableCell(withIdentifier: OtherCell.reusableIdentifier, for: indexPath) as! OtherCell
               let user = users[indexPath.row]
               cell.delegate = self
               cell.configure(user: user)
               return cell
          }
    }
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
          if segment.selectedSegmentIndex == 0  {
               performSegue(withIdentifier: "@chats", sender: nil)
          }
     }
     
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
          return segment.selectedSegmentIndex == 0  ? 60 : 80
     }
    
}


// MARK:- RequestDelegate delegate methods

extension FriendListController: RequestDelegate {
     
     func sendFriendRequest(to: String) {
          let request = FriendRequest(toUserId: to, status: .sent)
          FireDatabaseService.manager.saveFriendRequest(request: request)
     }
}


