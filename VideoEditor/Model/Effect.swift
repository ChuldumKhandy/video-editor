//
//  Effect.swift
//  VideoEditor
//
//  Created by Хандымаа Чульдум on 28.01.2023.
//

import UIKit

enum Effect: Int, CaseIterable {
    case mod
    case flash
    
    var localized: String {
        switch self {
        case .mod:      return "Mod"
        case .flash:    return "Flash"
        }
    }
    
    var image: UIImage? {
        switch self {
        case .mod:      return UIImage(named: "circle_grid_hex_fill")
        case .flash:    return UIImage(named: "flare")
        }
    }
}
