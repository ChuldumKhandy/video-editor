//
//  RootRouter.swift
//  VideoEditor
//
//  Created by Хандымаа Чульдум on 26.01.2023.
//

import UIKit

protocol FindPhotoRouterProtocol {
    func presentEffectViewController(selectedImages: [Data])
}

protocol EffectRouterProtocol {
    func popViewController()
    func presesentSuccessAlert()
    func presesentErrorAlert()
    func presesentBlockView()
    func dismissBlockView()
}

final class RootRouter {
    
    private(set) var window: UIWindow
    private let sceneFactory: SceneFactoryProtocol
    private var navigationController: UINavigationController?
    
    init(window: UIWindow) {
        self.window = window
        sceneFactory = SceneFactory()
    }
    
    func presentEffectViewController(selectedImages: [Data]) {
        let viewController = sceneFactory.createEffectViewController(router: self,
                                                                     images: selectedImages)
        
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func presentOKAlert(withText text: String?,
                                andTitle title: String? = "",
                                titleColor: UIColor? = nil) {
        let alertView = UIAlertController(title: title,
                                          message: text,
                                          preferredStyle: .alert)
        if let titleColor = titleColor,
           let title = title {
            alertView.setValue(NSAttributedString(
                string: title,
                attributes: [.foregroundColor: titleColor]), forKey: "attributedTitle")
        }
        
        alertView.addAction(UIAlertAction(title: "ОК", style: .default))
        navigationController?.topViewController?.present(alertView, animated: true)
    }
}

extension RootRouter: FindPhotoRouterProtocol {
    func presentRootNavigationControllerInWindow() {
        let mainViewController = sceneFactory.createFindPhotoViewController(router: self)
        navigationController = UINavigationController(rootViewController: mainViewController)
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
}

extension RootRouter: EffectRouterProtocol {
    func popViewController() {
        navigationController?.popViewController(animated: true)
    }
    
    func presesentSuccessAlert() {
        presentOKAlert(withText: "Video successfully saved to your gallery",
                       andTitle: "It's done")
    }
    
    func presesentErrorAlert() {
        presentOKAlert(withText: "Failed to save video",
                       andTitle: "Error",
                       titleColor: UIColor(hex: "#E31D4D"))
    }
    
    func presesentBlockView() {
        let blockView = sceneFactory.createBlockViewController()
        blockView.modalPresentationStyle = .overCurrentContext
        blockView.modalTransitionStyle = .crossDissolve
        navigationController?.topViewController?.present(blockView, animated: true)
    }
    
    func dismissBlockView() {
        navigationController?.topViewController?.presentedViewController?.dismiss(animated: true)
    }
}
