//
//  RequestBin
//  Elevator
//
//  Created by Jack Hutchinson on 7/1/15.
//  Copyright (c) 2015 Jack Hutchinson. All rights reserved.
//

import Foundation

class RequestBin
{
    // MARK: -
    var data : [FloorRequest] = []
    
    // MARK: -

    func append(request : FloorRequest)
    {
        data.append(request)
    }
    var countQueue : Int
    {
        return self.data.count
    }
    func removeRequestsForFloor(index:Int, direction:ElevatorDirection) -> Bool
    {
        let cnt = count(data)
//        data = data.filter(){ !(($0.floorIndexCurrent == index && $0.direction==direction) || $0.floorIndexDestination == index) }
        data = data.filter(){ !$0.shouldStopAtFloor(index, direction: direction) }

        return count(data) < cnt
    }
    func nextRequestAfter(floorIndex:Int, direction:ElevatorDirection) -> FloorRequest?
    {
        var request : FloorRequest?
        var requestIndex : Int?
        for var i=0; i<self.data.count; i++
        {
            let r = self.data[i]
            if direction == ElevatorDirection.Up
            {
                if r.floorIndex()>floorIndex && (request == nil || r.floorIndex()<request?.floorIndex())
                {
                    requestIndex = i
                    request = r
                }
            }
            else if direction == ElevatorDirection.Down
            {
                if r.floorIndex()<floorIndex && (request == nil || r.floorIndex()>request?.floorIndex())
                {
                    requestIndex = i
                    request = r
                }
            }
        }
        if let requestIndex = requestIndex
        {
            return self.data.removeAtIndex(requestIndex)
        }
        return nil
    }
}
