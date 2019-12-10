//
//  KKFlyWindow.swift
//  KKFloatWindowView
//
//  Created by 王铁山 on 2017/3/9.
//  Copyright © 2017年 kk. All rights reserved.
//

import UIKit

import Foundation

/**
 *  浮窗回调
 */
public protocol KKFLoatWindowDelegate: NSObjectProtocol {
    
    func floatWindowSelectedItem(_ item: KKFlyViewItem)
}

open class KKFlyWindow: UIWindow {

    /// 默认功能的 window，默认大小 (2, 100, 60, 60)
    open class func defaultFloatWindow(delegate: KKFLoatWindowDelegate, items: [KKFlyViewItem]) -> KKFlyWindow? {
        let window = KKFlyWindow.init(frame: CGRect.init(x: 2, y: 100, width: 60, height: 60), items: items)
        window.isHidden = false
        window.windowLevel = .statusBar
        window.layer.cornerRadius = 13
        window.layer.masksToBounds = true
        window.delegate = delegate
        return window
    }

    open weak var delegate: KKFLoatWindowDelegate? {
        didSet {
            self.viewModel.windowDelegate = self.delegate
        }
    }
    
    /// 移动窗口的手势
    open var panGestureRecognizer: UIPanGestureRecognizer!
    
    public init(frame: CGRect, items: [KKFlyViewItem]) {
        super.init(frame: frame)
        
        self.panGestureRecognizer = UIPanGestureRecognizer.init(target: self, action: #selector(pan(_:)))
        self.addGestureRecognizer(self.panGestureRecognizer)
        
        self.commitInit()
        
        self.viewModel = KKFlyViewModel.init(delegate: self, items: items)
        self.viewModel.lastFrame = self.frame
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - expend
    open func expend() {
        
        if self.viewModel.expending { return }
        
        self.menunView.isHidden = true
        
        self.viewModel.expending = true
        
        self.viewModel.lastFrame = self.frame
        
        self.frame = UIScreen.main.bounds
        
        if self.meunItemsView == nil {
            self.meunItemsView = self.getMenuItemsView()
            self.addSubview(self.meunItemsView)
        } else {
            self.meunItemsView.isHidden = false
        }
        
        self.collectionView.reloadData()
        
        self.meunItemsView.frame = self.viewModel.lastFrame
        
        UIView.animate(withDuration: 0.25, animations: {
            self.meunItemsView.frame = self.getMenuItemsFrame()
        }, completion: { (finsh) in
        }) 
    }
    
    open func close() {
        
        if !self.viewModel.expending {
            return
        }
        
        self.viewModel.expending = false
        
        if let menu = self.meunItemsView {
            UIView.animate(withDuration: 0.25, animations: {
                menu.frame = self.viewModel.lastFrame
            }, completion: { (finsh) in
               self.frame = self.viewModel.lastFrame
                self.menunView.isHidden = false
                self.viewModel.lastFrame = nil
                menu.isHidden = true
            }) 
        } else {
            self.frame = self.viewModel.lastFrame
            self.menunView.isHidden = false
           self.viewModel.lastFrame = nil
        }
        
    }
    
    /**
     show setting vc
     */
    @objc open func set() {
        self.close()
        guard !self.viewModel.setting else {
            return
        }
        self.viewModel.setting = true
        let settingVC = KKFloatSettingViewController(items: viewModel.items, showItems: viewModel.showingItems)
        settingVC.dismissBlock = { [weak self] in
            self?.viewModel.setting = false
        }
        settingVC.resultBlock = { [weak self] (items) in
            self?.viewModel.updateShowingItems(items: items)
        }
        self.viewModel.getValidPresentingVC()?.present(UINavigationController.init(rootViewController: settingVC), animated: true, completion: nil)
    }
    
    // MARK: - action
    
    @objc fileprivate func timerAction() {
        UIView.animate(withDuration: 0.25, animations: {
            self.menunView.alpha = 0.5
        }) 
        self.timer.fireDate = Date.distantFuture
    }
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.timer.fireDate = Date.distantFuture
        self.menunView.alpha = 1.0
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.menunView.alpha = 1.0
        
        self.timer.fireDate = Date().addingTimeInterval(2.0)
        
        if self.viewModel.expending {
            
            if let first = touches.first, let meunItemV = self.meunItemsView {
                
                if !meunItemV.bounds.contains(first.location(in: meunItemV)) {
                    self.close()
                    return
                }
            }
        }
        
        self.expend()
    }
    
    @objc fileprivate func pan(_ pan: UIPanGestureRecognizer) {
        
        if self.viewModel.expending {
            return
        }
        
        let t = pan.translation(in: self)
        
        let width = self.frame.size.width
        
        let height = self.frame.size.height
        
        let swidth = UIScreen.main.bounds.width
        
        let sheight = UIScreen.main.bounds.height
        
        let x = self.frame.origin.x
        
        let y = self.frame.origin.y
        
        self.frame = CGRect(x: x + t.x, y: y + t.y, width: width, height: height)
        
        pan.setTranslation(CGPoint.zero, in: self)
        
        if pan.state == .ended || pan.state == .cancelled {
            
            self.menunView.alpha = 1.0
            
            let center = self.center
            
            self.timer.fireDate = Date().addingTimeInterval(4.0)
            
            UIView.animate(withDuration: 0.25, animations: {
                var cx: CGFloat = 0.0
                var cy: CGFloat = 0.0
                if center.x < swidth / 2.0 {
                    cx = width / 2.0 + 2
                } else {
                    cx = swidth - width / 2.0 - 2
                }
                
                if self.frame.origin.y <= 50 {
                    cy = height / 2.0 + 22
                } else if y >= sheight - height - 30 {
                    cy = sheight - height / 2.0 - 2
                } else {
                    cy = y
                }
                
                self.center = CGPoint.init(x: cx, y: cy)
            })
        }
    }

    
    // MARK: - private
    
    fileprivate var viewModel: KKFlyViewModel!
    
    fileprivate var menunView: KKFlyViewMenuView!
    
    fileprivate var meunItemsView: UIView!
    
    fileprivate var collectionView: KKFlyCollectionView!
    
    fileprivate lazy var timer: Timer = {
        let time = Timer.init(timeInterval: 4.0, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        time.fireDate = Date.distantFuture
        RunLoop.current.add(time, forMode: .common)
        return time
    }()
    
    
    fileprivate func commitInit() {
        
        self.menunView = KKFlyViewMenuView.defaultMenuView()
        
        self.addSubview(self.menunView)
        
        self.menunView.alpha = 0.5
    }
}

// MARK: - collection view

extension KKFlyWindow: UICollectionViewDelegate, UICollectionViewDataSource {
    
    fileprivate func getCollectionView() -> KKFlyCollectionView {

        let coll = KKFlyCollectionView.init(frame: CGRect.zero, collectionViewLayout: KKFlyViewCollectionLayout())
        
        coll.touchBegin = {[weak self] in
            if let wSelf = self {
                wSelf.close()
            }
        }
        
        coll.delegate = self
        
        coll.dataSource = self
        
        coll.backgroundColor = UIColor.clear
        
        coll.register(KKFlyViewCell.classForCoder(), forCellWithReuseIdentifier: "cellId")
        
        return coll
    }
    
    fileprivate func getMenuItemsFrame() -> CGRect {
        
        let screenWidth = UIScreen.main.bounds.size.width
        
        let screenHeight = UIScreen.main.bounds.size.height
        
        let realWidth = min(screenWidth, 441) - 2 * 10
        
        let x = (screenWidth - realWidth) / 2.0
        
        let y = (screenHeight - realWidth) / 2.0
        
        return CGRect.init(x: x, y: y, width: realWidth, height: realWidth)
    }
    
    fileprivate func getMenuItemsView() -> UIView {
        
        let view = UIView.init(frame: self.getMenuItemsFrame())
        
        view.layer.masksToBounds = true
        
        view.layer.cornerRadius = 15
        
        let coll = self.getCollectionView()
        coll.frame = view.bounds
        self.collectionView = coll
            
        let eff = UIVisualEffectView.init(effect: UIBlurEffect.init(style: .dark))
        eff.frame = view.bounds
        eff.contentView.addSubview(coll)
        view.addSubview(eff)
        
        let setBtn = UIButton.init(type: .custom)
        setBtn.bounds = CGRect.init(x: 0, y: 0, width: 20, height: 20)
        setBtn.center = CGPoint.init(x: view.bounds.size.width - 20, y: 20)
        setBtn.setBackgroundImage(flyViewImage(name: "KKFlyViewSetting.png"), for: .normal)
        setBtn.addTarget(self, action: #selector(set), for: .touchUpInside)
        view.addSubview(setBtn)
        
        return view
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.showingItems.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! KKFlyViewCell
        cell.showData(viewModel.showingItems[indexPath.row], dash: false)
        if viewModel.showingItems[indexPath.row].isPHItem {
            cell.imageView.image = nil
        }
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.viewModel.selectedIndex(indexPath.row)
    }
}

extension KKFlyWindow: KKFlyViewModelDelegate {
    
    public func reloadData() {
        self.collectionView.reloadData()
    }
}

open class KKFlyViewMenuView: UIView {
    
    open class func defaultMenuView() -> KKFlyViewMenuView {
        let window = KKFlyViewMenuView.init(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        window.layer.cornerRadius = 13
        window.layer.masksToBounds = true
        return window
    }
    
    override open func draw(_ rect: CGRect) {
        
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

private class KKFlyCollectionView: UICollectionView {
    
    var touchBegin: (()->Void)?
}

fileprivate func flyViewSourcePath(name: String) -> String? {
    let named = "KKFlyView.bundle/\(name)"
    if let path = Bundle.main.path(forResource: named, ofType: nil) {
        return path
    }
    if let path = Bundle.init(for: KKFlyView.self).path(forResource: named, ofType: nil) {
        return path
    }
    let fullNamed = "Frameworks/KKFlyView.framework/\(named)"
    if let path = Bundle.main.path(forResource: fullNamed, ofType: nil) {
        return path
    }
    return nil
}

func flyViewImage(name: String) -> UIImage? {
    if let path = flyViewSourcePath(name: name) {
        return UIImage(contentsOfFile: path)
    }
    return nil
}

fileprivate func appIcon() -> UIImage? {
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
