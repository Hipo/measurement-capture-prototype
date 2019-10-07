//
//  File.swift
//  PoseNet
//
//  Created by Taylan Pince on 2019-10-07.
//  Copyright © 2019 Hipo. All rights reserved.
//

import UIKit


class ZoneErrorView: UIView {
    
    var showError = true {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.isOpaque = false
        self.backgroundColor = .clear
        self.alpha = 0.5
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        context.setFillColor(UIColor.clear.cgColor)
//        context.clear(rect)
        context.fill(rect)
        context.addEllipse(in: rect)
        context.setFillColor(showError ? UIColor.red.cgColor : UIColor.green.cgColor)
        context.fillPath()
    }
    
}
