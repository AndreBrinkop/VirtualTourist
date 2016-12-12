//
//  ViewController.swift
//  VirtualTourist
//
//  Created by André Brinkop on 12.12.16.
//  Copyright © 2016 André Brinkop. All rights reserved.
//

import UIKit

let EDIT_LABEL_HEIGHT_HIDDEN: CGFloat = 0.0
let EDIT_LABEL_HEIGHT_SHOWN: CGFloat = 80.0

class LocationMapViewController: UIViewController {
    
    // MARK: Properties

    @IBOutlet var editLabelHeight: NSLayoutConstraint!
    
    // MARK: Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = editButtonItem
        
        editLabelHeight.constant = EDIT_LABEL_HEIGHT_HIDDEN
        
    }

    // MARK: Editing

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        editLabelHeight.constant = editing ? EDIT_LABEL_HEIGHT_SHOWN : EDIT_LABEL_HEIGHT_HIDDEN
        UIView.animate(withDuration: 0.1) {
            self.view.layoutIfNeeded()
        }
    }


}

