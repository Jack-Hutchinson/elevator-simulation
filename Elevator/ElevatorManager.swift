//
//  ElevatorManager.swift
//  Elevator
//
//  Created by Jack Hutchinson on 7/1/15.
//  Copyright (c) 2015 Jack Hutchinson. All rights reserved.
//

import Foundation

// MARK: - Types of Input to Manager
enum ButtonType
{
    case InternalFloorButton
    case ExternalUpButton
    case ExternalDnButton
}
// MARK: - State for Elevator
enum ElevatorDirection
{
    case Ignore
    case Up
    case Down
}
class ElevatorManager
{
    // MARK: - Outputs to Controller
    var callbackElevatorMoving : (moving : Bool, direction:ElevatorDirection) -> Void
    var callbackCurrentFloorUpdate : (currentFloor : Int) -> Void
    var callbackClearButton : (floorIndex : Int, buttonType : ButtonType) -> Void
    var callbackElevatorDoor : (open : Bool) -> Void

    // MARK: - State Properties
    var isMoving : Bool
    var isServingRequest : Bool
    var currentFloorIndex : Int
    var currentElevatorDirection : ElevatorDirection
    // MARK: - Other Properties
    var configuration : ElevatorConfiguration
    var requestBin = RequestBin()
    
    let floorQueue = dispatch_queue_create("floorQueue", DISPATCH_QUEUE_CONCURRENT)
    var sema : dispatch_semaphore_t;

    
    // MARK: - Initializers and Initialization
    init(configuration :ElevatorConfiguration)
    {
        self.configuration = configuration
        callbackElevatorMoving = { (moving : Bool, direction : ElevatorDirection) -> Void in }
        callbackCurrentFloorUpdate = { (currentFloor : Int) -> Void in }
        callbackClearButton = { (floorIndex : Int, buttonType : ButtonType) -> Void in }
        callbackElevatorDoor = { (open : Bool) -> Void in }
        isMoving = false
        isServingRequest = false
        currentFloorIndex = 0
        currentElevatorDirection = .Up
        self.sema = dispatch_semaphore_create(1)

    }
    func reset()
    {
        requestBin = RequestBin()
        isMoving = false
        isServingRequest = false
        currentFloorIndex = 0
        currentElevatorDirection = .Up
        
        for index in 0..<configuration.numberFloors
        {
            callbackClearButton(floorIndex: index, buttonType: ButtonType.InternalFloorButton)
            callbackClearButton(floorIndex: index, buttonType: ButtonType.ExternalUpButton)
            callbackClearButton(floorIndex: index, buttonType: ButtonType.ExternalDnButton)
        }
        
        callbackCurrentFloorUpdate(currentFloor: currentFloorIndex + 1)
        callbackElevatorMoving(moving: isMoving, direction: currentElevatorDirection)
        callbackElevatorDoor(open: true)
        
    }

    // MARK: - Input to Controller
    func buttonActivatedForFloor(floorIndex:Int, buttonType:ButtonType)
    {
        // ignore if elevator is currently at the floor:
        if !isMoving && floorIndex == self.currentFloorIndex
        {
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                self.callbackElevatorDoor(open: true)
                self.callbackClearButton(floorIndex: floorIndex, buttonType: buttonType)
            }
            return
        }
        
