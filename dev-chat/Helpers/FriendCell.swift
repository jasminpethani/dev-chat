//
//  FriendCell.swift
//  dev-chat
//
//  Created by jasmin on 31/12/17.
//  Copyright © 2017 jasmin. All rights reserved.
//

import UIKit
import Kingfisher

class FriendCell: UITableViewCell {
    static let reusableIdentifier = "FriendCell"
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var netwrokStatus: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
    }
 
     func configure(user: UserDataModel) {
          if let photoUrl = user.photoUrl {
             profileImageView.kf.setImage(with: photoUrl)
          }
          self.nameLabel.text = user.username + " " + user.email
          self.netwrokStatus.text = "offline"
     }

}
