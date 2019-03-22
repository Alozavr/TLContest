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

final class Deallocator {
    var closure: () -> Void
    init(_ closure: @escaping () -> Void) {
        self.closure = closure
    }
    deinit {
        closure()
    }
}

private var associatedObjectAddr = ""

extension UIView {
    
    open override func method(for aSelector: Selector!) -> IMP! {
        if self is UINavigationBar, aSelector == #selector(UINavigationBar.draw(_:)) {
            setupThemeNotification()
        }
        return super.method(for: aSelector)
    }
    
    @objc convenience init(tl_frame: CGRect) {
        self.init(tl_frame: tl_frame)
        let deallocator = Deallocator { [weak self] in
            self?.removeThemeNotification()
        }
        objc_setAssociatedObject(self, &associatedObjectAddr, deallocator, .OBJC_ASSOCIATION_RETAIN)
        setupThemeNotification()
    }
    
    static func swizzleInitImplementation() {
        let originalSelector = #selector(UIView.init(frame:))
        let swizzledSelector = #selector(UIView.init(tl_frame:))

        guard let originalMethod = class_getInstanceMethod(self, originalSelector),
        let swizzledMethod = class_getInstanceMethod(self, swizzledSelector) else {
            fatalError("The methods are not found!")
        }

        let didAddMethod = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
        if didAddMethod {
            class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    }
    
    private func setupThemeNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateTheme), name: NSNotification.Name.updateTheme, object: nil)
    }
    
    private func removeThemeNotification() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.updateTheme, object: nil)
    }
    
    @objc private func updateTheme() {
        switch ThemeManager.shared.theme {
        case .dark:
            Colors.shared.primaryColor = UIColor(hexString: "232f3e")
            Colors.shared.secondaryAColor = UIColor(hexString: "354659")
            Colors.shared.secondaryBColor = UIColor(hexString: "1d2a3a")
            Colors.shared.secondaryCColor = UIColor.white
            Colors.shared.backgroundColor = UIColor(hexString: "19222d")
            Colors.shared.textColor = UIColor.white
            Colors.shared.statusBarStyle = .lightContent
            Colors.shared.barStyle = .blackTranslucent
            
            applyColors()
        case .light:
            Colors.shared.primaryColor = UIColor.white
            Colors.shared.secondaryAColor = UIColor(hexString: "cbd3dd")
            Colors.shared.secondaryBColor = UIColor(hexString: "f6f8fa")
            Colors.shared.secondaryCColor = UIColor(hexString: "77777c")
            Colors.shared.backgroundColor = UIColor(hexString: "fafafa")
            Colors.shared.textColor = UIColor.black
            Colors.shared.statusBarStyle = .default
            Colors.shared.barStyle = .default
            
            applyColors()
        }
    }
    
    private func applyColors() {
        if let vc = self.parentViewController {
            vc.setNeedsStatusBarAppearanceUpdate()
        }
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
            navBar.barStyle = Colors.shared.barStyle
        }
    }
}

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
