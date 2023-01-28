//
//  ImageModel.swift
//  VideoEditor
//
//  Created by Хандымаа Чульдум on 27.01.2023.
//

import UIKit

struct UnplashImage: Codable {
    let urls: Urls?
    let width: Int
    let height: Int
    
    struct Urls: Codable {
        let small: String?
    }
}

struct SearchUnplashImage: Codable {
    let results: [UnplashImage]?
}

struct PhotoModel {
    let width: Int
    let height: Int
    let image: Data
}
