//
//  SceneDelegate.swift
//  VideoEditor
//
//  Created by Хандымаа Чульдум on 26.01.2023.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var router: RootRouter?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        router = RootRouter(window: window)
        router?.presentRootNavigationControllerInWindow()
    }
}
