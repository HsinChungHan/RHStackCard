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

final class CardDeskViewViewModel {
    weak var delegate: CardDeskViewViewModelDelegate?
    
    private lazy var cardsRepo = CardsRepository()
    private lazy var cardStackSchedulerUseCase: CardStackSchedulerUseCaseProtocol = CardStackSchedulerUseCase.init(delegate: self, cardsRepo: cardsRepo)
    
    private lazy var loadCardImagesUseCase: LoadCardImagesUseCaseProtocol = makeLoadCardImagesUseCase()
    
    let scaleSizeManager = ScaleSizeAnimationController()
    private let taskManager = TaskManager()
    private lazy var slidingAnimationController = SlidingAnimationController(dataSource: self, delegate: self)
    private lazy var slidingEventObserver = SlidingEventObserver()
    
    // MARK: - CardViewPoolService
    private lazy var cardViewPool = CardViewPoolService()
    private var presentingCardViews: [CardView] { cardViewPool.presentingCardViews }

    private let domainURL: URL?
    init(domainURL: URL?) {
        self.domainURL = domainURL
        addObserver(with: slidingEventObserver)
        bindEvent()
    }
}

// MARK: - Internal AIPs
extension CardDeskViewViewModel {
    var currentCardView: CardView? { cardViews.first }
    
    func handlePan(gesture: UIPanGestureRecognizer) {
        guard let gestureOnView = gesture.view else { return }
        slidingAnimationController.handlePan(.init(gesture: gesture, in: gestureOnView))
    }
    
    func doSwipeCardViewTask(with direction: SlidingDirection) {
        currentCardView?.swipe(to: direction)
        slidingAnimationController.performAction(direction)
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
    // 否則直接由 cardStackSchedulerUseCase 要求 cardView render asset 圖片
    func loadImages(with cards: [Card]) {
        cards.forEach { card in
            loadImage(with: card)
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

// MARK: - CardStackSchedulerUseCaseDelegate
extension CardDeskViewViewModel: CardStackSchedulerUseCaseDelegate {
    func cardStackSchedulerUseCase(_ cardStackSchedulerUseCase: CardStackSchedulerUseCase, prepareDistributeCardViews cards: [Card]) {
        loadImages(with: cards)
        cardStackSchedulerUseCase.willUpdateCardRepo()
        delegate?.cardDeskViewViewModel(self, didDistributCardViewsForAddedCards: cardViewPool.presentingCardViews)
    }
    
    func cardStackSchedulerUseCase(_ cardStackSchedulerUseCase: CardStackSchedulerUseCase, prepareDistributeCardView card: Card) {
        var cardView = cardViewPool.dequeCardView(with: card.cardViewTypeName)
        setupCardView(with: card, on: cardView)
        loadImage(with: card)
        taskManager.markCurrentTaskAsFinished()
        delegate?.cardDeskViewViewModel(self, didDistributCardViewForSingleCard: cardView)
    }
    
    func cardStackSchedulerUseCase(_ cardStackSchedulerUseCase: CardStackSchedulerUseCase, didGenerateAllCards: Bool) {
        taskManager.reset()
        delegate?.cardDeskViewViewModel(self, didGenerateAllCards: true)
    }
}

// MARK: - SlidingAnimationControllerDataSource
extension CardDeskViewViewModel: SlidingAnimationControllerDataSource {
    var cardView: CardView? { currentCardView }
}

// MARK: - SlidingAnimationControllerDelegate
extension CardDeskViewViewModel: SlidingAnimationControllerDelegate {
    func slidingAnimationController(_ slidingAnimationController: SlidingAnimationController, didSlideChanged direction: SlidingDirection, withTransaltion translation: CGPoint) {
        let cardView = slidingAnimationController.cardView
        cardView?.viewModel.didSlideChanged(direction: direction, translation: translation)
        
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

// MARK: - Interact with CardStackSchedulerUseCase
extension CardDeskViewViewModel {
    var cardViews: [CardView] { cardViewPool.presentingCardViews }
    
    func addNewCards(with cards: [Card]) {
        cardViewPool.initCardViewsPool(with: cards)
        cardStackSchedulerUseCase.addNewCards(with: cards)
    }
    
    func popCardView() {
        let isNotGeneratedAllCards = !cardViewPool.presentingCardViews.isEmpty && !cardStackSchedulerUseCase.presentingCards.isEmpty
        if isNotGeneratedAllCards {
            cardViewPool.enqueCardView()
            cardStackSchedulerUseCase.popCardView(presentingCardViewsCount: cardViewPool.presentingCardViews.count)
        } else {
            cardStackSchedulerUseCase(cardStackSchedulerUseCase as! CardStackSchedulerUseCase, didGenerateAllCards: true)
        }
    }
    
    func loadImage<T: Card>(with card: T) {
        guard !card.imageURLs.isEmpty else { return }
        
        loadCardImagesUseCase.loadCardImages(with: card) { [weak self] result in
            guard let self else { return }
            switch result {
            case let .success((imageIndex, imageData)):
                self.cardViewPool.presentingCardViews.forEach {
                    if $0.card?.uid == card.uid {
                        $0.updateCardImage(with: imageData, at: imageIndex)
                    }
                }
            case .failure(_):
                return
            }
        }
    }
    
    private enum CardImageSourceType {
        case fromAsset
        case fromURL
        
        static func getType<T: Card>(with card: T) -> Self {
            return card.imageNames.isEmpty ? .fromURL : .fromAsset
        }
    }
    
    func setupCardView(with card: Card, on cardView: CardView) {
        switch CardImageSourceType.getType(with: card) {
        case .fromAsset:
            cardView.setupImageNamesCard(with: card)
        case .fromURL:
            cardView.setupImageURLsCard(with: card)
        }
    }
}
