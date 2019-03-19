//
//  ButtonCell.swift
//  TLContest
//
//  Created by Alexander Shoshiashvili on 18/03/2019.
//  Copyright © 2019 dd-team. All rights reserved.
//

import UIKit

class ButtonCell: UITableViewCell {
    
    typealias ThemeTexts = [Theme: String]
    
    weak var button: UIButton!
    
    var texts: ThemeTexts = [:]
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        initButtonView()
        selectionStyle = .none
        contentView.backgroundColor = Colors.shared.primaryColor
    }
    
    func configure(texts: ThemeTexts) {
        let text = texts[ThemeManager.shared.theme]
        button.setTitle(text, for: .normal)
        self.texts = texts
    }
    
    private func initButtonView() {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        addSubview(button)
        
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
        
        button.setTitleColor(UIColor(hexString: "2682e5"), for: .normal)
        button.addTarget(self, action: #selector(handleButtonAction), for: .touchUpInside)
        
        self.button = button
        
        NSLayoutConstraint.activate([
            button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            button.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            button.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            button.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            ])
    }
    
    // MARK: - Actions
    
    @objc func handleButtonAction() {
        ThemeManager.shared.switchTheme()
        configure(texts: texts)
    }
}
