//
//  ViewController.swift
//  KKFlyView
//
//  Created by 王铁山 on 2018/5/11.
//  Copyright © 2019 onety. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var window: KKFly?
    
    var tf: UITextField = UITextField.init(frame: .zero)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tf.frame = .init(x: 10, y: 100, width: 100, height: 50)
        view.addSubview(tf)
        
        view.backgroundColor = .white
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            let items = (0..<2).map({KKFlyViewItem.init(name: "\($0)", image: UIImage(named: "a"))})
            self.window = KKFly.getDefault(viewType: .window, items: items, onSelected: { [weak self] (item) in
                self?.flyViewSelectedItem(item)
            })
            self.view.addSubview(self.window!.view)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tf.becomeFirstResponder()
    }
    
    func flyViewSelectedItem(_ item: KKFlyViewItem) {
        
    }

}

