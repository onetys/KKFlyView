//
//  KKFly.swift
//  KKFlyView
//
//  Created by 王铁山 on 2017/3/9.
//  Copyright © 2017年 kk. All rights reserved.
//

import UIKit

import Foundation

extension KKFly {
    
    public enum ViewType {
        
        case window
        
        case view
    }
	
	public enum LayoutType {
		
		/// 苹果小圆点的布局方式
		case phone
		
		/// 列表方式
		case list
	}
}

open class KKFly: NSObject {

    /// 默认大小 (2, 100, 60, 60)
    open class func getDefault(viewType: KKFly.ViewType, items: [KKFlyViewItem], onSelected: ((KKFlyViewItem)->Void)?) -> KKFly {
		let window = KKFly.init(frame: CGRect.init(x: UIScreen.main.bounds.size.width - 62, y: UIScreen.main.bounds.size.height / 2.0 - 30, width: 60, height: 60), viewType: viewType, items: items, project_key: nil)
        window.onSelected = onSelected
        return window
    }
	
	/// 默认大小 (2, 100, 60, 60)
	open class func getDefault(viewType: KKFly.ViewType, project_key: String, items: [KKFlyViewItem], onSelected: ((KKFlyViewItem)->Void)?) -> KKFly {
		let window = KKFly.init(frame: CGRect.init(x: UIScreen.main.bounds.size.width - 62, y: UIScreen.main.bounds.size.height / 2.0 - 30, width: 60, height: 60), viewType: viewType, items: items, project_key: project_key)
		window.onSelected = onSelected
		return window
	}
    
	/// 点击菜单按钮的回调
    open var onSelected: ((KKFlyViewItem)->Void)? {
        didSet {
            viewModel.onSelected = onSelected
        }
    }
	
	/// 布局方式
	open var layoutType: LayoutType = .phone
    
    /// 移动窗口的手势
    open var panGestureRecognizer: UIPanGestureRecognizer!
	
	/// 用来区分多个地方使用的时候情况
	open var project_key: String {
		get {
			return viewModel.project_key
		}
		set {
			viewModel.project_key = newValue
		}
	}
	
	/// view
	@objc open var view: UIView!
	
	fileprivate let edg: CGFloat = 10
	fileprivate var width: CGFloat {
		let screenWidth = UIScreen.main.bounds.size.width
		let screenHeight = UIScreen.main.bounds.size.height
		return min(screenWidth, screenHeight, 441) - 2 * edg
	}
	fileprivate var padding: CGFloat {
		return (width - 3 * itemWidth) / 4.0
	}
	fileprivate let itemWidth: CGFloat = 60
	fileprivate let titleHeight: CGFloat = 30
    
