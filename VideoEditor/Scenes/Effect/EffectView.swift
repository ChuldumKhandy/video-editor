//
//  EffectView.swift
//  VideoEditor
//
//  Created by Хандымаа Чульдум on 28.01.2023.
//

import UIKit

protocol EffectViewDelegate: AnyObject {
    func tappedOnView(_ effectView: EffectView)
}

final class EffectView: UIView {
    
    private enum Constants {
        static let textSize: CGFloat = 20
        static let radius: CGFloat = 6
        static let top = 12
        static let leading = 16
        static let imageSize = 46
    }
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .black
        imageView.addCornerRadius(radius: Constants.radius)
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.interMedium(Constants.textSize)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    weak var delegate: EffectViewDelegate?
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    func configure(image: UIImage, title: String) {
        imageView.image = image
        titleLabel.text = title
    }
    
    func markAsSelect(_ selected: Bool) {
        self.layer.borderColor = selected ? UIColor.black.cgColor : UIColor.clear.cgColor
    }
    
    private func setup() {
        self.backgroundColor = .black.withAlphaComponent(0.04)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedOnView))
        self.addGestureRecognizer(tapGesture)
        
        self.layer.setBorder(color: .clear, width: 2)
        self.addCornerRadius(radius: Constants.radius)
        
        self.addSubview(imageView)
        self.addSubview(titleLabel)
        
        makeConstraints()
    }
    
    @objc
    private func tappedOnView() {
        delegate?.tappedOnView(self)
    }
    
    private func makeConstraints() {
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(Constants.leading)
            $0.top.equalTo(imageView.snp.bottom).offset(Constants.top)
            $0.centerX.equalToSuperview()
        }
        
        imageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(Constants.imageSize)
        }
    }
}
