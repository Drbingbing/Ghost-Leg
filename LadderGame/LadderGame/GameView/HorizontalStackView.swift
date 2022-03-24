//
//  PlayerStackView.swift
//  LadderGame
//
//  Created by Bing Bing on 2022/3/21.
//

import UIKit

class HorizontalStackView: UIView {

    var positions: [CGPoint] = [] {
        didSet { self.setNeedsLayout() }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        for (position, subview) in zip(positions, subviews) {
            
            subview.frame = CGRect(x: position.x, y: 0, width: 64, height: 64)
        }
    }
}
