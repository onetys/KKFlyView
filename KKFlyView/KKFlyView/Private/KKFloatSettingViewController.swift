//
//  KKFlySettingViewController.swift
//  KKFlySettingViewController
//
//  Created by 王铁山 on 2017/3/12.
//  Copyright © 2017年 kk. All rights reserved.
//

import Foundation

import UIKit

open class KKFlySettingViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var dismissBlock: (()->Void)?
    
    var resultBlock: (([KKFlyViewItem])->Void)?
    
    var items: [KKFlyViewItem] = []
    
    var showItems: [KKFlyViewItem] = []
    
    lazy var collectionView: UICollectionView = {
        let screenWidth = min(UIScreen.main.bounds.size.width, 441)
        let realWidth = screenWidth - 2 * 10
        let y: CGFloat = 64
        let frame = CGRect.init(x: 10, y: y, width: realWidth, height: realWidth)
        let c = UICollectionView.init(frame: frame, collectionViewLayout: KKFlyViewCollectionLayout())
        c.delegate = self
        c.dataSource = self
        c.register(KKFlyViewCell.self, forCellWithReuseIdentifier: "cellID")
        c.backgroundColor = UIColor.init(red: 239.0 / 255.0, green: 239 / 255.0, blue: 244 / 255.0, alpha: 1)
        return c
    }()
    
    var lastStepper: Double = 50
    
    required public init(items: [KKFlyViewItem], showItems: [KKFlyViewItem]) {
        super.init(nibName: nil, bundle: nil)
        self.items = items
        self.showItems = showItems
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "自定义功能"

        self.automaticallyAdjustsScrollViewInsets = false
        
        if #available(iOS 11.0, *) {
            self.collectionView.contentInsetAdjustmentBehavior = .never
        }
        
        view.backgroundColor = UIColor.init(red: 239.0 / 255.0, green: 239 / 255.0, blue: 244 / 255.0, alpha: 1)
        view.addSubview(self.collectionView)
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .cancel, target: self, action: #selector(cancelSetting))
        
        let editorView = UIView.init(frame: CGRect.init(x: 0, y: self.collectionView.frame.maxY + 60, width: self.view.bounds.size.width, height: 40))
        editorView.backgroundColor = UIColor.white
        
        let seg = UIStepper.init()
        seg.center = CGPoint.init(x: editorView.bounds.size.width - 80, y: editorView.bounds.size.height / 2.0)
        seg.maximumValue = 100
        seg.minimumValue = 0
        seg.value = self.lastStepper
        seg.addTarget(self, action: #selector(change(_:)), for: .valueChanged)
        editorView.addSubview(seg)
        self.view.addSubview(editorView)
    }
    
    @objc func cancelSetting() {
        self.dismiss(animated: true, completion: nil)
        self.dismissBlock?()
    }
    
    @objc func change(_ seg: UIStepper) {
        if seg.value > self.lastStepper {
            self.add()
        } else if seg.value < self.lastStepper {
            self.delete()
        }
        self.lastStepper = seg.value
    }
    
    func reloadData() {
        self.collectionView.reloadData()
        self.resultBlock?(self.showItems)
    }
    
    func add() {
        guard self.showItems.count < 6 else { return }
        self.showItems.append(KKFlyViewItem.phItem())
        reloadData()
    }
    
    func delete() {
        showItems.removeLast(1)
        if showItems.isEmpty {
            showItems.append(KKFlyViewItem.phItem())
        }
        reloadData()
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.showItems.count
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellID", for: indexPath) as! KKFlyViewCell
        cell.showData(showItems[indexPath.row], dash: true)
        return cell
    }
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard showItems[indexPath.row].isPHItem else {
            return
        }
        let list = KKFlyFuncListVC.init(items: items, showingNames: showItems.map({$0.name}))
        list.selectedItem = { [weak self] (item) in
            guard let wSelf = self else { return }
            wSelf.showItems[indexPath.row] = item
            wSelf.reloadData()
        }
        self.navigationController?.pushViewController(list, animated: true)
    }
}

private class KKFlyFuncListVC: UITableViewController {
    
    var showingNames: [String] = []
    
    var items: [KKFlyViewItem] = []
    
    var selectedItem: ((KKFlyViewItem)-> Void)?
    
    init(items: [KKFlyViewItem], showingNames:[String]) {
        super.init(nibName: nil, bundle: nil)
        self.items = items
        self.showingNames = showingNames
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        self.title = "功能选择"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "cellId")
        if cell == nil {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: "cellId")
        }
        let name = self.items[indexPath.row].name
        cell.textLabel?.text = name
        cell.textLabel?.textColor = self.showingNames.contains(name) ? UIColor.gray : UIColor.black
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let item = self.items[indexPath.row]
        
        if self.showingNames.contains(item.name) {
            tableView.deselectRow(at: indexPath, animated: true)
        } else {
            self.selectedItem?(item)
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
}






