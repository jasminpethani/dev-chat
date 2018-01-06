//
//  RoundImageView.swift
//  dev-chat
//
//  Created by jasmin on 31/12/17.
//  Copyright © 2017 jasmin. All rights reserved.
//

import UIKit


class RoundImageView: UIImageView {

   
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = frame.width / 2.0
        layer.borderColor = UIColor.clear.cgColor
        layer.borderWidth = 1.0
        clipsToBounds = true
    }
}
