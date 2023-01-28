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
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .black
        imageView.addCornerRadius(radius: 6)
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.interMedium(20)
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
        self.addCornerRadius(radius: 6)
        
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
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalTo(imageView.snp.bottom).offset(12)
            $0.centerX.equalToSuperview()
        }
        
        imageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(46)
        }
    }
}
