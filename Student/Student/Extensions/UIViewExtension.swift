//
//  UIViewExtension.swift
//  Student
//
//  Created by Leo Thomas on 11/12/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

extension UIView {

    func snapshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0);
        self.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let snapshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return snapshot
    }
    
    func snapshotView() -> UIView {
        let snapshotView = UIImageView(image: snapshot())
        snapshotView.layer.masksToBounds = false
        snapshotView.layer.shadowOffset = CGSizeMake(-5, 0)
        snapshotView.layer.shadowRadius = 5
        snapshotView.layer.shadowOpacity = 0.4
        return snapshotView
    }

}
