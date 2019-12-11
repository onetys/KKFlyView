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
    
    weak var windowDelegate: KKFlyViewDelegate?
    
    var cacheAllNames: [String] {
        get {
            return (UserDefaults.standard.value(forKey: "com.onety.fly.allname") as? [String]) ?? []
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "com.onety.fly.allname")
        }
    }
    
    var cacheShowingNames: [String] {
        get {
            return (UserDefaults.standard.value(forKey: "com.onety.fly.show") as? [String]) ?? []
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "com.onety.fly.show")
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
    
    /// 没有展开之前的 frame
    var lastFrame: CGRect!
    
    init(delegate: KKFlyViewModelDelegate, viewType: KKFly.ViewType, items: [KKFlyViewItem]) {
        self.viewType = viewType
        self.delegate = delegate
        self.items = items
        let nowNames: [String] = items.map({$0.name})
        var cacheNames = cacheShowingNames
        if cacheNames.isEmpty {
            cacheNames = Array<KKFlyViewItem>.init(repeating: KKFlyViewItem.phItem(), count: 6).map({$0.name})
        }
        cacheNames = cacheNames.filter({KKFlyViewItem.isPHItem(name: $0) || nowNames.contains($0)})
        var addNames: [String] = nowNames.filter({!cacheAllNames.contains($0)})
        cacheNames = cacheNames.map({ (name) -> String in
            if KKFlyViewItem.isPHItem(name: name) && !addNames.isEmpty {
                return addNames.popLast()!
            } else {
                return name
            }
        })
        cacheShowingNames = cacheNames
        cacheAllNames = items.map({$0.name})
    }
    
    func updateShowingItems(items: [KKFlyViewItem]) {
        self.cacheShowingNames = items.map({$0.name})
    }
    
    func selectedIndex(_ index: Int) {
        self.windowDelegate?.flyViewSelectedItem(self.showingItems[index])
        self.delegate?.close()
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
