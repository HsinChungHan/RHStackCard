//
//  CardDeskViewViewModel.swift
//  SlidingCard
//
//  Created by Chung Han Hsin on 2024/3/23.
//

import UIKit

protocol CardDeskViewViewModelDelegate: AnyObject {
    func cardDeskViewViewModel(_ cardDeskViewViewModel: CardDeskViewViewModel, didDistributeCardView cardView: CardView)
    func cardDeskViewViewModel(_ cardDeskViewViewModel: CardDeskViewViewModel, didGenerateAllCards: Bool)
}

class CardDeskViewViewModel {
    weak var delegate: CardDeskViewViewModelDelegate?
    private lazy var cardViewsManager = CardViewsManagerUseCase.init(delegate: self)
    
    private lazy var imageRepository = ImageRepository.init(imageNetworkService: ImageNetworkService(domainURL: domainURL), imageStoreService: ImageStoreService())
    private lazy var loadCardImagesUseCase: LoadCardImagesUseCase = LoadCardImagesUseCase(imageRepository: imageRepository)
    
    let domainURL: URL?
    init(domainURL: URL?) {
        self.domainURL = domainURL
    }
}

// MARK: - Computed Poroperties
extension CardDeskViewViewModel {
    var cardViews: [CardView] {
        cardViewsManager.presentingCardViews
    }
    
    var currentCardView: CardView? {
        cardViews.first
    }
}

// MARK: - Internal Methods
extension CardDeskViewViewModel {
    func addCards(with cards: [Card]) {
        cardViewsManager.addNewCards(with: cards)
    }
    
    func popCardView() {
        cardViewsManager.popCardView()
    }
}

// MARK: - Private Helpers
private extension CardDeskViewViewModel {
    // 只有那些圖片是要用 URL 抓的，才會經由 ImageRepository 提供圖片
    // 否則直接由 cardViewsManager 要求 cardView render asset 圖片
    func loadImages(with cards: [Card]) {
        cards.forEach { card in
            loadImage(with: card)
        }
    }
    
    func loadImage(with card: Card) {
        guard !card.imageURLs.isEmpty else { return }
        
        loadCardImagesUseCase.loadCardImages(with: card) { [weak self] result in
            guard let self else { return }
            switch result {
            case let .success((imageIndex, imageData)):
                self.cardViewsManager.updateCardURLImages(with: imageData, at: imageIndex, for: card)
            case .failure(_):
                return
            }
        }
    }
}

extension CardDeskViewViewModel: CardViewsManagerUseCaseDelegate {
    func cardViewsManager(_ cardViewsManager: CardViewsManagerUseCase, withAddedCards cards: [Card]) {
        loadImages(with: cards)
    }
    
    func cardViewsManager(_ cardViewsManager: CardViewsManagerUseCase, didDistributeCardView: Bool, cardView: CardView, card: Card) {
        loadImage(with: card)
        delegate?.cardDeskViewViewModel(self, didDistributeCardView: cardView)
    }
    
    func cardViewsManager(_ cardViewsManager: CardViewsManagerUseCase, didGenerateAllCards: Bool) {
        delegate?.cardDeskViewViewModel(self, didGenerateAllCards: true)
    }
}
