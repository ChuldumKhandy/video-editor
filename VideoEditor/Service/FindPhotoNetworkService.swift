//
//  PhotoNetworkService.swift
//  VideoEditor
//
//  Created by Хандымаа Чульдум on 28.01.2023.
//

import Foundation

protocol FindPhotoNetworkServiceProtocol {
    func getRandomPhotos(completion: @escaping (Result<[UnplashImage], NetworkError>) -> Void)
    func getSearchPhotos(query: String,
                         completion: @escaping (Result<SearchUnplashImage, NetworkError>) -> Void)
    func fetchImage(from model: UnplashImage,
                    completion: @escaping (Result<Data, NetworkError>) -> Void)
}

final class FindPhotoNetworkService: FindPhotoNetworkServiceProtocol {
    
    private var session: URLSession
    private var components = URLComponents()
    private var key = "Sn1s5ek1E7rZTNrYSKiiKmrRMC6n5H9d7QE0AnbeGt8"
    private let count = 30
    
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
        let configuration = URLSessionConfiguration.default
        session = URLSession(configuration: configuration)
        components.scheme = "https"
        components.host = "api.unsplash.com"
    }
    
    func getRandomPhotos(completion: @escaping (Result<[UnplashImage], NetworkError>) -> Void) {
        let path = "/photos/random"
        let parameters: [String: String] = ["count": "\(count)", "client_id": "\(key)"]
        guard let url = getURL(path: path, params: parameters) else {
            completion(.failure(.urlError))
            return
        }
        let request = URLRequest(url: url)
        
        networkService.requestData(request: request, completion: completion)
    }
    
    func getSearchPhotos(query: String,
                         completion: @escaping (Result<SearchUnplashImage, NetworkError>) -> Void) {
        let path = "/search/photos"
        let parameters: [String: String] = ["query": "\(query)", "client_id": "\(key)"]
        guard let url = getURL(path: path, params: parameters) else {
            completion(.failure(.urlError))
            return
        }
        let request = URLRequest(url: url)

        networkService.requestData(request: request, completion: completion)
    }
    
    func fetchImage(from model: UnplashImage,
                    completion: @escaping (Result<Data, NetworkError>) -> Void) {
        guard let urlString = model.urls?.small,
              let url = URL(string: urlString) else {
            completion(.failure(.urlError))
            return
        }
        let request = URLRequest(url: url)
        
        networkService.requestData(request: request, completion: completion)
    }
    
    private func getURL(path: String, params: [String: String]) -> URL? {
        components.path = path
        components.queryItems = params.map { URLQueryItem(name: $0, value: $1) }
        return components.url
    }
}
