//
//  Extensions.swift
//  VideoEditor
//
//  Created by Хандымаа Чульдум on 27.01.2023.
//

import UIKit

extension UIFont {
    private static var defaultFont: String {
        "Inter"
    }
    
    private enum FontWidth: String {
        case bold = "-Bold"
        case medium = "-Medium"
        case regular = "-Regular"
        case semibold = "-Semibold"
    }
    
    static func interBold(_ size: CGFloat) -> UIFont {
        return assembly(weight: .bold, uiFontWeight: .bold, size: size)
    }
    
    static func interMedium(_ size: CGFloat) -> UIFont {
        return assembly(weight: .medium, uiFontWeight: .medium, size: size)
    }
    
    static func interRegular(_ size: CGFloat) -> UIFont {
        return assembly(weight: .regular, uiFontWeight: .regular, size: size)
    }
    
    static func interSemibold(_ size: CGFloat) -> UIFont {
        return assembly(weight: .semibold, uiFontWeight: .semibold, size: size)
    }
    
    private static func assembly(font: String = defaultFont,
                                 weight: FontWidth,
                                 uiFontWeight: UIFont.Weight,
                                 size: CGFloat) -> UIFont {
        UIFont(name: font + weight.rawValue, size: size) ?? .systemFont(ofSize: size, weight: uiFontWeight)
    }
}

extension UIImage {
    var noImage: UIImage { #imageLiteral(resourceName: "no_image") }
}

extension UICollectionView {
    func register<T>(classCell: T.Type) where T: UICollectionViewCell {
        self.register(classCell, forCellWithReuseIdentifier: classCell.className)
    }

    func reusableCell<T>(classCell: T.Type, indexPath: IndexPath) -> T where T: UICollectionViewCell {
        if let newCell = self.dequeueReusableCell(withReuseIdentifier: classCell.className, for: indexPath) as? T {
            return newCell
        }
        return T()
    }
}

extension NSObject {
    class var className: String {
        let array = String(describing: self).components(separatedBy: ".")
        return array.last ?? "className"
    }
}

extension UIView {
    func addCornerRadius(radius: CGFloat? = nil, mask: CACornerMask? = nil) {
        guard let radius = radius else {
            self.layer.roundCorners(radius: self.frame.height / 2)
            return
        }

        self.layer.roundCorners(radius: radius, mask: mask)
    }

    func addBottomShadow() {
        layer.masksToBounds = false
        layer.shadowRadius = 9
        layer.shadowOpacity = 0.08
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowPath = UIBezierPath(rect: CGRect(x: 0,
                                                     y: bounds.maxY - layer.shadowRadius,
                                                     width: bounds.width,
                                                     height: layer.shadowRadius)).cgPath
    }
}

extension CALayer {
    func roundCorners(radius: CGFloat, mask: CACornerMask? = nil) {
        self.cornerRadius = radius

        if let mask = mask {
            self.maskedCorners = mask
        }
    }
    
    func addShadow(color: UIColor, radius: CGFloat, opacity: Float, offset: CGSize) {
        self.shadowOffset = offset
        self.shadowOpacity = opacity
        self.shadowRadius = radius
        self.shadowColor = color.cgColor
        self.masksToBounds = false
    }
    
    func setBorder(color: UIColor, width: CGFloat) {
        self.borderColor = color.cgColor
        self.borderWidth = width
    }
}

extension UIColor {
    convenience init?(hex: String) {
        let red, green, blue, alpha: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    red = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    green = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    blue = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    alpha = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: red,
                              green: green,
                              blue: blue,
                              alpha: alpha)
                    return
                }
            }
        }
        return nil
    }
}
