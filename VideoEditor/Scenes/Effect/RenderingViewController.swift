//
//  RenderingViewController.swift
//  VideoEditor
//
//  Created by Хандымаа Чульдум on 28.01.2023.
//

import UIKit

final class RenderingViewController: UIViewController {
    
    private lazy var infoView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.addCornerRadius(radius: 12)
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Video Processing"
        label.font = UIFont.interBold(20)
        label.textColor = .black
        return label
    }()
    
    private lazy var decrLabel: UILabel = {
        let label = UILabel()
        label.text = "Wait a little bit"
        label.font = UIFont.interRegular(16)
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
        infoView.addSubview(decrLabel)
        infoView.addSubview(activityIndicator)
        
        makeConstraints()
    }
    
    private func makeConstraints() {
        blurEffectView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        infoView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.equalToSuperview().offset(32)
            $0.height.equalTo(200)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(32)
            $0.centerX.equalToSuperview()
        }
        
        decrLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
        }
        
        activityIndicator.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-32)
        }
    }
}
