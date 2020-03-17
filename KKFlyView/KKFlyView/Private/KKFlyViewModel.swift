//
//  KKFlyViewModel.swift
//  KKFlyViewModel
//
//  Created by 王铁山 on 2017/3/11.
//  Copyright © 2017年 kk. All rights reserved.
//

import Foundation

import UIKit

protocol KKFlyViewModelDelegate: NSObjectProtocol {
    
    func close()
    
    func reloadData()
}

/// 浮窗管理者
/// 通过此类可以编辑新的功能和事件，数据管理层
class KKFlyViewModel {
    
    var viewType: KKFly.ViewType
    
    var items: [KKFlyViewItem] = []
    
    weak var delegate: KKFlyViewModelDelegate?
    
    var onSelected: ((KKFlyViewItem)->Void)?
	
	var project_key: String = "default"
    
    var cacheAllNames: [String] {
        get {
            return (UserDefaults.standard.value(forKey: "com.onety.fly.\(project_key).allname") as? [String]) ?? []
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "com.onety.fly.\(project_key).allname")
        }
    }
    
    var cacheShowingNames: [String] {
        get {
            return (UserDefaults.standard.value(forKey: "com.onety.fly.\(project_key).show") as? [String]) ?? []
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "com.onety.fly.\(project_key).show")
            var result: [KKFlyViewItem] = []
            for name in cacheShowingNames {
                if let index = items.lastIndex(where: {$0.name == name}) {
                    result.append(items[index])
                } else {
                    result.append(KKFlyViewItem.phItem())
                }
            }
            showingItems = result
        }
    }
    
    var showingItems: [KKFlyViewItem] = []
    
    /// 是否正在设置
    var setting: Bool = false
    
    /// 是否为展开模式
    var expending: Bool = false
    
    /// 是否正在动画
    var animating: Bool = false
    
    /// 没有展开之前的 frame
    var lastFrame: CGRect!
    
	init(delegate: KKFlyViewModelDelegate, viewType: KKFly.ViewType, items: [KKFlyViewItem], project_key: String?) {
		if let pk = project_key {
			self.project_key = pk
		}
        self.viewType = viewType
        self.delegate = delegate
        self.items = items
		// now
        let nowNames: [String] = items.map({$0.name})
		// cache all name
		var cacheAllNames = self.cacheAllNames
		if cacheAllNames.isEmpty {
			cacheAllNames = nowNames
		}
		// cache
        var cacheNames = cacheShowingNames
		// cache empty, show all now
        if cacheNames.isEmpty {
            cacheNames = nowNames
        }
		// count less, add ph
		if cacheNames.count < 6 {
			let phName = KKFlyViewItem.phItem().name
			for _ in 0..<(6-cacheNames.count) {
				cacheNames.append(phName)
			}
		}
		// delete abandoned
        cacheNames = cacheNames.filter({KKFlyViewItem.isPHItem(name: $0) || nowNames.contains($0)})
		// increase name
        var addNames: [String] = nowNames.filter({!cacheAllNames.contains($0)})
        cacheNames = cacheNames.map({ (name) -> String in
            if KKFlyViewItem.isPHItem(name: name) && !addNames.isEmpty {
                return addNames.popLast()!
            } else {
                return name
            }
        })
		if cacheNames.count < 6 {
			for _ in 0..<(6 - cacheNames.count) {
				if !addNames.isEmpty {
					cacheNames.append(addNames.popLast()!)
				}
			}
		}
        cacheShowingNames = cacheNames
        cacheAllNames = nowNames
    }
    
    func updateShowingItems(items: [KKFlyViewItem]) {
        self.cacheShowingNames = items.map({$0.name})
    }
    
    func selectedIndex(_ index: Int) {
        guard !showingItems[index].isPHItem else { return }
        onSelected?(showingItems[index])
        delegate?.close()
    }
        
    func getValidPresentingVC() -> UIViewController? {
        func getTopVC(_ base: UIViewController?) -> UIViewController? {
            guard let vc = base else {return nil}
            if let tabBar = vc as? UITabBarController {
                return getTopVC(tabBar.selectedViewController)
            } else if let na = vc as? UINavigationController {
                return getTopVC(na.visibleViewController)
            } else if let pre = vc.presentedViewController {
                return getTopVC(pre)
            } else {
                return base
            }
        }
        var resultWindow: UIWindow?
        if let delegate = UIApplication.shared.delegate, let window = delegate.window {
            resultWindow = window
        } else {
            resultWindow = UIApplication.shared.keyWindow
        }
        if let vc = resultWindow?.rootViewController {
            return getTopVC(vc)
        } else {
            return nil
        }
    }
}
