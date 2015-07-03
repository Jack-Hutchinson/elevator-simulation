//
//  ViewController.swift
//  Elevator
//
//  Created by Jack Hutchinson on 6/30/15.
//  Copyright (c) 2015 Jack Hutchinson. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var upArrowImageView :UIImageView!
    @IBOutlet weak var downArrowImageView :UIImageView!
    @IBOutlet weak var activity :UIActivityIndicatorView!
    @IBOutlet weak var currentFloorLabel: UILabel!
    @IBOutlet weak var internalFloorButtons: UICollectionView!
    @IBOutlet weak var externalFloorButtons: UICollectionView!
    @IBOutlet weak var elevatorDoorLabel: UILabel!
    
    @IBOutlet weak var constraintTopCollectionViewHeight:NSLayoutConstraint!;
    
    let kCellSpacing = CGFloat(3.0)
    let kInternalCellLength = CGFloat(75)
    let kExternallCellWidth = CGFloat(92)
    let kExternallCellHeight = CGFloat(95)
    let kNumberOfColumnsInternal = CGFloat(6)
    let kNumberOfColumnsExternal = CGFloat(3)
    var elevatorManager : ElevatorManager = ElevatorManager(configuration: ElevatorConfiguration.lastConfigurationOrDefault())
    
    var selectedInternal : [Bool] = []
    var selectedExternalUp : [Bool] = []
    var selectedExternalDn : [Bool] = []
    
    // MARK: - Initializers
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }

    // MARK: - ViewController Events
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.upArrowImageView.hidden = true
        self.downArrowImageView.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // load the configuration for the elevator:
        self.configureElevatorSystem()
        
    }
    // MARK: - Setup
    func configureElevatorSystem()
    {
        // reset exsiting
        elevatorManager.reset()
        
        elevatorManager = ElevatorManager(configuration: ElevatorConfiguration.lastConfigurationOrDefault())
        
        // MARK: Callbacks for refreshing the UI from elevator manager:
        elevatorManager.callbackElevatorMoving = { isMoving, direction in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.upArrowImageView.hidden = direction == ElevatorDirection.Down
                self.downArrowImageView.hidden = direction == ElevatorDirection.Up
                if isMoving
                {
                    self.activity.startAnimating()
                }
                else
                {
                    self.activity.stopAnimating()
                }
            })
        }
        elevatorManager.callbackCurrentFloorUpdate = { currentFloor in
            self.currentFloorLabel.text = "Floor \(currentFloor)"
        }
        elevatorManager.callbackClearButton = { floorIndex, buttonType in
            if let toggleButton = self.getToggleButtonForIndex(floorIndex, buttonType: buttonType)
            {
                toggleButton.clear()
            }
            self.setButtonSelected(floorIndex, bval: false, buttonType: buttonType)
        }
        elevatorManager.callbackElevatorDoor = { open in
            
            self.elevatorDoorLabel.hidden = !open
        }
        
        // initialized selected buttons shadow (for cell reuse)
        self.selectedInternal = [Bool](count:elevatorManager.configuration.numberFloors, repeatedValue : false)
        self.selectedExternalUp = [Bool](count:elevatorManager.configuration.numberFloors, repeatedValue : false)
        self.selectedExternalDn = [Bool](count:elevatorManager.configuration.numberFloors, repeatedValue : false)
        

        self.internalFloorButtons.reloadData()
        self.externalFloorButtons.reloadData()
        
        // delay to give collection view time to load
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.05 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.elevatorManager.reset()
        }
    }
    // MARK: - Actions
    
    @IBAction func dragCollectionViewAction(sender: AnyObject) {
        
        println("dragging")
    }
    
    @IBAction func refreshTapped(sender:AnyObject)
    {
        configureElevatorSystem()
    }
    // MARK: - Helpers
    func callBackForButtonTapped() -> (index:Int, buttonType:ButtonType) -> Void
    {
        // provide callback to call into elevator manager:
        return {index, buttonType in
            self.elevatorManager.buttonActivatedForFloor(index, buttonType: buttonType)
            
            self.setButtonSelected(index, bval: true, buttonType: buttonType)        }
    }
    func getToggleButtonForIndex(index:Int, buttonType:ButtonType) -> ToggleButton?
    {
        // returns toggle button associated with floor index, button type:
        if buttonType == ButtonType.InternalFloorButton
        {
            if let cell = self.internalFloorButtons.cellForItemAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) as? InternalButtonCell
            {
                return cell.floorButton
            }
        }
        else
        {
            if let cell = self.externalFloorButtons.cellForItemAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) as? ExternalButtonCell
            {
                if buttonType == ButtonType.ExternalUpButton
                {
                    return cell.upButton
                }
                else if buttonType == ButtonType.ExternalDnButton
                {
                    return cell.downButton
                }
            }
        }
        return nil
    }
    func setButtonSelected(index:Int, bval:Bool, buttonType:ButtonType)
    {
        // Helper to maintain selected state of buttons
        if buttonType == ButtonType.InternalFloorButton
        {
            self.selectedInternal[index] = bval
        }
        else if buttonType == ButtonType.ExternalUpButton
        {
            self.selectedExternalUp[index] = bval
        }
        else if buttonType == ButtonType.ExternalDnButton
        {
            self.selectedExternalDn[index] = bval
        }
    }
    // MARK: - UICollectionViewDatasource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        // number is same for both internal and external buttons:
        return self.elevatorManager.configuration.numberFloors
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let numberFloors = self.elevatorManager.configuration.numberFloors
        if collectionView == self.internalFloorButtons
        {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("internalButton", forIndexPath: indexPath) as! InternalButtonCell
            cell.configureButton(indexPath.row+1,
                isSelected:self.selectedInternal[indexPath.row],
                topFloorNo:numberFloors,
                callback: self.callBackForButtonTapped())
            return cell
        }
        else
        {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("externalButton", forIndexPath: indexPath) as! ExternalButtonCell
            cell.configureButton(indexPath.row+1,
                isSelectedUp:self.selectedExternalUp[indexPath.row],
                isSelectedDown:self.selectedExternalDn[indexPath.row],
                topFloorNo:numberFloors, callback: self.callBackForButtonTapped())
            return cell
        }
        
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
    {
        var width = UIScreen.mainScreen().bounds.size.width
        if collectionView == self.internalFloorButtons
        {
            return CGSizeMake(kInternalCellLength, kInternalCellLength)
        }
        else
        {
            return CGSizeMake(kExternallCellWidth, kExternallCellHeight)
        }
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets
    {
        return UIEdgeInsetsMake(kCellSpacing, kCellSpacing, kCellSpacing, kCellSpacing)
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat
    {
        return kCellSpacing
    }
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat
    {
        return kCellSpacing
    }


}

