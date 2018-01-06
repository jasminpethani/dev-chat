//
//  ProfileViewController.swift
//  dev-chat
//
//  Created by jasmin on 31/12/17.
//  Copyright © 2017 jasmin. All rights reserved.
//

import UIKit
import Eureka

enum AvailabilityStatus: String {
    case offline
    case online
}


class ProfileViewController: FormViewController {
    // TODO: profile upload photo
    // status of current profile
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var userStatus: UILabel! // online/offline
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: load model into profile
        
        userStatus.text = AvailabilityStatus.offline.rawValue
        tableView.showsVerticalScrollIndicator = false
        tableView.bounces = false
        
        setupProfileForm()
    }
    
    private func setupProfileForm() {
        form +++ Section()
        
            <<< TextRow("rowUserName") {
                $0.title = "User name"
            }
        
            <<< TextRow("rowEmail") {
                $0.title = "Email"
            }
        
            <<< TextRow("rowDOB") {
                $0.title = "Date of Birth"
            }
    }
    
    
    
    @IBAction func closeController(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func updateProfileClicked(_ sender: Any) {
        view.endEditing(true)
        debugPrint(form.values())
    }
}
