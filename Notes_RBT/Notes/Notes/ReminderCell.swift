//
//  ReminderCell.swift
//  Notes
//
//  Created by Rational Bits on 20/03/15.
//  Copyright (c) 2015 rbt. All rights reserved.
//

import UIKit

class ReminderCell: UITableViewCell {

    @IBOutlet var reminderLabel: UILabel!
    
    @IBOutlet var reminderValue: UILabel!
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    
}

