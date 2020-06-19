//
//  Tool.swift
//  KKFlyView
//
//  Created by 王铁山 on 2020/6/19.
//  Copyright © 2020 onety. All rights reserved.
//

import Foundation
import UIKit

func appIcon() -> UIImage? {
	guard let dic = Bundle.main.infoDictionary else {
		return nil
	}
	guard let bundleIcon = dic["CFBundleIcons"] as? [String: Any],
		let primary = bundleIcon["CFBundlePrimaryIcon"] as? [String: Any],
		let files = primary["CFBundleIconFiles"] as? [String] else {
			return nil
	}
	guard let last =  files.last else {
		return nil
	}
	guard let image = UIImage(named: last) else {
		return nil
	}
	UIGraphicsBeginImageContextWithOptions(image.size, false, UIScreen.main.scale)
	UIBezierPath.init(roundedRect: CGRect.init(origin: .zero, size: image.size), cornerRadius: min(image.size.width, image.size.height)).addClip()
	image.draw(in: CGRect.init(origin: .zero, size: image.size))
	let img = UIGraphicsGetImageFromCurrentImageContext()
	UIGraphicsEndImageContext()
	return img
}
