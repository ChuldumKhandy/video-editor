//
//  EffectPresenter.swift
//  VideoEditor
//
//  Created by Хандымаа Чульдум on 27.01.2023.
//

import simd
import UIKit

private extension Effect {
    var filterName: String {
        switch self {
        case .mod:      return "CIModTransition"
        case .flash:    return "CIFlashTransition"
        }
    }
}

protocol EffectPresenterProtocol {
    var effects: [Effect] { get set }
    var selectedEffect: Effect? { get set }
    func tappedBackButton()
    func tappedNextButton()
}

final class EffectPresenter: EffectPresenterProtocol {
    
    private var displayLink = CADisplayLink()
    private let ciContext = CIContext()
    private var time: Double = 0
    private let step = 0.05
    private let settings = RenderSettings()
    
    weak var view: EffectViewControllerProtocol?
    private let router: EffectRouterProtocol
    private var sourceImages: [Data] = []
    private var filtredImage: [UIImage] = []
    
    var effects: [Effect] = Effect.allCases
    var selectedEffect: Effect? {
        didSet { view?.updateUI() }
    }
    
    init(view: EffectViewControllerProtocol,
         router: EffectRouterProtocol,
         images: [Data]) {
        self.view = view
        self.router = router
        self.sourceImages = images
    }
    
    func tappedBackButton() {
        router.popViewController()
    }
    
    func tappedNextButton() {
        router.presesentRenderingView()
        beginTransition()
    }
    
    private func beginTransition() {
        displayLink = CADisplayLink(target: self,
                                    selector: #selector(stepTime))
        displayLink.add(to: RunLoop.current,
                        forMode: RunLoop.Mode.default)
    }
    
    @objc private func stepTime() {
        time += step
        guard time < 1 else {
            router.dismissRenderingView()
            displayLink.remove(from: RunLoop.main,
                               forMode: RunLoop.Mode.default)
            render()
            time = 0
            filtredImage.removeAll()
            return
        }
        
        guard let firstImage = sourceImages.first,
              let secondImage = sourceImages.last,
              let sourceCIImage = CIImage(data: firstImage),
              let finalCIImage = CIImage(data: secondImage),
              let dissolvedCIImage = transitionFilter(sourceCIImage,
                                                      to: finalCIImage,
                                                      time: time) else {
            showErrorAlert()
            return
        }
        
        showCIImage(dissolvedCIImage, context: ciContext)
        
    }
    
    private func transitionFilter(_ inputImage: CIImage,
                          to targetImage: CIImage,
                          time: TimeInterval) -> CIImage? {
        
        let inputTime = simd_smoothstep(0, 1, time)
        guard let filterName = selectedEffect?.filterName,
              let filter = CIFilter(name: filterName,
                                    parameters: [kCIInputImageKey: inputImage,
                                           kCIInputTargetImageKey: targetImage,
                                                  kCIInputTimeKey: inputTime]) else {
            return nil
        }
        
        return filter.outputImage
    }
    
    private func showCIImage(_ ciImage: CIImage,
                     context: CIContext) {
        
        guard let cgImage = context.createCGImage(ciImage,
                                                  from: ciImage.extent) else {
            showErrorAlert()
            return
        }
        let uiImage = UIImage(cgImage: cgImage)
        filtredImage.append(uiImage)
    }
    
    private func render() {
        let imageAnimator = ImageAnimator(renderSettings: settings,
                                          images: filtredImage)
        imageAnimator.render { result in
            switch result {
            case .failure:
                self.showErrorAlert()
            case .success:
                self.router.presesentSuccessAlert()
            }
        }
    }
    
    private func showErrorAlert() {
        router.dismissRenderingView()
        router.presesentErrorAlert()
    }
}
