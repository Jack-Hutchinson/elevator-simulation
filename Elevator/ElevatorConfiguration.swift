//
//  ElevatorConfiguration
//  Elevator
//
//  Created by Jack Hutchinson on 7/1/15.
//  Copyright (c) 2015 Jack Hutchinson. All rights reserved.
//

import Foundation

struct ElevatorConfiguration
{
    // MARK: - Constants and Properties
    static let kKeyBuildingConfiguration = "kKeyBuildingConfiguration"
    static let kKeyNumberFloors = "kKeyNumberFloors"
    static let kKeyNumberElevators = "kKeyNumberElevators"
    static let kKeyTimeBetweenFloors = "kKeyTimeBetweenFloors"
    static let kKeyTimeAtFloors = "kKeyTimeAtFloors"

    var numberElevators : Int = 1
    var numberFloors : Int = 3
    var timeAtFloor : Float = 2.0
    var timeBetweenFloors : Float = 1.5
    
    // MARK: - Static class methods

    static func lastConfigurationOrDefault() -> ElevatorConfiguration
    {
        var cfg = ElevatorConfiguration()
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let saved = userDefaults.objectForKey(kKeyBuildingConfiguration) as? NSDictionary
        {
            if let ival = saved[kKeyNumberElevators] as? Int
            {
                cfg.numberElevators = ival
            }
            if let ival = saved[kKeyNumberFloors] as? Int
            {
                cfg.numberFloors = ival
            }
            if let fval = saved[kKeyTimeBetweenFloors] as? Float
            {
                cfg.timeBetweenFloors = fval
            }
            if let fval = saved[kKeyTimeAtFloors] as? Float
            {
                cfg.timeAtFloor = fval
            }
            
        }
        return cfg
    }
    static func saveConfiguration(cfg : ElevatorConfiguration)
    {
        var dict = NSMutableDictionary()
        dict[kKeyNumberElevators] = cfg.numberElevators
        dict[kKeyNumberFloors] = cfg.numberFloors
        dict[kKeyTimeAtFloors] = cfg.timeAtFloor
        dict[kKeyTimeBetweenFloors] = cfg.timeBetweenFloors
        
        NSUserDefaults.standardUserDefaults().setObject(dict, forKey: kKeyBuildingConfiguration)
        NSUserDefaults.standardUserDefaults().synchronize()
        
    }
}