//
//  Styles.swift
//  Koleda
//
//  Created by Oanh Tran on 5/24/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit

struct Style {
    struct ViewStyle<T> {
        
        let styling: (T) -> Void
        
        func apply(to view: T) {
            styling(view)
        }
        
        static func compose(_ styles: [ViewStyle<T>]) -> ViewStyle<T> {
            return ViewStyle { view in
                for style in styles {
                    style.styling(view)
                }
            }
        }
        
        static func compose(styles: [ViewStyle<T>],
                            styling: @escaping (T) -> Void) -> ViewStyle<T>
        {
            var allStyles = styles
            allStyles.append(ViewStyle(styling: styling))
            
            return compose(allStyles)
        }
        
        static func compose(_ styles: ViewStyle<T>...) -> ViewStyle<T> {
            return compose(styles)
        }
        
        static func compose(_ styles: ViewStyle<T>...,
            stylingClosure: @escaping (T) -> Void) -> ViewStyle<T>
        {
            var allStyles = styles
            allStyles.append(ViewStyle(styling: stylingClosure))
            return compose(allStyles)
        }
    }
    
    struct Color {
        static let white = UIColor.white
        static let black = UIColor.black
		static let bgDarkButtonColor = UIColor.init(r: 31, g: 27, b: 21, alpha: 1)
        static let denimBlue = UIColor.init(r: 65, g: 93, b: 150, alpha: 1)
        static let textGrey = UIColor.init(r: 84, g: 84, b: 84, alpha: 1)
        static let textLightGrey = UIColor.init(r: 109, g: 114, b: 120, alpha: 1)
        static let borderViewColor = UIColor.init(r: 209, g: 209, b: 209, alpha: 1)
        static let menuSettingsBackground = UIColor.init(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
    }
    
    fileprivate struct Size {
        static let standardButtonHeight: CGFloat = 57
        static let socialButtonHeight: CGFloat = 40
    }
    
    fileprivate struct CornerRadius {
        static let standardButton: CGFloat = 4
    }
    
    fileprivate struct BorderWidth {
        static let standardButton: CGFloat = 1
    }
    
    fileprivate struct Image {
        static var closeLightBackground: UIImage {
            return #imageLiteral(resourceName: "closeLightGrey")
        }
    }
    
    struct Button {
        private static let light = ViewStyle<UIButton> { button in
            button.backgroundColor = Color.white
            button.tintColor = Color.black
            button.titleLabel?.textColor = Color.black
            button.layer.borderWidth = BorderWidth.standardButton
            button.layer.borderColor = Color.black.cgColor
        }
        
        private static let dark = ViewStyle<UIButton> { button in
            button.backgroundColor = Color.black
            button.tintColor = Color.white
            button.titleLabel?.textColor = Color.white
        }
        
        static let primary = ViewStyle.compose(rounded(height: Size.standardButtonHeight)) { button in
            button.setTitleColor(Color.white, for: .normal)
            button.titleLabel?.font = UIFont.app_FuturaPTMedium(ofSize: 16)
            button.backgroundColor = Color.bgDarkButtonColor
        }
        
        static let secondaryWithBorder = ViewStyle.compose(rounded(height: Size.standardButtonHeight)) { button in
            button.setTitleColor(Color.textGrey, for: .normal)
            button.titleLabel?.font = UIFont.app_FuturaPTDemi(ofSize: 16)
            button.backgroundColor = Color.white
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.lightGray.cgColor
        }
        
        static let secondary = ViewStyle.compose(rounded(height: Size.standardButtonHeight)) { button in
            button.setTitleColor(Color.textGrey, for: .normal)
            button.titleLabel?.font = UIFont.app_FuturaPTDemi(ofSize: 16)
            button.backgroundColor = Color.white
        }
        
        static let halfWithWhite = ViewStyle.compose(rounded(height: Size.standardButtonHeight)) { button in
            button.setTitleColor(Color.textLightGrey, for: .normal)
            button.titleLabel?.font = UIFont.app_FuturaPTDemi(ofSize: 16)
            button.backgroundColor = Color.white
        }
        
        static let halfWithBlue = ViewStyle.compose(rounded(height: Size.standardButtonHeight)) { button in
            button.setTitleColor(Color.white, for: .normal)
            button.titleLabel?.font = UIFont.app_FuturaPTDemi(ofSize: 16)
            button.backgroundColor = Color.denimBlue
        }
        
