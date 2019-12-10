//
//  KKFlyView.swift
//  KKFlyView
//
//  Created by 王铁山 on 2018/5/11.
//  Copyright © 2018年 king. All rights reserved.
//

import Foundation

import UIKit

open class KKFlyView: UIView {
    
    /// 移动窗口的手势
    open var panGestureRecognizer: UIPanGestureRecognizer!
    
    /// 当拖动位置时自动调整 alpha
    open var autoJustAlpha: Bool = true
    
    /// 设置所在的容器了，用来定位边缘，不设置默认 superView
    weak open var containerView: UIView?
    
    /// 构造
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        self.panGestureRecognizer = UIPanGestureRecognizer.init(target: self, action: #selector(pan(_:)))
        self.addGestureRecognizer(self.panGestureRecognizer)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    @objc fileprivate func pan(_ pan: UIPanGestureRecognizer) {
        
        guard let spView = self.containerView ?? self.superview else { return }
        
        let t = pan.translation(in: self)
        
        let width = self.frame.size.width
        
        let height = self.frame.size.height
        
        let swidth = spView.frame.size.width
        
        let sheight = spView.frame.size.height
        
        let x = self.frame.origin.x
        
        let y = self.frame.origin.y
        
        self.frame = CGRect(x: x + t.x, y: y + t.y, width: width, height: height)
        
        pan.setTranslation(CGPoint.zero, in: self)
        
        if pan.state == .ended || pan.state == .cancelled {
            
            if autoJustAlpha {
                
                self.alpha = 1.0
                
            }
            
            let center = self.center
            
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
        } else if pan.state == .began || pan.state == .changed {
            
            if autoJustAlpha {
                
                self.alpha = 0.6
                
            }
        }
    }
}
