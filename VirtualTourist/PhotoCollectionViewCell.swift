//
//  PhotoCollectionViewCell.swift
//  VirtualTourist
//
//  Created by André Brinkop on 12.12.16.
//  Copyright © 2016 André Brinkop. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var errorLabel: UILabel!
    
    override var isSelected: Bool {
        didSet {
            self.contentView.alpha = isSelected ? 0.6 : 1.0
        }
    }
    
}