        static let halfWithBlackSmall = ViewStyle.compose(rounded(height: Size.socialButtonHeight)) { button in
            button.setTitleColor(Color.white, for: .normal)
            button.titleLabel?.font = UIFont.app_FuturaPTBook(ofSize: 14)
            button.backgroundColor = Color.black
        }
        
        static let halfWithWhiteSmall = ViewStyle.compose(rounded(height: Size.socialButtonHeight)) { button in
            button.setTitleColor(Color.textLightGrey, for: .normal)
            button.titleLabel?.font = UIFont.app_FuturaPTDemi(ofSize: 16)
            button.backgroundColor = Color.white
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.lightGray.cgColor
        }
        
        static let halfWithBlueSmall = ViewStyle.compose(rounded(height: Size.socialButtonHeight)) { button in
            button.setTitleColor(Color.white, for: .normal)
            button.titleLabel?.font = UIFont.app_FuturaPTDemi(ofSize: 16)
            button.backgroundColor = Color.denimBlue
        }
        
        
        static let closeLightBackground = ViewStyle<UIButton> { item in
            item.setImage(Image.closeLightBackground, for: .normal)
        }
        
        private static func withHeight(_ height: CGFloat) -> ViewStyle<UIButton> {
            return ViewStyle<UIButton> { button in
                let heightId = "height_identifier"
                button.removeConstraints(
                    button.constraints.filter { $0.identifier == heightId }
                )
                let heightConstraint = button.heightAnchor.constraint(equalToConstant: height)
                heightConstraint.identifier = heightId
                button.addConstraint(heightConstraint)
            }
        }
        
        private static func rounded(height: CGFloat) -> ViewStyle<UIButton> {
            return ViewStyle.compose(withHeight(height), ViewStyle<UIButton> { button in
                button.layer.cornerRadius = CornerRadius.standardButton
                button.clipsToBounds = true
            })
        }
       
    }
    
    struct View {
        static let cornerRadius = ViewStyle<UIView> { view in
            let layer = view.layer
            layer.cornerRadius = CornerRadius.standardButton
        }
        
        static let borderAndCorner = ViewStyle<UIView> { view in
            let layer = view.layer
            layer.borderWidth = 1.5
            layer.borderColor = Color.borderViewColor.cgColor
            layer.cornerRadius = CornerRadius.standardButton
        }
        
        static let borderShadow = ViewStyle<UIView> { view in
            let layer = view.layer
            layer.borderWidth = 1
            layer.borderColor = Color.borderViewColor.cgColor
            layer.shadowOpacity = 0.6
            layer.shadowOffset = CGSize.zero
            layer.shadowColor = Color.borderViewColor.cgColor
            layer.shadowRadius = 10.0
            layer.shadowPath = UIBezierPath(rect: view.bounds).cgPath
            layer.shouldRasterize = true
        }
        
        static let borderShadowSelected = ViewStyle<UIView> { view in
            let layer = view.layer
            layer.borderWidth = 1
            layer.borderColor = Color.black.cgColor
            layer.shadowOpacity = 0.6
            layer.shadowOffset = CGSize.zero
            layer.shadowColor = Color.borderViewColor.cgColor
            layer.shadowRadius = 10.0
            layer.shadowPath = UIBezierPath(rect: view.bounds).cgPath
            layer.shouldRasterize = true
        }
        
        static let shadowStyle1 = ViewStyle<UIView> { view in
            let layer = view.layer
            layer.shadowOpacity = 0.6
            layer.shadowOffset = CGSize.zero
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowRadius = 8.0
//            layer.shadowPath = UIBezierPath(rect: view.bounds).cgPath
            layer.shouldRasterize = true
        }
        
        static let shadowBlackRemote = ViewStyle<UIView> { view in
           view.addshadowAllSides(cornerRadius: CornerRadius.standardButton, shadowColor: Color.textLightGrey, shadowRadius: 10.0)
        }
        
        static let shadowCornerWhite = ViewStyle<UIView> { view in
            view.addshadowAllSides(cornerRadius: CornerRadius.standardButton, shadowColor: Color.textLightGrey)
        }
        
        static let scheduleShadowView = ViewStyle<UIView> { view in
            view.addshadowAllSides(cornerRadius: CornerRadius.standardButton, shadowColor: Color.textLightGrey, shadowRadius: 10.0)
        }
    }
    
    struct BarButtonItem {
        static let closeLightBackground = ViewStyle<UIBarButtonItem> { item in
            item.image = Image.closeLightBackground
        }
    }
}
