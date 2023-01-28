//
//  BlockViewController.swift
//  VideoEditor
//
//  Created by Хандымаа Чульдум on 28.01.2023.
//

import UIKit

final class BlockViewController: UIViewController {
    
    private enum Constants {
        static let titleTextSize: CGFloat = 20
        static let descTextSize: CGFloat = 16
        static let radius: CGFloat = 12
        static let top = 8
        static let leading = 32
        static let infoViewHeight = 200
    }
    
    private lazy var infoView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.addCornerRadius(radius: Constants.radius)
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Video Processing"
        label.font = UIFont.interBold(Constants.titleTextSize)
        label.textColor = .black
        return label
    }()
    
    private lazy var descLabel: UILabel = {
        let label = UILabel()
        label.text = "Wait a little bit"
        label.font = UIFont.interRegular(Constants.descTextSize)
        label.textColor = .black
        return label
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = .large
        return activityIndicator
    }()
    
    private let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        activityIndicator.startAnimating()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        activityIndicator.stopAnimating()
    }
    
    private func setup() {
        self.view.addSubview(blurEffectView)
        self.view.addSubview(infoView)
        
        infoView.addSubview(titleLabel)
        infoView.addSubview(descLabel)
        infoView.addSubview(activityIndicator)
        
        makeConstraints()
    }
    
    private func makeConstraints() {
        blurEffectView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        infoView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.equalToSuperview().offset(Constants.leading)
            $0.height.equalTo(Constants.infoViewHeight)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Constants.leading)
            $0.centerX.equalToSuperview()
        }
        
        descLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(Constants.top)
            $0.centerX.equalToSuperview()
        }
        
        activityIndicator.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-Constants.leading)
        }
    }
}
