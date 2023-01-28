//
//  EffectViewController.swift
//  VideoEditor
//
//  Created by Хандымаа Чульдум on 27.01.2023.
//

import PhotosUI
import UIKit

protocol EffectViewControllerProtocol: AnyObject {
    func updateUI()
}

final class EffectViewController: UIViewController, EffectViewControllerProtocol {
    
    var presenter: EffectPresenterProtocol?
    
    private enum Constants {
        static let textSize: CGFloat = 20
        static let spacing: CGFloat = 8
        static let radius: CGFloat = 6
        static let top = 24
        static let leading = 16
        static let stackBottom = 98
        static let buttonBottom = 22
        static let navViewHeight = 52
        static let buttonHeight = 52
    }
    
    private lazy var navView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.addCornerRadius(radius: Constants.radius,
                             mask: [.layerMinXMaxYCorner, .layerMaxXMaxYCorner])
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Select 1 effect"
        label.font = UIFont.interBold(Constants.textSize)
        label.textColor = .black
        return label
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "btn_back"), for: .normal)
        button.addTarget(self, action: #selector(tappedBackButton), for: .touchUpInside)
        return button
        
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillEqually
        stackView.spacing = Constants.spacing
        stackView.axis = .vertical
        return stackView
    }()
    
    private lazy var nextButton: MainButton = {
        let button = MainButton()
        button.setTitle("Next", for: .normal)
        button.addTarget(self, action: #selector(tappedNextButton), for: .touchUpInside)
        return button
        
    }()
    
    private var viewDidLayout = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !viewDidLayout {
            navView.addBottomShadow()
            viewDidLayout = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let photos = PHPhotoLibrary.authorizationStatus()
        switch photos {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { status in
                guard status == .authorized else {
                    return
                }
            }
        default: break
        }
    }
    
    func updateUI() {
        DispatchQueue.main.async {
            self.nextButton.alpha = self.presenter?.selectedEffect == nil ? 0.4 : 1
        }
    }
    
    private func setup() {
        self.view.backgroundColor = .white
        self.navigationController?.navigationBar.isHidden = true
        
        self.view.addSubview(navView)
        self.view.addSubview(stackView)
        self.view.addSubview(nextButton)
        
        navView.addSubview(titleLabel)
        navView.addSubview(backButton)
        
        setupStackView()
        updateUI()
        makeConstraints()
    }
    
    @objc
    private func tappedBackButton() {
        presenter?.tappedBackButton()
    }
    
    @objc
    private func tappedNextButton() {
        presenter?.tappedNextButton()
    }
    
    private func setupStackView() {
        presenter?.effects.forEach({ effect in
            let view = EffectView()
            view.configure(image: effect.image ?? UIImage().noImage,
                           title: effect.localized)
            view.tag = effect.rawValue
            view.delegate = self
            stackView.addArrangedSubview(view)
        })
    }
    
    private func makeConstraints() {
        navView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            $0.height.equalTo(Constants.navViewHeight)
        }
        
        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(Constants.buttonBottom)
            $0.centerY.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(backButton)
        }
        
        stackView.snp.makeConstraints {
            $0.top.equalTo(navView.snp.bottom).offset(Constants.top)
            $0.leading.equalToSuperview().offset(Constants.leading)
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-Constants.stackBottom)
        }
        
        nextButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(Constants.leading)
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-Constants.buttonBottom)
            $0.height.equalTo(Constants.buttonHeight)
        }
    }
}

extension EffectViewController: EffectViewDelegate {
    func tappedOnView(_ effectView: EffectView) {
        presenter?.selectedEffect = Effect(rawValue: effectView.tag)
        stackView.arrangedSubviews.forEach { view in
            (view as? EffectView)?.markAsSelect(view == effectView)
        }
    }
}
