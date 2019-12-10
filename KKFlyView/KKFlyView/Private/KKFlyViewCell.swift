//
//  KKFlyViewCell.swift
//  KKFlyView
//
//  Created by 王铁山 on 2017/3/11.
//  Copyright © 2017年 kk. All rights reserved.
//

import Foundation

import UIKit

class KKFlyViewCell: UICollectionViewCell {
    
    var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.imageView = UIImageView.init()
        
        self.imageView.bounds = CGRect.init(x: 0, y: 0, width: frame.size.width - 8, height: frame.size.height - 8)
        
        self.imageView.center = CGPoint.init(x: frame.size.width / 2.0, y: frame.size.height / 2.0)
        
        self.imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.contentView.addSubview(self.imageView)
        
        self.layer.masksToBounds = true
        
        self.layer.cornerRadius = 3
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func showData(_ item: KKFlyViewItem, dash: Bool) {
        
        self.imageView.image = item.renderImage()
        
        if let tint = item.tintColor {
            self.imageView.tintColor = tint
        }
        
        if dash {
            
            let imageView = UIImageView.init(image: self.dashImage(self.bounds))
            
            self.backgroundView = imageView
        } else {
            
            self.backgroundView = nil
        }
        
    }
    
    fileprivate func dashImage(_ rect: CGRect) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)
        
        let context = UIGraphicsGetCurrentContext()
        
        let lengths: [CGFloat] = [5, 1.5]
        
        context?.setLineDash(phase: 0, lengths: lengths)
        
        context?.setLineWidth(3)
        
        context?.setLineJoin(.round)
        
        context?.setStrokeColor(UIColor.init(red: 109.0 / 255.0, green: 109.0 / 255.0, blue: 114.0 / 255.0, alpha: 1).cgColor)
        
        context?.addRect(rect)
        
        context?.strokePath()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image ?? UIImage()
    }
}
