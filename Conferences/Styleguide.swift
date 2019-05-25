//
//  Styleguide.swift
//  Conferences
//
//  Created by Zagahr on 23/03/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import UIKit



class StyleGuide {

    func setup() {
        setupNavigationBar()
    }

    private func setupNavigationBar() {
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().prefersLargeTitles = true
    }
}

extension UIColor {

    static var primaryText: UIColor {
        return UIColor(white: 0.9, alpha: 1.0)
    }

    static var secondaryText: UIColor {
        return UIColor(white: 0.75, alpha: 1.0)
    }

    static var tertiaryText: UIColor {
        return UIColor(white: 0.55, alpha: 1.0)
    }

    static var panelBackground: UIColor {
        return UIColor(red:0.13, green:0.13, blue:0.13, alpha:1.0)
    }

    static var darkWindowBackground: UIColor {
        return UIColor(red:0.12, green:0.12, blue:0.12, alpha:1.0)
    }

    static var elementBackground: UIColor {
        return UIColor(red:0.09, green:0.09, blue:0.09, alpha:1.0)
    }

    static var inactiveButton: UIColor {
        return UIColor(red:0.09, green:0.09, blue:0.09, alpha:1.0)
    }

    static var activeButton: UIColor {
        return UIColor(red:0.11, green:0.11, blue:0.11, alpha:1.0)
    }

    static var prefsPrimaryText: UIColor {
        return UIColor(red: 0.90, green: 0.90, blue: 0.90, alpha: 1.00)
    }

    static var prefsSecondaryText: UIColor {
        return UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 1.00)
    }

    static var prefsTertiaryText: UIColor {
        return UIColor(red: 0.49, green: 0.49, blue: 0.49, alpha: 1.00)
    }

    static var errorText: UIColor {
        return UIColor(red: 0.85, green: 0.18, blue: 0.18, alpha: 1.00)
    }


    static var activeColor: UIColor {
        return .white
    }

    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

}

extension UIFont {
    class var tiny: UIFont {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return UIFont.systemFont(ofSize: 12)
        } else {
            return UIFont.systemFont(ofSize: 10)
        }
    }

    class var small: UIFont {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return UIFont.systemFont(ofSize: 15)
        } else {
            return UIFont.systemFont(ofSize: 13)
        }
    }

    class var medium: UIFont {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return UIFont.systemFont(ofSize: 25, weight: .bold)
        } else {
            return UIFont.systemFont(ofSize: 18, weight: .bold)
        }
    }

    class var large: UIFont {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return UIFont.systemFont(ofSize: 40)
        } else {
            return UIFont.systemFont(ofSize: 25)
        }
    }
}

public extension UIWindow {
    func switchRootViewController(
        to viewController: UIViewController,
        animated: Bool = true,
        duration: TimeInterval = 0.5,
        options: UIView.AnimationOptions = .transitionCrossDissolve,
        _ completion: (() -> Void)? = nil) {

        guard animated else {
            rootViewController = viewController
            completion?()
            return
        }

        UIView.transition(with: self, duration: duration, options: options, animations: {
            let oldState = UIView.areAnimationsEnabled
            UIView.setAnimationsEnabled(false)
            self.rootViewController = viewController
            UIView.setAnimationsEnabled(oldState)
        }, completion: { _ in
            completion?()
        })
    }
}

extension UIView {
    func addShadowWithOffset(_ offset: CGSize, color: UIColor, opacity: Float, shadowRadius: CGFloat) {
        layer.shadowColor = color.cgColor
        layer.shadowOffset = offset
        layer.shadowOpacity = opacity
        layer.shadowRadius = shadowRadius
        layer.masksToBounds = false

        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }

    func applyDefaultShadow() {
        addShadowWithOffset(CGSize(width: 1.0, height: 1.0), color: UIColor.gray, opacity: 0.1, shadowRadius: 1.0)
    }

    func removeShadow() {
        addShadowWithOffset(CGSize(width: 0.0, height: 0.0), color: UIColor.clear, opacity: 0.0, shadowRadius: 0.0)
    }
}
