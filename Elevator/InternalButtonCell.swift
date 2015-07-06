//
//  InternalButtonCollectionViewCell.swift
//  Elevator
//
//  Created by Jack Hutchinson on 7/1/15.
//  Copyright (c) 2015 Jack Hutchinson. All rights reserved.
//

import UIKit

class InternalButtonCell: UICollectionViewCell {
    
    @IBOutlet var floorButton : ToggleButton!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        
    }
    override func awakeFromNib() {
        
        self.layer.cornerRadius = self.bounds.size.width / 2.0
        self.layer.borderColor = UIColor.blackColor().CGColor
        self.layer.borderWidth = 2.0
        
    }
    func configureButton(floorNo:Int, isSelected:Bool, topFloorNo:Int, callback:(index:Int, buttonType:ButtonType) -> Void)
    {
        self.floorButton.setTitle("\(floorNo)", forState:.Normal)
        // in case floor # gets too large:
        self.floorButton.titleLabel!.adjustsFontSizeToFitWidth = true
        self.floorButton.titleLabel!.minimumScaleFactor = 0.5
        self.floorButton.selected = isSelected
        self.floorButton.callbackButtonActive = {toggle in
            
            callback(index: floorNo-1, buttonType: ButtonType.InternalFloorButton)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.selected = false
        self.floorButton.clear()
    }

}
