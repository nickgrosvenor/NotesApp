//
//  ImageCell.swift
//  Notes
//
//  Created by Ankit Mishra on 16/03/15.
//  Copyright (c) 2015 rbt. All rights reserved.
//

import UIKit

let ImageHeight: CGFloat = 200.0
let OffsetSpeed: CGFloat = 25.0


class ImageCell: UITableViewCell {

    
    @IBOutlet weak var bhImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    var images: UIImage = UIImage(){
        didSet{
            bhImageView.image = images
        }
    }
    
    
    func offset(offset: CGPoint){
        bhImageView.frame = CGRectOffset(self.bhImageView.bounds, offset.x, offset.y)
    }
    


}



