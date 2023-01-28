//
//  SceneFactory.swift
//  VideoEditor
//
//  Created by Хандымаа Чульдум on 26.01.2023.
//

import UIKit

protocol SceneFactoryProtocol: AnyObject {
    func createFindPhotoViewController(router: RootRouter) -> FindPhotosViewController
    func createEffectViewController(router: RootRouter, images: [Data]) -> EffectViewController
    func createRenderingViewController() -> RenderingViewController 
}

final class SceneFactory: SceneFactoryProtocol {
    
    func createFindPhotoViewController(router: RootRouter) -> FindPhotosViewController {
        let view = FindPhotosViewController()
        let networkService = NetworkService()
        let presenter = FindPhotosPresenter(view: view,
                                            router: router,
                                            networkService: networkService)
        view.presenter = presenter
        return view
    }
    
    func createEffectViewController(router: RootRouter, images: [Data]) -> EffectViewController {
        let view = EffectViewController()
        let presenter = EffectPresenter(view: view,
                                        router: router,
                                        images: images)
        view.presenter = presenter
        return view
    }
    
    func createRenderingViewController() -> RenderingViewController {
        return RenderingViewController()
    }
}
