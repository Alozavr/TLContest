//
//  Theme.swift
//  TLContest
//
//  Created by Alexander Shoshiashvili on 18/03/2019.
//  Copyright © 2019 dd-team. All rights reserved.
//

import UIKit

enum Theme: String {
    case light
    case dark
}

class ThemeManager {
    
    static var shared = ThemeManager()
    
    var theme: Theme {
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "current_theme_key")
            changeTheme()
        }
        get {
            let themeString = UserDefaults.standard.string(forKey: "current_theme_key") ?? ""
            return Theme(rawValue: themeString) ?? .light
        }
    }
    
    private func changeTheme() {
        NotificationCenter.default.post(name: NSNotification.Name.updateTheme, object: nil)
    }
    
    func setupTheme() {
        changeTheme()
    }
    
    func switchTheme() {
        switch theme {
        case .light:
            theme = .dark
        case .dark:
            theme = .light
        }
    }
    
    init() {}
}


extension NSNotification.Name {
    static var updateTheme = NSNotification.Name("UpdateThemeNotification")
}

extension UIView {
    
    func setupThemeNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateTheme), name: NSNotification.Name.updateTheme, object: nil)
    }
    
    fileprivate func removeThemeNotification() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.updateTheme, object: nil)
    }
    
    @objc private func updateTheme() {
        switch ThemeManager.shared.theme {
        case .dark:
            Colors.shared.primaryColor = UIColor(hexString: "232f3e")
            Colors.shared.secondaryAColor = UIColor(hexString: "354659")
            Colors.shared.secondaryBColor = UIColor(hexString: "1d2a3a")
            Colors.shared.backgroundColor = UIColor(hexString: "19222d")
            Colors.shared.textColor = UIColor.white
            
            applyColors()
        case .light:
            Colors.shared.primaryColor = UIColor.white
            Colors.shared.secondaryAColor = UIColor(hexString: "cbd3dd")
            Colors.shared.secondaryBColor = UIColor(hexString: "f6f8fa")
            Colors.shared.backgroundColor = UIColor(hexString: "fafafa")
            Colors.shared.textColor = UIColor.black
            
            applyColors()
        }
    }
    
    private func applyColors() {
        if let tableView = self as? UITableView {
            tableView.backgroundColor = Colors.shared.backgroundColor
        } else if let cell = self as? UITableViewCell {
            cell.contentView.backgroundColor = Colors.shared.primaryColor
            cell.backgroundColor = Colors.shared.primaryColor
            for subview in cell.subviews + cell.contentView.subviews {
                if let label = subview as? UILabel {
                    label.textColor = Colors.shared.textColor
                    label.backgroundColor = Colors.shared.primaryColor
                } else if let chartView = subview as? ChartOverview {
                    chartView.overview.backgroundColor = Colors.shared.primaryColor
                    chartView.slider.backgroundColor = .clear
                    chartView.slider.updateLayerFrames()
                } else if let graph = subview as? DetailedChartView {
                    graph.backgroundColor = Colors.shared.primaryColor
                    graph.chartView.backgroundColor = Colors.shared.primaryColor
                }
            }
        } else if let navBar = self as? UINavigationBar {
            navBar.backgroundColor = Colors.shared.primaryColor
            navBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: Colors.shared.textColor]
            navBar.tintColor = Colors.shared.textColor
            navBar.barTintColor = Colors.shared.primaryColor
        }
    }
    
}
