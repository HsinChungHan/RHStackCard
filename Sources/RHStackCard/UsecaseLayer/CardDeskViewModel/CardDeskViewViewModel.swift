//
//  CardDeskViewViewModel.swift
//  SlidingCard
//
//  Created by Chung Han Hsin on 2024/3/23.
//

import UIKit

protocol CardDeskViewViewModelDelegate: AnyObject {
    func cardDeskViewViewModel(_ cardDeskViewViewModel: CardDeskViewViewModel, didDistributCardViewsForAddedCards presentingCardViews: [CardView])
    func cardDeskViewViewModel(_ cardDeskViewViewModel: CardDeskViewViewModel, didDistributCardViewForSingleCard singleCardView: CardView)
    
    func cardDeskViewViewModel(_ cardDeskViewViewModel: CardDeskViewViewModel, didGenerateAllCards: Bool)
    
    func cardDeskViewViewModel(_ cardDeskViewViewModel: CardDeskViewViewModel, willPerformCardViewAction direction: SlidingDirection)
    func cardDeskViewViewModel(_ cardDeskViewViewModel: CardDeskViewViewModel, didPerformCardViewAction: SlidingDirection)
    
    func cardDeskViewViewModel(_ cardDeskViewViewModel: CardDeskViewViewModel, didReciveCardViewSlidingEvent event: ObservableEvents.CardViewEvents.SlidingEvent)
}

class CardDeskViewViewModel {
    weak var delegate: CardDeskViewViewModelDelegate?
    private lazy var cardViewsManager: CardViewsManagerUseCaseProtocol = CardViewsManagerUseCase.init(delegate: self)
    
    private lazy var loadCardImagesUseCase: LoadCardImagesUseCaseProtocol = makeLoadCardImagesUseCase()
    
    let scaleSizeManager = ScaleSizeAnimationController()
    let taskManager = TaskManager()
    private lazy var slidingAnimationController = SlidingAnimationController(dataSource: self, delegate: self)
    private lazy var slidingEventObserver = SlidingEventObserver()

    let domainURL: URL?
    init(domainURL: URL?) {
        self.domainURL = domainURL
        addObserver(with: slidingEventObserver)
        bindEvent()
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
    func addNewCards(with cards: [Card]) {
        cardViewsManager.addNewCards(with: cards)
    }
    
    func popCardView() {
        cardViewsManager.popCardView()
    }
    
    func handlePan(gesture: UIPanGestureRecognizer) {
        slidingAnimationController.handlePan(gesture: gesture)
    }
    
    func doSwipeCardViewTask(with direction: SlidingDirection) {
        currentCardView?.swipe(to: direction)
        slidingAnimationController.performCardViewActionAnimation(with: direction)
    }
    
    func doCardViewControlBarEvent(slideAction: CardViewAction, cards: [Card]) {
        let action = { [weak self] in
            guard let self else { return }
            let cardViewDirection = slideAction.cardViewDirection
            switch cardViewDirection {
            // 當 slideAction 為 refresh 時， cardViewDirection 為 none
            case .none:
                self.addNewCards(with: cards)
                self.taskManager.markCurrentTaskAsFinished()
            default:
                self.doSwipeCardViewTask(with: cardViewDirection)
            }
        }
        taskManager.addSlideOutAction(action)
    }
}

// MARK: - Private Helpers
private extension CardDeskViewViewModel {
    // 只有需要用 URL 抓的圖片才會經由 ImageRepository 提供圖片
    // 否則直接由 cardViewsManager 要求 cardView render asset 圖片
    func loadImages(with cards: [Card]) {
        cards.forEach { card in
            loadImage(with: card)
        }
    }
    
    func loadImage<T: Card>(with card: T) {
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
    
    private func addObserver(with slidingEventObserver: SlidingEventObserver) {
        ObservableSlidingAnimation.shared.addObserver(slidingEventObserver)
    }
    
    private func bindEvent() {
        slidingEventObserver.didUpdateValue = { [weak self] event in
            guard let self else { return }
            self.delegate?.cardDeskViewViewModel(self, didReciveCardViewSlidingEvent: event)
        }
    }
}

// MARK: - Factory Methods
extension CardDeskViewViewModel {
    private func makeLoadCardImagesUseCase() -> LoadCardImagesUseCaseProtocol {
        let imageRepository: ImageRepositoryProtocol = ImageRepository.init(imageNetworkService: ImageNetworkService(domainURL: domainURL), imageStoreService: ImageStoreService())
        return LoadCardImagesUseCase(imageRepository: imageRepository)
    }
}

// MARK: - CardViewsManagerUseCaseDelegate
extension CardDeskViewViewModel: CardViewsManagerUseCaseDelegate {
    func cardViewsManager(_ cardViewsManager: CardViewsManagerUseCase, didDistributeCardView cardView: CardView, forSingleCard card: Card) {
        loadImage(with: card)
        taskManager.markCurrentTaskAsFinished()
        delegate?.cardDeskViewViewModel(self, didDistributCardViewForSingleCard: cardView)
    }
    
    func cardViewsManager(_ cardViewsManager: CardViewsManagerUseCase, didDistributeCardViews presentingCardViews: [CardView], whenAddNewCards cards: [Card]) {
        loadImages(with: cards)
        delegate?.cardDeskViewViewModel(self, didDistributCardViewsForAddedCards: cardViews)
    }
    
    func cardViewsManager(_ cardViewsManager: CardViewsManagerUseCase, didGenerateAllCards: Bool) {
        taskManager.reset()
        delegate?.cardDeskViewViewModel(self, didGenerateAllCards: true)
    }
}

// MARK: - SlidingAnimationControllerDataSource
extension CardDeskViewViewModel: SlidingAnimationControllerDataSource {
    var cardView: CardView? {
        currentCardView
    }
}

// MARK: - SlidingAnimationControllerDelegate
extension CardDeskViewViewModel: SlidingAnimationControllerDelegate {
    func slidingAnimationController(_ slidingAnimationController: SlidingAnimationController, didSlideChanged direction: SlidingDirection, withTransaltion translation: CGPoint) {
        let cardView = slidingAnimationController.cardView
        cardView?.viewModel.didSlideCahnged(with: direction, withTransaltion: translation)
        
        scaleSizeManager.presentingCardViews = cardViews
        scaleSizeManager.paningCurrentPresentingCardView(withTranslation: translation)
    }
        
    func slidingAnimationController(_ slidingAnimationController: SlidingAnimationController, willPerformCardViewAction direction: SlidingDirection) {
        delegate?.cardDeskViewViewModel(self, willPerformCardViewAction: direction)
        let cardView = slidingAnimationController.cardView
        switch direction {
        case .backToIdentity:
            cardView?.setActionLabelsToBeTransparent()
        default: break
        }
    }
    
    func slidingAnimationController(_ slidingAnimationController: SlidingAnimationController, cardViewDidPerformSwipeActionAnimation direction: SlidingDirection) {
        delegate?.cardDeskViewViewModel(self, didPerformCardViewAction: direction)
        if direction != .backToIdentity {
            popCardView()
        }
        
        scaleSizeManager.presentingCardViews = cardViews
        scaleSizeManager.scaleCurrentPresentCardView()
    }
}
