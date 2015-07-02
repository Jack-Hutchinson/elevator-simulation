//
//  SettingsViewController.swift
//  Elevator
//
//  Created by Jack Hutchinson on 6/30/15.
//  Copyright (c) 2015 Jack Hutchinson. All rights reserved.
//

import UIKit

class SettingsViewController: XLFormViewController {

    let kKeyBuildingConfiguration = "kKeyBuildingConfiguration"
    
    let kKeyNumberFloors = "kKeyNumberFloors"
//    let kKeyNumberElevators = "kKeyNumberElevators"
    let kKeyTimeBetweenFloors = "kKeyTimeBetweenFloors"
    let kKeyTimeAtFloors = "kKeyTimeAtFloors"
    
    var buildingConfiguration = ElevatorConfiguration.lastConfigurationOrDefault()
    
    // MARK: - Initializers
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        buildingConfiguration = ElevatorConfiguration.lastConfigurationOrDefault()
        
        self.initializeForm()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: XLFormDescriptorDelegate
    
    override func formRowDescriptorValueHasChanged(formRow: XLFormRowDescriptor!, oldValue: AnyObject!, newValue: AnyObject!) {
        super.formRowDescriptorValueHasChanged(formRow, oldValue: oldValue, newValue: newValue)
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        let tag = formRow.tag
        if newValue is NSNull
        {
            userDefaults.removeObjectForKey(tag)
        }
        else if let val = newValue as? XLFormOptionsObject
        {
            userDefaults.setObject(val.formDisplayText(), forKey: tag)
        }
        else if let val = newValue as? NSString
        {
            switch tag
            {
            case kKeyNumberFloors:
                self.buildingConfiguration.numberFloors = val.integerValue
//            case kKeyNumberElevators:
//                self.buildingConfiguration.numberElevators = val.integerValue
            case kKeyTimeAtFloors:
                self.buildingConfiguration.timeAtFloor = val.floatValue
            case kKeyTimeBetweenFloors:
                self.buildingConfiguration.timeBetweenFloors = val.floatValue
            default:
                break
            }
            ElevatorConfiguration.saveConfiguration(self.buildingConfiguration)
        }
    }
    
    // MARK: - XLForm
    func initializeForm() {
        
        let userDefaults = NSUserDefaults.standardUserDefaults()

        let form : XLFormDescriptor
        var section : XLFormSectionDescriptor
        var row : XLFormRowDescriptor
        
        form = XLFormDescriptor(title: "Elevator Settings")
        
        section = XLFormSectionDescriptor.formSection() //as! XLFormSectionDescriptor
        section.title = "Building"
        form.addFormSection(section)
        
        // Number of Floors
        row = XLFormRowDescriptor(tag: kKeyNumberFloors, rowType: XLFormRowDescriptorTypeText, title:"Number of Floors")
        row.cellConfigAtConfigure.setObject(NSNumber(integer: NSTextAlignment.Right.rawValue), forKey: "textField.textAlignment")
        row.cellConfigAtConfigure["textField.placeholder"] = "Enter # Floors"
        row.value = self.buildingConfiguration.numberFloors
        section.addFormRow(row)
        
//        // Number of Elevators
//        row = XLFormRowDescriptor(tag: kKeyNumberElevators, rowType: XLFormRowDescriptorTypeText, title:"Number of Elevators")
//        row.cellConfigAtConfigure.setObject(NSNumber(integer: NSTextAlignment.Right.rawValue), forKey: "textField.textAlignment")
//        row.cellConfigAtConfigure["textField.placeholder"] = "Enter # Elevators"
//        row.value = self.buildingConfiguration.numberElevators
//        section.addFormRow(row)
        
        // Time Between Floors
        row = XLFormRowDescriptor(tag: kKeyTimeBetweenFloors, rowType: XLFormRowDescriptorTypeText, title:"Time Between Floors")
        row.cellConfigAtConfigure.setObject(NSNumber(integer: NSTextAlignment.Right.rawValue), forKey: "textField.textAlignment")
        row.cellConfigAtConfigure["textField.placeholder"] = "Enter Seconds"
        row.value = self.buildingConfiguration.timeBetweenFloors
        section.addFormRow(row)
        
        // Time At Floors
        row = XLFormRowDescriptor(tag: kKeyTimeAtFloors, rowType: XLFormRowDescriptorTypeText, title:"Time At Floor")
        row.cellConfigAtConfigure.setObject(NSNumber(integer: NSTextAlignment.Right.rawValue), forKey: "textField.textAlignment")
        row.cellConfigAtConfigure["textField.placeholder"] = "Enter Seconds"
        row.value = self.buildingConfiguration.timeAtFloor
        section.addFormRow(row)

        self.form = form
        
    }

}
