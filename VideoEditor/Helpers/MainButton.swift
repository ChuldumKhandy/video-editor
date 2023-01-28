//
//  MainButton.swift
//  VideoEditor
//
//  Created by Хандымаа Чульдум on 27.01.2023.
//

import UIKit

final class MainButton: UIButton {
     
    override func didMoveToWindow() {
        super.didMoveToWindow()
        self.configureRounded()
        self.configureColor()
        self.configureText()
    }
    
    private func configureRounded() {
        self.addCornerRadius(radius: 12)
    }
    
    private func configureColor() {
        self.backgroundColor = .black
        self.layer.addShadow(color: .black,
                             radius: 9,
                             opacity: 0.08,
                             offset: CGSize(width: 0, height: 4))
    }
    
    private func configureText() {
        self.titleLabel?.font = UIFont.interSemibold(16)
        self.setTitleColor(.white, for: .normal)
    }
}
