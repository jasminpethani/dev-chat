//
//  RegistrationViewController.swift
//  dev-chat
//
//  Created by jasmin on 30/12/17.
//  Copyright © 2017 jasmin. All rights reserved.
//

import UIKit
import Eureka

class RegistrationViewController: FormViewController {

    private  var user = UserDataModel()
    
     override func viewDidLoad() {
          super.viewDidLoad()
        
          title = "Create Account"
 
          tableView.bounces = false
          tableView.showsVerticalScrollIndicator = false
          tableView.showsHorizontalScrollIndicator = false
          tableView.separatorStyle = .none
        
          initForm()
          setupRegistrationForm()
     }
 
     private func initForm() {
          NameRow.defaultCellSetup = { cell, row in
               cell.height = { 45 }
               cell.contentView.layoutMargins.left = 20
          }
          EmailRow.defaultCellSetup = { cell, row in
               cell.height = { 45 }
               cell.contentView.layoutMargins.left = 20
          }
          DateRow.defaultCellSetup = {cell , _ in
               cell.height = { 45 }
               cell.contentView.layoutMargins.left = 20
          }
          PasswordRow.defaultCellSetup = { cell, row in
               cell.height  = { 45 }
               cell.contentView.layoutMargins.left = 20
          }
        
            LabelRow.defaultCellSetup = { cell, row in
                cell.textLabel?.textColor = UIColor.red
                cell.contentView.layoutMargins.left = 20
                cell.textLabel?.font = UIFont.systemFont(ofSize: 11.0)
                cell.height = { 10 }
                cell.textLabel?.textAlignment = .right
            }
     }
    
     private func setupRegistrationForm()  {
          form +++ Section()
          
               <<< NameRow("usernameRow") {
                    $0.placeholder = "@username"
                    $0.add(rule: RuleRequired())
                    $0.validationOptions = .validatesOnChangeAfterBlurred
                }.cellUpdate({ (cell, row) in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }else {
                        self.user.username = row.value ?? ""
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
            
               <<< EmailRow("emailRow") {
                    $0.placeholder = "john@example.com"
                    $0.add(rule: RuleRequired())
                    $0.add(rule: RuleEmail())
                    $0.validationOptions = .validatesOnChangeAfterBlurred
                }.cellUpdate({ (cell, row) in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }else {
                        self.user.email = row.value  ?? ""
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
               
               <<< DateRow("dateOfBirthRow") {
                     $0.noValueDisplayText = "Type your Date of Birth"
                }.onChange({ (row) in
                    self.user.dateOfBirth = row.value
                })
               
               <<< PasswordRow("passwordRow") {
                    $0.placeholder = "Password"
                    $0.add(rule: RuleMinLength(minLength: 8))
                    $0.add(rule: RuleMaxLength(maxLength: 13))
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
               
               <<< PasswordRow("otherPasswordRow") {
                    $0.placeholder = "Re-type your password"
                    $0.add(rule: RuleEqualsToRow(form: form, tag: "passwordRow"))
               } .cellUpdate { cell, row in
                    if !row.isValid {
                         cell.titleLabel?.textColor = .red
                    } else {
                        self.user.password = row.value  ?? ""
                    }
                }.onRowValidationChanged({ (cell, row) in
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
     }
     
     @IBAction func createAccountPressed(_ sender: Any) {
        view.endEditing(true)
        let erros = form.validate()
        if erros.isEmpty {
            FireDatabaseService.manager.registerUser(model: user).then { (logggedIn) -> Void in
                if logggedIn {
                    (UIApplication.shared.delegate as! AppDelegate).setApplicationRootController()
                }
                }.catch { (error) in
                    debugPrint(error.localizedDescription)
            }
        }
     }

}
