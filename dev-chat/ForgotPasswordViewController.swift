//
//  ForgotPasswordViewController.swift
//  dev-chat
//
//  Created by jasmin on 30/12/17.
//  Copyright © 2017 jasmin. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: UIViewController {

     @IBOutlet weak var emailTextField: UITextField!
    
    private func isValidEmailAddress(emailAddressString: String) -> Bool {
        
        var returnValue = true
        let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
        
        do {
            let regex = try NSRegularExpression(pattern: emailRegEx)
            let nsString = emailAddressString as NSString
            let results = regex.matches(in: emailAddressString, range: NSRange(location: 0, length: nsString.length))
            
            if results.count == 0
            {
                returnValue = false
            }
            
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            returnValue = false
        }
        
        return  returnValue
    }
    
     @IBAction func forgotPasswordClicked(_ sender: Any) {
          guard let email = emailTextField.text, !email.isEmpty else { return  }
        
        if isValidEmailAddress(emailAddressString: email) {
    
           FireDatabaseService.manager.forgotPassword(email: email)
               .then(on: DispatchQueue.main, execute: { doesSend -> Void in
                    if doesSend {
                         debugPrint("send to your mail \(email)")
                        self.dismiss(animated: true, completion: nil)
                    }
               }).catch (execute: { (error) in
                    let alert = UIAlertController(title: "Error", message: "Password reset request has not been sent", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel))
                    self.present(alert, animated: true, completion: nil)
               })
            
        } else {
            let alert = UIAlertController(title: "Error", message: "Email is not valid", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel))
            self.present(alert, animated: true, completion: nil)
        }
     }
     
}
