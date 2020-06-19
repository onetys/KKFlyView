//
//  KKFlyViewCollectionLayout.swift
//  KKFlyViewCollectionLayout
//
//  Created by 王铁山 on 2017/3/11.
//  Copyright © 2017年 kk. All rights reserved.
//

import Foundation

import UIKit


/// 此种 collectionViewLayout 可以模仿苹果 辅助按钮 的布局
open class KKFlyViewCollectionLayout: UICollectionViewLayout {
    
    override open func prepare() {
        super.prepare()
    }
    
    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        guard let coll = self.collectionView, let dataSource = coll.dataSource else {
            return nil
        }
        
        let count = dataSource.collectionView(coll, numberOfItemsInSection: 0)
        
        guard count > 0 else{
            return nil
        }
        
        var atts = [UICollectionViewLayoutAttributes]()
        
        for i in 0...count - 1 {
            
            if let att = self.layoutAttributesForItem(at: IndexPath.init(row: i, section: 0)) {
             
                atts.append(att)
            }
            
        }
        
        return atts
    }
    
    override open func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override open func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        guard let coll = self.collectionView, let dataSource = coll.dataSource else {
            return nil
        }
        
        let count = dataSource.collectionView(coll, numberOfItemsInSection: indexPath.section)
        
        guard count > 0 else{
            return nil
        }
        
        let width: CGFloat = 60
        
        let att = UICollectionViewLayoutAttributes.init(forCellWith: indexPath)
        
        att.size = CGSize.init(width: width, height: width)
        
        att.center = centerAt(indexPath.row, count: count)
		
		if att.center == .zero {
			att.isHidden = true
		}
        
        return att
    }
    
    open func centerAt(_ index: Int, count: Int) -> CGPoint {
        
        let scrollSize = self.collectionView!.bounds.size
        
        let width: CGFloat = 60
        
        let allWidth = scrollSize.width
        
        /// 宽度下，除去 item 剩余的宽度
        let left = allWidth - 3 * width
        
        // item 之间的间距
        let itemPad = left / 4.0
        
        if count == 1 {
            return CGPoint.init(x: scrollSize.width / 2.0, y: scrollSize.height / 2.0)
        }
        
        else if count >= 2 && count <= 4 {
            
            if index == 0 {
                return CGPoint.init(x: itemPad + width / 2.0, y: scrollSize.height / 2.0)
            } else if index == 1 {
                return CGPoint.init(x: scrollSize.width - itemPad - width / 2.0, y: scrollSize.height / 2.0)
            } else if index == 2 {
                return CGPoint.init(x: scrollSize.width / 2.0, y: width / 2.0 + itemPad)
            } else if index == 3 {
                return CGPoint.init(x: scrollSize.width / 2.0, y: scrollSize.height - width / 2.0 - itemPad)
            }
        } else if count > 5 {
            
            let moreDown: CGFloat = -10
            
            if index == 0 {
                return CGPoint.init(x: itemPad + width / 2.0, y: allWidth - itemPad - width - width / 2.0 - moreDown)
            } else if index == 1 {
                return CGPoint.init(x: scrollSize.width - itemPad - width / 2.0, y: itemPad + width + width / 2.0)
            } else if index == 2 {
                return CGPoint.init(x: itemPad + width / 2.0, y: itemPad + width + width / 2.0)
            } else if index == 3 {
                return CGPoint.init(x: scrollSize.width - itemPad - width / 2.0, y: allWidth - itemPad - width - width / 2.0 - moreDown)
            } else if index == 4 {
                return CGPoint.init(x: allWidth / 2.0, y: itemPad + width / 2.0)
            } else if index == 5 {
                return CGPoint.init(x: allWidth / 2.0, y: allWidth - itemPad - width / 2.0)
			} else {
				return CGPoint.zero
			}
        }
        return CGPoint.zero
    }
    
}





