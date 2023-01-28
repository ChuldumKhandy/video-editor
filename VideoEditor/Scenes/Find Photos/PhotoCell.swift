//
//  PhotoCell.swift
//  VideoEditor
//
//  Created by Хандымаа Чульдум on 26.01.2023.
//

import UIKit

final class PhotoCell: UICollectionViewCell {
    
    private enum Constants {
        static let radius: CGFloat = 6
        static let leading = 6
    }
    
    private lazy var imageView: UIImageView = {
       let imageView = UIImageView()
        imageView.addCornerRadius(radius: Constants.radius)
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup() 
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }

    func setupImage(_ image: UIImage) {
        imageView.image = image
    }
    
    func markAsSelect(_ selected: Bool) {
        self.layer.borderColor = selected ? UIColor.black.cgColor : UIColor.clear.cgColor
        imageView.snp.updateConstraints {
            $0.leading.top.equalToSuperview().offset(selected ? Constants.leading : 0)
            $0.trailing.bottom.equalToSuperview().offset(selected ? -Constants.leading : 0)
        }
    }
    
    private func setup() {
        self.addSubview(imageView)
        self.layer.setBorder(color: .clear, width: 2)
        self.addCornerRadius(radius: Constants.radius)
        
        makeConstraints()
    }
    
    private func makeConstraints() {
        imageView.snp.makeConstraints {
            $0.leading.top.equalToSuperview()
            $0.trailing.bottom.equalToSuperview()
        }
    }
}
