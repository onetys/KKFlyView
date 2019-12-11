//
//  ViewController.swift
//  KKFlyView
//
//  Created by 王铁山 on 2018/5/11.
//  Copyright © 2019 onety. All rights reserved.
//

import UIKit

class ViewController: UIViewController, KKFlyViewDelegate {
    
    var window: KKFly?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            let items = (0..<2).map({KKFlyViewItem.init(name: "\($0)", image: UIImage(named: "a"))})
            self.window = KKFly.getDefault(delegate: self, viewType: .view, items: items)
            self.view.addSubview(self.window!.view)
        }
    }
    
    func flyViewSelectedItem(_ item: KKFlyViewItem) {
        
    }

}

