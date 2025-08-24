//
//  ImageDownloader.swift
//  SlidingCard
//
//  Created by Chung Han Hsin on 2024/3/25.
//

import Foundation

enum ImageRepositoryError: Error {
    case jsonError
    case networkError
}

protocol ImageRepositoryProtocol {
    func loadImage(with fullUrl: String, completion: @escaping (Result<Data, ImageRepositoryError>) -> Void)
}

class ImageRepository: ImageRepositoryProtocol {
    let imageNetworkService: ImageNetworkServiceProtocol
    let imageStoreService: ImageStoreServiceProtocol
    init(
        imageNetworkService: ImageNetworkServiceProtocol,
        imageStoreService: ImageStoreServiceProtocol) {
        self.imageNetworkService = imageNetworkService
        self.imageStoreService = imageStoreService
    }
    
    fileprivate func extractPath(from fullUrl: String) -> String? {
        guard let url = URL(string: fullUrl) else {
            return nil
        }
        return url.path
    }
    
    func loadImage(with fullUrl: String, completion: @escaping (Result<Data, ImageRepositoryError>) -> Void) {
        guard let path = extractPath(from: fullUrl) else { return }
        let imageID = path.replacingOccurrences(of: "/", with: "")
        imageStoreService.loadImage(with: imageID) {[weak self] result in
            guard let self else { return }
            switch result {
            case let .success(data):
                completion(.success(data))
            case .failure(_):
                self.imageNetworkService.downloadImage(with: path) { result in
                    switch result {
                    case let .success(data):
                        self.imageStoreService.insertImage(with: imageID, imageData: data) { _ in }
                        completion(.success(data))
                    default:
                        completion(.failure(.networkError))
                    }
                }
            }
        }
    }
}
