//
//  ImageStoreService.swift
//  SlidingCard
//
//  Created by Chung Han Hsin on 2024/3/25.
//

import Foundation
import RHCacheStoreAPI
import UIKit

enum ImageStoreServiceError: Error {
    case failureInsertion
    case failureLoad
    case failureDeletion
}

protocol ImageStoreServiceProtocol {
    func loadImage(with id: String, completion: @escaping (Result<Data, ImageStoreServiceError>) -> Void)
    func insertImage(with id: String, imageData: Data, completion: @escaping (Result<Void, ImageStoreServiceError>) -> Void)
    func deleteImage(with id: String, completion: @escaping (Result<Void, ImageStoreServiceError>) -> Void)
}

class ImageStoreService: ImageStoreServiceProtocol {
    let factory = RHCacheStoreAPIImplementationFactory()
    
    lazy var store = factory.makeActorCodableImageDataStore(with: imageStoreURL)
    
    func loadImage(with id: String, completion: @escaping (Result<Data, ImageStoreServiceError>) -> Void) {
        Task {
            Task {
                let fileName = "\(id)"
                let result = await store.retrieve(with: fileName)
                switch result {
                case .empty:
                    completion(.failure(.failureLoad))
                case let .found(data):
                    completion(.success(data))
                default:
                    completion(.failure(.failureLoad))
                }
            }
        }
    }
    
    func insertImage(with id: String, imageData: Data, completion: @escaping (Result<Void, ImageStoreServiceError>) -> Void) {
        Task {
            do {
                let fileName = "\(id)"
                try await store.insert(with: fileName, imageData: imageData)
                completion(.success(()))
            } catch {
                completion(.failure(.failureInsertion))
            }
        }
    }
    
    func deleteImage(with id: String, completion: @escaping (Result<Void, ImageStoreServiceError>) -> Void) {
        Task {
            do {
                let fileName = "\(id)"
                try await store.delete(with: fileName)
                completion(.success(()))
            } catch {
                completion(.failure(.failureDeletion))
            }
        }
    }
}

extension ImageStoreService {
    var imageStoreURL: URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}
