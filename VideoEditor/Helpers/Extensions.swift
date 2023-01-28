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
    private func addShadowWithRoundedCorners() {
        masksToBounds = false
        sublayers?.filter { $0.frame.equalTo(self.bounds) }
            .forEach { $0.roundCorners(radius: self.cornerRadius, mask: self.maskedCorners) }

        self.contents = nil

        if let sublayer = sublayers?.first,
            sublayer.name == "#shadowLayer#" {

            sublayer.removeFromSuperlayer()
        }

        let contentLayer = CALayer()
        contentLayer.name = "#shadowLayer#"
        contentLayer.contents = contents
        contentLayer.frame = bounds
        contentLayer.cornerRadius = cornerRadius
        contentLayer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        contentLayer.masksToBounds = true

        insertSublayer(contentLayer, at: 0)
    }

    func roundCorners(radius: CGFloat, mask: CACornerMask? = nil) {
        self.cornerRadius = radius

        if let mask = mask {
            self.maskedCorners = mask
        }

        if shadowOpacity != 0 {
            addShadowWithRoundedCorners()
        }
    }
    
    func addShadow(color: UIColor, radius: CGFloat, opacity: Float, offset: CGSize) {
        self.shadowOffset = offset
        self.shadowOpacity = opacity
        self.shadowRadius = radius
        self.shadowColor = color.cgColor
        self.masksToBounds = false

        if cornerRadius != 0 {
            addShadowWithRoundedCorners()
        }
    }
    
    func setBorder(color: UIColor, width: CGFloat) {
        self.borderColor = color.cgColor
        self.borderWidth = width
    }
}

extension UIColor {
    
    convenience init?(string: String) {
        var red, green, blue, alpha: UInt64
        let start: String.Index
        if string.hasPrefix("#") {
            start = string.index(string.startIndex, offsetBy: 1)
        } else {
            start = string.index(string.startIndex, offsetBy: 0)
        }
        let hexColor = String(string[start...])
        if hexColor.count == 8 || hexColor.count == 6 {
            var startIndex = hexColor.index(hexColor.startIndex, offsetBy: 0)
            var endIndex = hexColor.index(hexColor.startIndex, offsetBy: 1)
            let rString = String(hexColor[startIndex...endIndex])
            startIndex = hexColor.index(hexColor.startIndex, offsetBy: 2)
            endIndex = hexColor.index(hexColor.startIndex, offsetBy: 3)
            let gString = String(hexColor[startIndex...endIndex])
            startIndex = hexColor.index(hexColor.startIndex, offsetBy: 4)
            endIndex = hexColor.index(hexColor.startIndex, offsetBy: 5)
            let bString = String(hexColor[startIndex...endIndex])
            
            var scan = Scanner(string: rString)
            red = 0
            scan.scanHexInt64(&red)
            scan = Scanner(string: gString)
            green = 0
            scan.scanHexInt64(&green)
            scan = Scanner(string: bString)
            blue = 0
            scan.scanHexInt64(&blue)
            if hexColor.count == 8 {
                startIndex = hexColor.index(hexColor.startIndex, offsetBy: 6)
                endIndex = hexColor.index(hexColor.startIndex, offsetBy: 7)
                let aString = String(hexColor[startIndex...endIndex])
                scan = Scanner(string: aString)
                alpha = 0
                scan.scanHexInt64(&alpha)
            } else {
                alpha = 255
            }
            self.init(red: CGFloat(red) / 255,
                      green: CGFloat(green) / 255,
                      blue: CGFloat(blue) / 255,
                      alpha: CGFloat(alpha) / 255)
            return
            
        }
        return nil
    }
}
