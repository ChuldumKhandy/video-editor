//
//  NetworkService.swift
//  VideoEditor
//
//  Created by Хандымаа Чульдум on 27.01.2023.
//

import Foundation

enum NetworkError: Error {
    case urlError
    case serverError
    case notData
    case decodeError
}

protocol NetworkServiceProtocol {
    func getRandomPhotos(completion: @escaping (Result<[UnplashImage], NetworkError>) -> Void)
    func getSearchPhotos(query: String,
                         completion: @escaping (Result<SearchUnplashImage, NetworkError>) -> Void)
    func fetchImage(from model: UnplashImage,
                    completion: @escaping (Result<Data, NetworkError>) -> Void)
}

final class NetworkService: NetworkServiceProtocol {
    
    private var session: URLSession
    private var components = URLComponents()
    private var key = "Sn1s5ek1E7rZTNrYSKiiKmrRMC6n5H9d7QE0AnbeGt8"
    private let count = 30
    
    init() {
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
        
        requestData(request: request, completion: completion)
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

        requestData(request: request, completion: completion)
    }
    
    func fetchImage(from model: UnplashImage,
                    completion: @escaping (Result<Data, NetworkError>) -> Void) {
        guard let urlString = model.urls?.small,
              let url = URL(string: urlString) else {
            completion(.failure(.urlError))
            return
        }
        
        session.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(.serverError))
                debugPrint(String(describing: error))
                return
            }
            guard let data = data else {
                completion(.failure(.notData))
                debugPrint(String(describing: error))
                return
            }
            completion(.success(data))
        }.resume()
        
    }
    
    private func requestData<T: Decodable>(request: URLRequest,
                                           completion: @escaping (Result<T, NetworkError>) -> Void) {
        session.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(.serverError))
                debugPrint(String(describing: error))
                return
            }
            
            guard let data = data else {
                completion(.failure(.notData))
                debugPrint(String(describing: error))
                return
            }
            
            do {
                let result = try JSONDecoder().decode(T.self, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(.decodeError))
                debugPrint("Failed to decode...")
            }
        }.resume()
    }
    
    private func getURL(path: String, params: [String: String]) -> URL? {
        components.path = path
        components.queryItems = params.map { URLQueryItem(name: $0, value: $1) }
        return components.url
    }
}
