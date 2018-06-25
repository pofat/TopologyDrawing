//
//  CircleView.swift
//  TopologyMusicNode
//
//  Created by Pofat Tseng on 2018/3/18.
//  Copyright © 2018年 Pofat. All rights reserved.
//

import UIKit

@IBDesignable class CircleView: UIView {

    var label: UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        label.textColor = .black
        label.center = center
        label.textAlignment = .center
        label.frame = frame
        addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        label.textColor = .black
        label.center = center
        addSubview(label)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.size.width/2
        clipsToBounds = true
    }
    
    func setValue(text: String) {
        label.text = text
    }
}
