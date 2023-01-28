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
    func requestData<T: Decodable>(request: URLRequest,
                                   completion: @escaping (Result<T, NetworkError>) -> Void)
    func requestData(request: URLRequest,
                    completion: @escaping (Result<Data, NetworkError>) -> Void)
}

final class NetworkService: NetworkServiceProtocol {
    
    private var session: URLSession
    
    init() {
        let configuration = URLSessionConfiguration.default
        session = URLSession(configuration: configuration)
    }
    
    func requestData<T: Decodable>(request: URLRequest,
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
    
    func requestData(request: URLRequest,
                    completion: @escaping (Result<Data, NetworkError>) -> Void) {
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
            completion(.success(data))
        }.resume()
        
    }
}
