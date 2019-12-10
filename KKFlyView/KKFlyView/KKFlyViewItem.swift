//
//  KKFlyViewItem.swift
//  KKFlyViewItem
//
//  Created by 王铁山 on 2017/3/11.
//  Copyright © 2017年 kk. All rights reserved.
//

import Foundation

import UIKit

open class KKFlyViewItem {
    
    /// Set up a ID to distinguish
    open var name: String
    
    /// icon image
    open var image: UIImage?
    
    /// tint color
    open var tintColor: UIColor?
    
    /// color for text, not be used in this version
    var titleColor: UIColor?
    
    public init(name: String, image: UIImage?) {
        self.name = name
        self.image = image
    }
    
    open func renderImage() -> UIImage? {
        guard let img = image else {
            return nil
        }
        guard let _ = tintColor else {
            return img
        }
        return img.withRenderingMode(.alwaysTemplate)
    }
}