	public init(frame: CGRect, viewType: KKFly.ViewType, items: [KKFlyViewItem], project_key: String?) {
        super.init()
        
		viewModel = KKFlyViewModel.init(delegate: self, viewType: viewType, items: items, project_key: project_key)
        viewModel.lastFrame = frame
        
        if viewType == .view {
            let v = KKView(frame: frame)
            v.delegate = self
            v.layer.zPosition = 10
            v.layer.masksToBounds = true
            view = v
        } else {
            let window = KKWindow.init(frame: frame)
            window.delegate = self
            window.isHidden = false
            window.windowLevel = .statusBar
            window.layer.cornerRadius = 13
            window.layer.masksToBounds = true
            view = window
        }
        
        panGestureRecognizer = UIPanGestureRecognizer.init(target: self, action: #selector(pan(_:)))
        view.addGestureRecognizer(panGestureRecognizer)
        
        commitInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
	
	open override func value(forKeyPath keyPath: String) -> Any? {
		if keyPath == "_view" {
			return view
		}
		return super.value(forKeyPath: keyPath)
	}

    // MARK: - expend
    open func expend() {
        
        if viewModel.expending { return }
        
        menunView.isHidden = true
        
        viewModel.expending = true
        
        viewModel.lastFrame = view.frame
        
        view.frame = UIScreen.main.bounds
        
        if meunItemsView == nil {
            meunItemsView = getMenuItemsView()
            view.addSubview(meunItemsView)
        } else {
            meunItemsView.isHidden = false
        }
        
        collectionView.reloadData()
        
        meunItemsView.frame = viewModel.lastFrame
        
        viewModel.animating = true
        UIView.animate(withDuration: 0.25, animations: {
            self.meunItemsView.frame = self.getMenuItemsFrame()
        }, completion: { (finsh) in
            self.viewModel.animating = false
        }) 
    }
    
    open func close() {
        if !viewModel.expending {
            return
        }
        viewModel.expending = false
        if let menu = meunItemsView {
            viewModel.animating = true
            UIView.animate(withDuration: 0.25, animations: {
                menu.frame = self.viewModel.lastFrame
            }, completion: { (finsh) in
                self.view.frame = self.viewModel.lastFrame
                self.menunView.isHidden = false
                self.viewModel.lastFrame = nil
                menu.isHidden = true
                self.viewModel.animating = false
            }) 
        } else {
            view.frame = viewModel.lastFrame
            menunView.isHidden = false
            viewModel.lastFrame = nil
        }
        
    }
    
    /**
     show setting vc
     */
    @objc open func set() {
        close()
        guard !viewModel.setting else {
            return
        }
        viewModel.setting = true
		let settingVC = KKFlySettingViewController(items: viewModel.items, showItems: viewModel.showingItems, layoutType: layoutType)
        settingVC.dismissBlock = { [weak self] in
            self?.viewModel.setting = false
        }
        settingVC.resultBlock = { [weak self] (items) in
            self?.viewModel.updateShowingItems(items: items)
        }
		let na = UINavigationController.init(rootViewController: settingVC)
		na.modalPresentationStyle = .fullScreen
		viewModel.getValidPresentingVC()?.present(na, animated: true, completion: nil)
    }
    
    // MARK: - private
    
    fileprivate var viewModel: KKFlyViewModel!
    
    fileprivate var menunView: KKFlyViewMenuView!
    
    fileprivate var meunItemsView: UIView!
    
    fileprivate var collectionView: UICollectionView!
    
    fileprivate lazy var timer: Timer = {
        let time = Timer.init(timeInterval: 4.0, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        time.fireDate = Date.distantFuture
        RunLoop.current.add(time, forMode: .common)
        return time
    }()
    
    
    fileprivate func commitInit() {
        menunView = KKFlyViewMenuView.defaultMenuView()
        view.addSubview(menunView)
        menunView.alpha = 0.5
    }
}

// MARK: - action
extension KKFly: ViewDelegate  {
    
    @objc fileprivate func timerAction() {
        UIView.animate(withDuration: 0.25, animations: {
            self.menunView.alpha = 0.5
        })
        timer.fireDate = Date.distantFuture
    }
    
    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        timer.fireDate = Date.distantFuture
        menunView.alpha = 1.0
    }
    
    func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !viewModel.animating else { return }
        menunView.alpha = 1.0
        timer.fireDate = Date().addingTimeInterval(2.0)
        if viewModel.expending {
            if let first = touches.first, let meunItemV = meunItemsView {
                if !meunItemV.bounds.contains(first.location(in: meunItemV)) {
                    close()
                    return
                }
            }
        }
        expend()
    }
    
    @objc fileprivate func pan(_ pan: UIPanGestureRecognizer) {
        
        if viewModel.expending {
            return
        }
        
        let t = pan.translation(in: view)
        
        let width = view.frame.size.width
        
        let height = view.frame.size.height
        
        let swidth = UIScreen.main.bounds.width
        
        let sheight = UIScreen.main.bounds.height
        
        let x = view.frame.origin.x
        
        let y = view.frame.origin.y
        
        view.frame = CGRect(x: x + t.x, y: y + t.y, width: width, height: height)
        
        pan.setTranslation(CGPoint.zero, in: view)
        
        if pan.state == .ended || pan.state == .cancelled {
            
            menunView.alpha = 1.0
            
            let center = view.center
            
            timer.fireDate = Date().addingTimeInterval(4.0)
            
            UIView.animate(withDuration: 0.25, animations: {
                var cx: CGFloat = 0.0
                var cy: CGFloat = 0.0
                if center.x < swidth / 2.0 {
                    cx = width / 2.0 + 2
                } else {
                    cx = swidth - width / 2.0 - 2
                }
                
				if self.view.frame.origin.y <= 50 {
					cy = height / 2.0 + 34
				} else if y >= sheight - height - 30 {
					cy = sheight - height / 2.0 - 2
				} else {
					cy = y
				}
				
				self.view.center = CGPoint.init(x: cx, y: CGFloat.maximum(height / 2.0 + 34, cy))
            })
        }
    }
}

// MARK: - collection view

extension KKFly: UICollectionViewDelegate, UICollectionViewDataSource {
    
    fileprivate func getCollectionView() -> UICollectionView {
		let layout: UICollectionViewLayout
		if layoutType == .list {
			let pad = self.padding
			let l = UICollectionViewFlowLayout.init()
			l.sectionInset = UIEdgeInsets.init(top: pad, left: pad, bottom: pad, right: pad)
			l.minimumLineSpacing = pad
			l.minimumInteritemSpacing = pad
			l.itemSize = CGSize(width: itemWidth, height: itemWidth + titleHeight)
			layout = l
		} else {
			layout = KKFlyViewCollectionLayout()
		}
        let coll = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: layout)
		if layoutType == .list {
			coll.alwaysBounceVertical = true
		}
		coll.showsVerticalScrollIndicator = false
		coll.showsHorizontalScrollIndicator = false
        coll.delegate = self
        coll.dataSource = self
        coll.backgroundColor = UIColor.clear
        coll.register(KKFlyViewCell.classForCoder(), forCellWithReuseIdentifier: "cellId")
        return coll
    }
    
    fileprivate func getMenuItemsFrame() -> CGRect {
		let width = self.width
        let screenWidth = UIScreen.main.bounds.size.width
        let screenHeight = UIScreen.main.bounds.size.height
        let x = (screenWidth - width) / 2.0
        let y = (screenHeight - width) / 2.0
        return CGRect.init(x: x, y: y, width: width, height: width)
    }
    
    fileprivate func getMenuItemsView() -> UIView {
        
        let view = UIView.init(frame: getMenuItemsFrame())
        
        view.layer.masksToBounds = true
        
        view.layer.cornerRadius = 15
        
        let coll = getCollectionView()
        coll.frame = view.bounds
        collectionView = coll
            
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
		cell.showData(viewModel.showingItems[indexPath.row], dash: false, showLabel: layoutType == .list, labelHeight: self.titleHeight)
        if viewModel.showingItems[indexPath.row].isPHItem {
            cell.imageView.image = nil
        }
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.selectedIndex(indexPath.row)
    }
}

extension KKFly: KKFlyViewModelDelegate {
    
    public func reloadData() {
        collectionView.reloadData()
    }
}

protocol ViewDelegate: class {
    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
}
fileprivate class KKView: UIView {
    
    weak var delegate: ViewDelegate?
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.touchesBegan(touches, with: event)
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.touchesEnded(touches, with: event)
    }
}
fileprivate class KKWindow: UIWindow {
    weak var delegate: ViewDelegate?
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.touchesBegan(touches, with: event)
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.touchesEnded(touches, with: event)
    }
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
