//
//  KKFlyViewItemExtension.swift
//  KKFlyView
//
//  Created by 王铁山 on 2019/12/10.
//  Copyright © 2019 onety. All rights reserved.
//

import Foundation

extension KKFlyViewItem {
    
    var isPHItem: Bool {
        return name == "ph"
    }
    
    class func isPHItem(name: String) -> Bool {
        return name == "ph"
    }
    
    class func phItem() -> KKFlyViewItem {
        let item = KKFlyViewItem(name: "ph", image: nil)
        item.image = flyViewImage(name: "KKFlyViewAdd.png")
        return item
    }
}
