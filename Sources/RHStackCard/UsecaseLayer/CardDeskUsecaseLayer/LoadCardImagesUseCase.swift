//
//  DownloadCardImagesUseCase.swift
//  SlidingCard
//
//  Created by Chung Han Hsin on 2024/3/27.
//

import Foundation

protocol LoadCardImagesUseCaseProtocol {
    func loadCardImages(with card: Card, completion: @escaping (Result<(Int, Data), Error>) -> Void)
}

final class LoadCardImagesUseCase: LoadCardImagesUseCaseProtocol {
    private lazy var loadImageCurrencyQueue = makeLoadImageCurrencyQueue()
    
    private let imageRepository: ImageRepositoryProtocol
    init(imageRepository: ImageRepositoryProtocol) {
        self.imageRepository = imageRepository
    }
    
    func loadCardImages(with card: Card, completion: @escaping (Result<(Int, Data), Error>) -> Void) {
        for (index, url) in card.imageURLs.enumerated() {
            loadImageCurrencyQueue.addOperation { [weak self] in
                guard let self else { return }
                self.imageRepository.loadImage(with: url.absoluteString) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case let .success(data):
                            completion(.success((index, data)))
                        case let .failure(error):
                            completion(.failure(error))
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Factory Methods
private extension LoadCardImagesUseCase {
    func makeLoadImageCurrencyQueue(with maxmumCurrencies: Int = 10) -> OperationQueue {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = maxmumCurrencies
        return queue
    }
}
