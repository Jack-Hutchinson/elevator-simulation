//
//  ExternalButtonCollectionViewCell
//  Elevator
//
//  Created by Jack Hutchinson on 7/1/15.
//  Copyright (c) 2015 Jack Hutchinson. All rights reserved.
//

import UIKit

class ExternalButtonCell : UICollectionViewCell
{
    @IBOutlet var floorLabel : UILabel!
    @IBOutlet var upButton : ToggleButton!
    @IBOutlet var downButton : ToggleButton!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        
    }
    override func awakeFromNib() {
        
        
        self.layer.borderColor = UIColor.blackColor().CGColor
        self.layer.borderWidth = 2.0
    }
    func configureButton(floorNo:Int, isSelectedUp:Bool, isSelectedDown:Bool, topFloorNo:Int, callback:(index:Int, buttonType:ButtonType) -> Void)
    {
        self.floorLabel.text = "\(floorNo)"
        if floorNo == 1
        {
            self.downButton.hidden = true
        }
        if floorNo == topFloorNo
        {
            self.upButton.hidden = true
        }
        
        self.upButton.selected = isSelectedUp
        self.downButton.selected = isSelectedDown
        
        self.upButton.callbackButtonActive = {toggle in
                callback(index: floorNo-1, buttonType: ButtonType.ExternalUpButton)
        }
        self.downButton.callbackButtonActive = {toggle in
            callback(index: floorNo-1, buttonType: ButtonType.ExternalDnButton)
        }
        
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.selected = false

        upButton.clear()
        upButton.hidden = false
        downButton.clear()
        downButton.hidden = false
    }

    
}