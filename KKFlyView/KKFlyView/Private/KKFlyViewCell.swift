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
    
    var imageView: UIImageView = UIImageView.init()
	
	var label: UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
		label.textColor = .white
		label.textAlignment = .center
        contentView.addSubview(imageView)
		contentView.addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
	
	override func layoutSubviews() {
		super.layoutSubviews()
	}

	func showData(_ item: KKFlyViewItem, dash: Bool, showLabel: Bool, labelHeight: CGFloat) {
        imageView.image = item.renderImage()
		label.text = item.isPHItem ? "" : item.name
        if let tint = item.tintColor {
            imageView.tintColor = tint
        }
        if dash {
			if frame.size.width > 0 {
				let imageView = UIImageView.init(image: dashImage(bounds))
				backgroundView = imageView
			}
			imageView.layer.masksToBounds = true
			imageView.layer.cornerRadius = 3
        } else {
			imageView.layer.masksToBounds = false
			imageView.layer.cornerRadius = 0
            backgroundView = nil
        }
		relayout(dash: dash, showLabel: showLabel, labelHeight: labelHeight)
    }
	
	func relayout(dash: Bool, showLabel: Bool, labelHeight: CGFloat) {
		label.isHidden = !showLabel
		if showLabel {
			label.frame = CGRect.init(x: 0, y: frame.size.height - labelHeight, width: frame.size.width, height: labelHeight)
		}
		if !showLabel {
			imageView.frame = CGRect(x: 3, y: 3, width: frame.size.width - 6, height: frame.size.height - 6)
		} else {
			imageView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height - labelHeight)
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
