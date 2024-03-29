//
//  CardDeskViewController.swift
//  SlidingCard
//
//  Created by Chung Han Hsin on 2024/3/23.
//

import UIKit

public protocol CardDeskViewControllerDataSource: AnyObject {
    var cards: [Card] { get }
    var domainURL: URL? { get }
}

public class CardDeskViewController: UIViewController {
    private lazy var vibrationAnimationController = VibrationAnimationController(dataSource: self, delegate: self)
    
    private lazy var viewModel = CardDeskViewViewModel(domainURL: dataSource?.domainURL)
    private lazy var slidingEventObserver = SlidingEventObserver()
    private lazy var cardViewControlBar = makeCardViewControlBar(with: self)
    
    var currentCardView: CardView? {
        guard let currentCardView = viewModel.currentCardView else {
            taskManager.reset()
            return nil
        }
        return currentCardView
    }
    
    let taskManager = TaskManager()
    
    private var _cards: [Card] {
        guard let dataSource else { return [] }
        return dataSource.cards
    }
    
    private weak var dataSource: CardDeskViewControllerDataSource?
    init(dataSource: CardDeskViewControllerDataSource? = nil) {
        self.dataSource = dataSource
        super.init(nibName: nil, bundle: nil)
        viewModel.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var tapGestureRecognizer = makeTapGestureRecognizer()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        registerCardViewType()
        view.addGestureRecognizer(tapGestureRecognizer)
        viewModel.addCards(with: _cards)
        setupLayout()
        addObserver(with: slidingEventObserver)
        bindEvent()
    }
    
    public func registerCardViewType(withCardViewID cardViewID: String, cardViewType: CardView.Type) {
        CardViewTypeManager.register(withCardViewID: cardViewID, cardViewType: cardViewType)
    }
    
    private func registerCardViewType() {
        registerCardViewType(withCardViewID: "BasicCardView", cardViewType: BasicCardView.self)
    }
    
    private func addObserver(with slidingEventObserver: SlidingEventObserver) {
        ObservableSlidingAnimation.shared.addObserver(slidingEventObserver)
    }
    
    private func bindEvent() {
        slidingEventObserver.didUpdateValue = { [weak self] event in
            guard let self else { return }
            self.cardViewControlBar.handleSlideBehaviorLabelAlpha(with: event)
        }
    }
    
    private func setupLayout() {
        view.addSubview(cardViewControlBar)
        cardViewControlBar.constraint(bottom: view.snp.bottom, centerX: view.snp.centerX, padding: .init(top: 0, left: 0, bottom: 16, right: 0))
    }
}

// MARK: - Factory Methods
fileprivate extension CardDeskViewController {
    func makeTapGestureRecognizer() -> UITapGestureRecognizer {
        let tapGetsure = UITapGestureRecognizer(target: self, action: #selector(handleTap(gesture:)))
        return tapGetsure
    }
    
    @objc func handleTap(gesture: UITapGestureRecognizer) {
        let tapLocation = gesture.location(in: view)
        let shouldAdvanceNextPhoto = tapLocation.x > view.frame.midX ? true : false
        currentCardView?.setCurrentPhotoIndex(shouldAdvanceNextPhoto: shouldAdvanceNextPhoto)
    }
    
    func makeCardViewControlBar(with delegate: CardViewControlBarDelegate) -> CardViewControlBar {
        let bar = CardViewControlBar(buttonsShouldHaveInitialColor: false)
        bar.delegate = delegate
        return bar
    }
}

// MARK: - Internal Methods
extension CardDeskViewController {
    public func addInSuperViewController(with superViewController: UIViewController) {
        superViewController.addChild(self)
        didMove(toParent: superViewController)
    }
    
    public func doAppendNewCardsTask(with cards: [Card]) {
        viewModel.addCards(with: cards)
        taskManager.markCurrentTaskAsFinished()
    }
    
    public func doSwipeCardViewTask(with direction: SlidingDirection) {
        currentCardView?.swipe(to: direction)
    }
    
    public func slideTopCardView(with action: @escaping () -> Void) {
        taskManager.addSlideOutAction(action)
    }
}

extension CardDeskViewController: CardDeskViewViewModelDelegate {
    func cardDeskViewViewModel(_ cardDeskViewViewModel: CardDeskViewViewModel, didDistributeCardView cardView: CardView) {
        cardView.delegate = self
        view.insertSubview(cardView, at: 0)
        cardView.fillSuperView()
        taskManager.markCurrentTaskAsFinished()
        
//        cardView.transform = .identity

//        cardView.scaleToMinimumSize()
//        viewModel.cardViewsAnimationManager.scaleWaitingCardViews()
    }
    
    func cardDeskViewViewModel(_ cardDeskViewViewModel: CardDeskViewViewModel, didGenerateAllCards: Bool) {
        taskManager.markCurrentTaskAsFinished()
    }
}

extension CardDeskViewController: CardViewDelegate {
    public func cardView(_ cardView: CardView, didTapOutOfIndex direction: CardViewViewModel.OutOfIndexDirection) {
        switch direction {
        case .left:
            ImpactFeedbackController.startImpactFeedback(with: .heavy)
            vibrationAnimationController.doBriefVibration(angle: -5)
        case .right:
            ImpactFeedbackController.startImpactFeedback(with: .heavy)
            vibrationAnimationController.doBriefVibration(angle: 5)
        case .stillIncludeIndex:
            ImpactFeedbackController.startImpactFeedback(with: .medium)
        }
    }
    
    public func cardView(_ cardView: CardView, didRemoveCardViewFromSuperView: Bool) {
        if !didRemoveCardViewFromSuperView { return }
        
        viewModel.popCardView()
    }
}

// MARK: - VibrationAnimationControllerDataSource
extension CardDeskViewController: VibrationAnimationControllerDataSource {
    var targetView: UIView { view }
}

// MARK: - VibrationAnimationControllerDelegate
extension CardDeskViewController: VibrationAnimationControllerDelegate {
    func vibrationAnimationController(_ vibrationAnimationController: VibrationAnimationController, didEndVibrationAnimation: Bool) {
    }
}

extension CardDeskViewController: CardViewControlBarDelegate {
    public func cardViewControlBar(_ cardViewControlBar: CardViewControlBar, slideAction: CardViewAction) {
        let action = { [weak self] in
            guard let self else { return }
            let cardViewDirection = slideAction.cardViewDirection
            if cardViewDirection == .backToIdentity {
                let newCards = _cards
                doAppendNewCardsTask(with: newCards)
                return
            }
            doSwipeCardViewTask(with: cardViewDirection)
        }
        slideTopCardView(with: action)
    }
}