        var request : FloorRequest?
        switch buttonType
        {
        case ButtonType.InternalFloorButton:
            request = FloorRequest(floorIndex: floorIndex)
        case ButtonType.ExternalUpButton:
            request = FloorRequest(sourceFloorIndex:floorIndex, direction:ElevatorDirection.Up)
        case ButtonType.ExternalDnButton:
            request = FloorRequest(sourceFloorIndex:floorIndex, direction:ElevatorDirection.Down)
        }
        if let request = request
        {
            self.theRequestBin().append(request)
            println("new request: \(request.description) ")

            if !isServingRequest
            {
                checkElevatorState(self.currentElevatorDirection, floorIndex:self.currentFloorIndex)
            }
        }
        
        
    }
    // MARK: - Elevator Operation
    func checkElevatorState(direction:ElevatorDirection, floorIndex:Int)
    {
        if let next = theRequestBin().nextRequestAfter(floorIndex, direction:direction)
        {
            self.isServingRequest = true
            moveToFloor(next)
        }
        else if theRequestBin().countQueue>0
        {
            if self.currentElevatorDirection == ElevatorDirection.Up
            {
                self.currentElevatorDirection = ElevatorDirection.Down
            }
            else if self.currentElevatorDirection == ElevatorDirection.Down
            {
                self.currentElevatorDirection = ElevatorDirection.Up
            }
            checkElevatorState(self.currentElevatorDirection, floorIndex: floorIndex)
        }
    }
    func moveToFloor(request : FloorRequest)
    {
        callbackElevatorDoor(open: false)

        var floorIndex = request.floorIndex()

        // set elevator direction:
        self.currentElevatorDirection = floorIndex < self.currentFloorIndex ? ElevatorDirection.Down : ElevatorDirection.Up;
        
        if self.currentElevatorDirection == .Up
        {
            for var floor = (self.currentFloorIndex+1); floor <= floorIndex; floor++
            {
                let index = floor   // capture the value before it changes in for loop
                dispatch_barrier_async(self.floorQueue, { () -> Void in
                    dispatch_semaphore_wait(self.sema, DISPATCH_TIME_FOREVER)
                    self.nextFloor(index, request:request){
                        dispatch_semaphore_signal(self.sema)
                    }
                })
            }
        }
        else
        {
            for var floor = (self.currentFloorIndex-1); floor>=floorIndex; floor--
            {
                let index = floor   // capture the value before it changes in for loop
                dispatch_barrier_async(self.floorQueue, { () -> Void in
                    dispatch_semaphore_wait(self.sema, DISPATCH_TIME_FOREVER)
                    self.nextFloor(index, request:request){
                        dispatch_semaphore_signal(self.sema)
                    }
                })
            }
        }
        
    }
    func nextFloor(floorIndex:Int, request : FloorRequest, completion:()->())
    {
        // 1) Start the move:
        self.isMoving = true
        self.callbackElevatorMoving(moving: self.isMoving, direction:self.currentElevatorDirection)
        
        self.delay(Double(self.configuration.timeBetweenFloors)){
            
            // floor is either a target floor or an intermediate floor.
            let stopAtFloor : Bool = floorIndex == request.floorIndex()
            
            // 2) Move ended, update state, UI
            self.isMoving = false
            self.currentFloorIndex = floorIndex
            
            // remove any appropriate request made for this floor:
            if stopAtFloor && request.direction != ElevatorDirection.Ignore
            {
                self.currentElevatorDirection = request.direction
            }
            self.updateUIWithFloorState()

            var localStop = self.theRequestBin().removeRequestsForFloor(floorIndex, direction:self.currentElevatorDirection)
            if localStop || stopAtFloor
            {
                self.callbackElevatorDoor(open: true)
                println("arrived floor \(floorIndex+1)")
                
                // delay for opening/closing door
                self.delay(Double(self.configuration.timeAtFloor), closure: { () -> () in
                    
                    self.callbackElevatorDoor(open: false)

                    if stopAtFloor
                    {
                        self.isServingRequest = false
                        if self.checkElevatorDirectionChangeForFloor(floorIndex)
                        {
                            self.theRequestBin().removeRequestsForFloor(floorIndex, direction:self.currentElevatorDirection)
                            self.updateUIWithFloorState()
                        }
                    }
                    self.checkElevatorState(self.currentElevatorDirection, floorIndex: self.currentFloorIndex)
                    completion()
                })
            }
            else
            {
                println("passing floor \(floorIndex+1)")

                completion()
            }
        }
    }
    func checkElevatorDirectionChangeForFloor(floorIndex:Int) -> Bool
    {
        var changed = false
        if floorIndex==0 && self.currentElevatorDirection==ElevatorDirection.Down
        {
            self.currentElevatorDirection = ElevatorDirection.Up
            changed = true
        }
        else if floorIndex == (self.configuration.numberFloors-1) && self.currentElevatorDirection==ElevatorDirection.Up
        {
            self.currentElevatorDirection = ElevatorDirection.Down
            changed = true
        }
        return changed
    }
    func updateUIWithFloorState()
    {
        self.callbackElevatorMoving(moving: self.isMoving, direction: self.currentElevatorDirection)
        self.callbackCurrentFloorUpdate(currentFloor: self.currentFloorIndex+1)
        if self.currentElevatorDirection==ElevatorDirection.Up
        {
            self.callbackClearButton(floorIndex: self.currentFloorIndex, buttonType: ButtonType.InternalFloorButton)
            self.callbackClearButton(floorIndex: currentFloorIndex, buttonType: ButtonType.ExternalUpButton)
        }
        else if self.currentElevatorDirection == ElevatorDirection.Down
        {
            self.callbackClearButton(floorIndex: currentFloorIndex, buttonType: ButtonType.InternalFloorButton)
            self.callbackClearButton(floorIndex: currentFloorIndex, buttonType: ButtonType.ExternalDnButton)
        }
        
    }
    // MARK: - Helpers
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    func theRequestBin() -> RequestBin
    {
        return self.requestBin
    }
    
}