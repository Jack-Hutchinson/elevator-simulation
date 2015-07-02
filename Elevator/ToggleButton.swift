//
//  ToggleButton.swift
//  Elevator
//
//  Created by Jack Hutchinson on 7/1/15.
//  Copyright (c) 2015 Jack Hutchinson. All rights reserved.
//

import UIKit

class ToggleButton: UIButton {
    
    var callbackButtonActive : (me:ToggleButton)->Void = {toggle in}
    override func awakeFromNib() {
        
        self.addTarget(self, action: Selector("touchUpInside:"), forControlEvents: .TouchUpInside)
    }
    func touchUpInside(sender: UIButton!)
    {
        // deselection not allowed by user:
        if !selected
        {
            selected = true
            callbackButtonActive(me: self)
        }
    }
    func clear()
    {
        selected = false
        setNeedsDisplay()
        setNeedsLayout()
    }

}
