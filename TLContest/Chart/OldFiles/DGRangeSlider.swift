//
//  RangeSlider.swift
//  TLContest
//
//  Created by Dmitry Grebenschikov on 12/03/2019.
//  Copyright © 2019 dd-team. All rights reserved.
//

import UIKit

class DGRangeSlider: UIView {
    
    weak var leftToggle: UIView!
    weak var rightToggle: UIView!
    weak var centerToggle: UIView!
    
    var toggleWidth: CGFloat = 10 {
        didSet {
            initToggles()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func initToggles() {
        subviews.forEach({ $0.removeFromSuperview() })
        let leftToggle = UIView(frame: CGRect.zero)
        let rightToggle = UIView(frame: CGRect.zero)
        let centerToggle = UIView(frame: CGRect.zero)

        self.leftToggle = leftToggle
        self.rightToggle = rightToggle
        self.centerToggle = centerToggle
        
        centerToggle.translatesAutoresizingMaskIntoConstraints = false
        addSubview(centerToggle)
        
        for (i, toggle) in [leftToggle, rightToggle].enumerated() {
            toggle.translatesAutoresizingMaskIntoConstraints = false
            addSubview(toggle)
            toggle.tag = i
            toggle.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
            
            let bindingAnchor = i == 0 ? toggle.leadingAnchor : toggle.trailingAnchor
            let toBindAnchor = i == 0 ? leadingAnchor : trailingAnchor
            
            NSLayoutConstraint.activate([
                bindingAnchor.constraint(equalTo: toBindAnchor),
                toggle.topAnchor.constraint(equalTo: topAnchor),
                toggle.bottomAnchor.constraint(equalTo: bottomAnchor),
                toggle.widthAnchor.constraint(equalToConstant: toggleWidth)
                ])
        }
        
        NSLayoutConstraint.activate([
            centerToggle.leadingAnchor.constraint(equalTo: leftToggle.trailingAnchor),
            centerToggle.topAnchor.constraint(equalTo: topAnchor),
            centerToggle.bottomAnchor.constraint(equalTo: bottomAnchor),
            centerToggle.trailingAnchor.constraint(equalTo: rightToggle.leadingAnchor)
            ])
    }
    
    func setup() {
        layer.borderColor = UIColor.gray.cgColor
        layer.borderWidth = 1
        initToggles()
    }
    
}
