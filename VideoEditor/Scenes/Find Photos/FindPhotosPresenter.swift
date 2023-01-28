//
//  FindPhotosPresenter.swift
//  VideoEditor
//
//  Created by Хандымаа Чульдум on 27.01.2023.
//

import UIKit

protocol FindPhotosPresenterProtocol {
    var photoModels: [PhotoModel] { get set }
    var isHideNextButton: Bool { get set }
    var query: String { get set }
    func getImage(by index: Int) -> UIImage
    func isSelectImage(by index: Int) -> Bool
    func selecteImage(by index: Int)
    func tappedNextButton()
}

final class FindPhotosPresenter: FindPhotosPresenterProtocol {
    
    weak var view: FindPhotosViewProtocol?
    private let router: FindPhotoRouterProtocol
    private var networkService: FindPhotoNetworkServiceProtocol
    private var selectedImages: [Data] = []
    
    var photoModels: [PhotoModel] = []
    var isHideNextButton = true
    var query: String = "" {
        didSet { getSearchPhotos() }
    }
    
    init(view: FindPhotosViewProtocol,
         router: FindPhotoRouterProtocol,
         networkService: FindPhotoNetworkServiceProtocol) {
        self.view = view
        self.router = router
        self.networkService = networkService
        getRandomPhotos()
    }
    
    func getImage(by index: Int) -> UIImage {
        let imageData = photoModels[index].image
        return UIImage(data: imageData) ?? UIImage().noImage
    }
    
    func isSelectImage(by index: Int) -> Bool {
        return selectedImages.contains { $0 == photoModels[index].image }
    }
    
    func selecteImage(by index: Int) {
        let data = photoModels[index].image
        defer {
            isHideNextButton = selectedImages.count < 2
            view?.reloadData()
        }
        
        guard !selectedImages.contains(where: { $0 == data }) else {
            selectedImages.removeAll { $0 == data }
            return
        }
        
        if !(selectedImages.count < 2) {
            selectedImages.removeFirst()
        }
        selectedImages.append(data)
    }
    
    func tappedNextButton() {
        router.presentEffectViewController(selectedImages: selectedImages)
    }
    
    private func getRandomPhotos() {
        networkService.getRandomPhotos { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .failure:
                print("ERROR: get random photos")
            case .success(let models):
                self.getPhoto(models: models)
            }
        }
    }
    
    private func getSearchPhotos() {
        networkService.getSearchPhotos(query: self.query) { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .failure:
                print("ERROR: get photos search")
            case .success(let models):
                guard let searchResults = models.results,
                      !searchResults.isEmpty else {
                    return
                }
                self.photoModels.removeAll()
                self.getPhoto(models: searchResults)
            }
        }
    }
    
    private func getPhoto(models: [UnplashImage]?) {
        models?.forEach { model in
            networkService.fetchImage(from: model) { result in
                switch result {
                case .failure:
                    print("ERROR: get image")
                case .success(let imageData):
                    self.photoModels.append(PhotoModel(width: model.width,
                                                       height: model.height,
                                                       image: imageData))
                    
                }
                self.view?.reloadData()
            }
        }
    }
}
