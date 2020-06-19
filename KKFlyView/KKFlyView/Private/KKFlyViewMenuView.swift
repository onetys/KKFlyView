//
//  KKFlyViewMenuView.swift
//  KKFlyView
//
//  Created by 王铁山 on 2020/6/19.
//  Copyright © 2020 onety. All rights reserved.
//

import Foundation

import UIKit

class KKFlyViewMenuView: UIView {
	
	class func defaultMenuView() -> KKFlyViewMenuView {
		let window = KKFlyViewMenuView.init(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
		window.layer.cornerRadius = 13
		window.layer.masksToBounds = true
		return window
	}
	
	override func draw(_ rect: CGRect) {
		
		super.draw(rect)
		
		guard let context = UIGraphicsGetCurrentContext() else {
			return
		}
		
		let width = rect.size.width
		let height = rect.size.height
		
		let lineWidth: CGFloat = 4
		
		context.setFillColor(UIColor.init(red: 90.0 / 255.0, green: 90.0 / 255.0, blue: 90.0 / 255.0, alpha: 1).cgColor)
		
		context.fill(rect)
		
		let colors = [
			UIColor.init(red: 170.0 / 255.0, green: 170.0 / 255.0, blue: 170.0 / 255.0, alpha: 1),
			UIColor.init(red: 120.0 / 255.0, green: 120.0 / 255.0, blue: 120.0 / 255.0, alpha: 1)]
		
		context.setLineWidth(lineWidth)
		
		for i in 0...colors.count-1 {
			
			context.setStrokeColor(colors[i].cgColor)
			
			context.addArc(center: CGPoint.init(x: width / 2.0, y: height / 2.0), radius: 16 + lineWidth / 2.0 + CGFloat(i) * lineWidth, startAngle: CGFloat.pi * 2, endAngle: 0, clockwise: true)
			
			context.strokePath()
		}
		
		context.setFillColor(UIColor.clear.cgColor)
		
		context.addArc(center: CGPoint.init(x: width / 2.0, y: height / 2.0), radius: 16 - lineWidth / 2.0, startAngle: CGFloat.pi * 2, endAngle: 0, clockwise: true)
		
		context.fillPath()
		
		appIcon()?.draw(in: CGRect(x: (rect.size.width - 2 * 16) / 2.0, y: (rect.size.height - 2 * 16) / 2.0, width: 32, height: 32))
	}
}
