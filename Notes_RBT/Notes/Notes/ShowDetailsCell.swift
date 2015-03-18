//
//  ShowDetailsCell.swift
//  TestDate
//
//  Created by Ankit Mishra on 13/03/15.
//  Copyright (c) 2015 rbt. All rights reserved.
//

import UIKit

class ShowDetailsCell: UITableViewCell {


    @IBOutlet weak var noteLbl: UITextView!
    @IBOutlet weak var bgTextView: UIView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var bgImage: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
