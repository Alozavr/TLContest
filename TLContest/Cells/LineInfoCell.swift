//
//  LineInfoCell.swift
//  TLContest
//
//  Created by Dmitry Grebenschikov on 12/03/2019.
//  Copyright © 2019 dd-team. All rights reserved.
//

import UIKit

class LineInfoCell: UITableViewCell {
    
    weak var nameLabel: UILabel!
    weak var colorView: UIView!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        setupThemeNotification()
        initColorView()
        initLabelView()
        selectionStyle = .none
    }
    
    func configure(color: UIColor, text: String, isChecked: Bool) {
        colorView.backgroundColor = color
        nameLabel.text = text
        setIsChecked(isChecked)
    }
    
    func setIsChecked(_ checked: Bool) {
        accessoryType = checked ? .checkmark : .none
    }
    
    private func initColorView() {
        let colorView = UIView()
        colorView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(colorView)
        colorView.layer.cornerRadius = 8
        self.colorView = colorView
        
        NSLayoutConstraint.activate([
            colorView.heightAnchor.constraint(equalToConstant: 24),
            colorView.widthAnchor.constraint(equalToConstant: 24),
            colorView.centerYAnchor.constraint(equalTo: centerYAnchor),
            colorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16)
            ])
    }
    
    private func initLabelView() {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        self.nameLabel = label
        
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            label.leadingAnchor.constraint(equalTo: colorView.trailingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 16)
            ])
    }
}
