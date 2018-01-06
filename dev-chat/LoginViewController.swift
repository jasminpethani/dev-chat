//
//  LoginViewController.swift
//  dev-chat
//
//  Created by jasmin on 30/12/17.
//  Copyright © 2017 jasmin. All rights reserved.
//

import UIKit
import Eureka

class LoginViewController: FormViewController {
  
 
     // MARK:- Life Cycle methods
     
     override func viewDidLoad() {
          super.viewDidLoad()
          
          tableView.backgroundColor = UIColor.white
          tableView.bounces = false
          tableView.separatorStyle = .none
          tableView.showsHorizontalScrollIndicator = false
          tableView.showsVerticalScrollIndicator = false
          
          
          title = "Login"
          
          initForm()
          setupLoginForm()
          
     }

     private func initForm() {
          EmailRow.defaultCellSetup = { cell, row in
               cell.height = { 45 } // increase the height 6 pt
               cell.layoutMargins = .zero // remove table cell separator margin
               cell.contentView.layoutMargins.left = 20 // set up left margin to 20
          }
          
          PasswordRow.defaultCellSetup = { cell, row in
               cell.height = { 45 } // increase the height 6 pt
               cell.layoutMargins = .zero // remove table cell separator margin
               cell.contentView.layoutMargins.left = 20 // set up left margin to 20
          }
          
          LabelRow.defaultCellSetup = { cell, row in
               cell.textLabel?.textColor = UIColor.red
               cell.contentView.layoutMargins.left = 20
               cell.textLabel?.font = UIFont.systemFont(ofSize: 11.0)
               cell.height = { 10 }
               cell.textLabel?.textAlignment = .right
          }
      }
     
     private func setupLoginForm() {
          let mainSection = Section()
          
          mainSection <<< EmailRow("emailRow") {
               $0.placeholder = "john@doe.com"
               $0.add(rule: RuleRequired(msg: "email field is required"))
               $0.add(rule: RuleEmail(msg: "not valid email"))
               $0.validationOptions = ValidationOptions.validatesOnChangeAfterBlurred
          }.cellUpdate({ (cell, row) in
               if !row.isValid {
                    cell.titleLabel?.textColor = .red
               }
          })
          .onRowValidationChanged({ (cell, row) in
               let rowIndex = row.indexPath!.row
               while row.section!.count > rowIndex + 1 && row.section?[rowIndex  + 1] is LabelRow {
                    row.section?.remove(at: rowIndex + 1)
               }
               if !row.isValid {
                    for (index, validationMsg) in row.validationErrors.map({ $0.msg }).enumerated() {
                         let labelRow = LabelRow() {
                              $0.title = validationMsg
                              $0.cell.height = { 30 }
                         }
                         row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                    }
               }
          })
          
          mainSection <<< PasswordRow("passwordRow") {
               $0.placeholder = "Password"
               $0.add(rule: RuleRequired(msg: "password field is require"))
               $0.validationOptions = ValidationOptions.validatesOnChangeAfterBlurred
          }
          .cellUpdate({ (cell, row) in
               if !row.isValid {
                    cell.titleLabel?.textColor = .red
               }
          })
          .onRowValidationChanged({ (cell, row) in
               let rowIndex = row.indexPath!.row
               while row.section!.count > rowIndex + 1 && row.section?[rowIndex  + 1] is LabelRow {
                    row.section?.remove(at: rowIndex + 1)
               }
               if !row.isValid {
                    for (index, validationMsg) in row.validationErrors.map({ $0.msg }).enumerated() {
                         let labelRow = LabelRow() {
                              $0.title = validationMsg
                              $0.cell.height = { 30 }
                         }
                         row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                    }
               }
           })
          
          form +++ mainSection
     }
     
     
     @IBAction func registrationButtonClicked(_ sender: Any) {
          performSegue(withIdentifier: "@registration", sender: nil)
     }
     
     @IBAction func forgotPwdButtonClicked(_ sender: Any) {
          performSegue(withIdentifier: "@forgotpassword", sender: nil)
     }
     
     @IBAction func loginButtonClicked(_ sender: Any) {
          self.view.endEditing(true)
          let errors = form.validate()
          
          if errors.isEmpty {
               let values = form.values()
               guard let email = values["emailRow"] as? String,
                    let password = values["passwordRow"] as? String else { return }
               
               FireDatabaseService.manager.loginIntoFirebase(with: email, password: password).then(execute: { user -> Void in
                    (UIApplication.shared.delegate as! AppDelegate).setApplicationRootController()
               }).catch(execute: { (error) in
                    fatalError(error.localizedDescription)
               })
          }
     }
         
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
          if segue.identifier == "@registration" {
          
          } else if segue.identifier == "@forgotpassword" {
               
          }
     }
     
}
