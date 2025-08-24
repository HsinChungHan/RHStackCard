//
//  ImageNetworkService.swift
//  SlidingCard
//
//  Created by Chung Han Hsin on 2024/3/25.
//

import Foundation
import RHNetworkAPI

protocol ImageNetworkServiceProtocol {
    func downloadImage(with path: String, completion: @escaping (Result<Data, Error>) -> Void)
}

class ImageNetworkService: ImageNetworkServiceProtocol {
    let factory = RHNetworkAPIImplementationFactory()
    var networkAPI: RHNetworkAPIProtocol? = nil
    let headers: [String : String] =
    [
        "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.183 Safari/537.36"
    ]
    init(domainURL: URL?) {
        guard let domainURL else { return }
        networkAPI = factory.makeNonCacheAndNoneUploadProgressClient(with: domainURL, headers: headers)
    }
    
    func downloadImage(with path: String, completion: @escaping (Result<Data, Error>) -> Void) {
        networkAPI?.get(path: path, queryItems: []) { result in
            switch result {
            case let .success(data, _):
                completion(.success(data))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}

extension ImageNetworkService {
    
}
