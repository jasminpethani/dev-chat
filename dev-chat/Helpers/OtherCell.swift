//
//  OtherCell.swift
//  dev-chat
//
//  Created by jasmin on 05/01/18.
//  Copyright © 2018 jasmin. All rights reserved.
//

import UIKit

protocol RequestDelegate: class {
     func sendFriendRequest(to: String)
}

class OtherCell: UITableViewCell {
     static let reusableIdentifier = "OtherCell"
     
     weak var delegate: RequestDelegate?
     
     @IBOutlet weak private  var profileImageView: UIImageView!
     @IBOutlet weak private var nameLabel: UILabel!
     @IBOutlet weak private var sendRequestBtn: UIButton!
     
     private var to: String = ""
 

    override func awakeFromNib() {
        super.awakeFromNib()
     
        backgroundColor = UIColor.clear
        selectionStyle = .none
        sendRequestBtn.addTarget(self, action: #selector(OtherCell.sendRequestBtnPressed), for: .touchUpInside)
    }
     
     func configure(user: UserDataModel) {
          self.to = user.userId
          if let photoUrl = user.photoUrl {
               profileImageView.kf.setImage(with: photoUrl)
          }
          self.nameLabel.text = user.username + " " + user.email
     }

     
     @objc func sendRequestBtnPressed() {
          delegate?.sendFriendRequest(to: self.to)
          sendRequestBtn.isEnabled = false
     }

}
