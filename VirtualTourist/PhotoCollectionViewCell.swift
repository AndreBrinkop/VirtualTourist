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
    @IBOutlet var trashOverlay: UIView!
    
    override var isSelected: Bool {
        didSet {
            self.trashOverlay.isHidden = !isSelected
        }
    }
    
}
