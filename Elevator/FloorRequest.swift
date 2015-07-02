//
//  FloorRequest.swift
//  Elevator
//
//  Created by Jack Hutchinson on 7/1/15.
//  Copyright (c) 2015 Jack Hutchinson. All rights reserved.
//

import Foundation

class FloorRequest
{
    // 2 modes of an object:
    //  Mode A: floor destination explicity set
    //  Mode B: elevator direction specified from request source

    // MARK: - Constants and Properties
    let IgnoreIndex = -1
    var floorIndexDestination : Int
    var floorIndexCurrent : Int
    var direction : ElevatorDirection
    
    // MARK: - Initializers
    init(floorIndex:Int)
    {
        floorIndexDestination = floorIndex
        floorIndexCurrent = IgnoreIndex
        direction = .Ignore
    }
    init(sourceFloorIndex:Int, direction:ElevatorDirection)
    {
        floorIndexDestination = IgnoreIndex
        floorIndexCurrent = sourceFloorIndex
        self.direction = direction
    }
    // MARK: - Methods
    var description : String
    {
        if self.direction == ElevatorDirection.Ignore
        {
            return "Request floor \(floorIndexDestination+1)"
        }
        else
        {
            let dir = self.direction == ElevatorDirection.Up ? "Up" : "Down"
            return "Request \(dir) from floor \(floorIndexCurrent+1)"
        }
    }
    func floorIndex() -> Int
    {
        if self.direction == ElevatorDirection.Ignore
        {
            return floorIndexDestination
        }
        else
        {
            return floorIndexCurrent
        }
    }
}
