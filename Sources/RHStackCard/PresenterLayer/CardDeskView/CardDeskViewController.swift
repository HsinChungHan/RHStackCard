//
//  CardDeskViewController.swift
//  SlidingCard
//
//  Created by Chung Han Hsin on 2024/3/23.
//

import UIKit

public protocol CardDeskViewControllerDelegate: AnyObject {
    func cardDeskViewController(_ cardDeskVC: CardDeskViewController, didReciveCardViewSlidingEvent event: ObservableEvents.CardViewEvents.SlidingEvent)
    func cardDeskViewController(_ cardDeskVC: CardDeskViewController, willPerformCardViewAction direction: SlidingDirection)
    func cardDeskViewController(_ cardDeskVC: CardDeskViewController, didPerformCardViewAction direction: SlidingDirection)
}

public protocol CardDeskViewControllerDataSource: AnyObject {
    var cards: [Card] { get }
    var domainURL: URL? { get }
}

public class CardDeskViewController: UIViewController {
    private lazy var vibrationAnimationController = VibrationAnimationController(dataSource: self, delegate: self)
    private lazy var viewModel = CardDeskViewViewModel(domainURL: dataSource?.domainURL)
    private lazy var panGestureRecognizer = makePanGestureRecognizer()
    private lazy var slidingEventObserver = SlidingEventObserver()
    private lazy var cardViewControlBar = makeCardViewControlBar(with: self)
    private let hapticsPort = UIKitHapticsAdapter()
    private var currentCardView: CardView? { viewModel.currentCardView }
    
    public weak var delegate: CardDeskViewControllerDelegate?

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
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        registerCardViewType()
        view.addGestureRecognizer(panGestureRecognizer)
        setupLayout()
        addObserver(with: slidingEventObserver)
        bindEvent()
    }
    
    public func addNewCards() {
        viewModel.addNewCards(with: _cards)
    }
}


// MARK: - Public APIs
public extension CardDeskViewController {
    func registerCardViewType(withCardViewID cardViewID: String, cardViewType: CardView.Type) {
        CardViewType.register(withCardViewID: cardViewID, cardViewType: cardViewType)
    }
    
    func triggerTaskManager(slideAction: CardViewAction) {
        viewModel.doCardViewControlBarEvent(slideAction: slideAction, cards: _cards)
    }
}

// MARK: - Private helpers Methods
private extension CardDeskViewController {
    func registerCardViewType() {
        registerCardViewType(withCardViewID: "BasicCardView", cardViewType: BasicCardView.self)
    }
    
    func addObserver(with slidingEventObserver: SlidingEventObserver) {
        ObservableSlidingAnimation.shared.addObserver(slidingEventObserver)
    }
    
    func bindEvent() {
        slidingEventObserver.didUpdateValue = { [weak self] event in
            guard let self else { return }
            self.cardViewControlBar.handle(slidingEvent: event)
        }
    }
    
    func setupLayout() {
        view.addSubview(cardViewControlBar)
        cardViewControlBar.constraint(bottom: view.snp.bottom, centerX: view.snp.centerX, padding: .init(top: 0, left: 0, bottom: 24, right: 0))
    }
    
    func makeCardViewControlBar(with delegate: CardViewControlBarDelegate) -> CardViewControlBar {
        let bar = CardViewControlBar(buttonsShouldHaveInitialColor: false)
        bar.delegate = delegate
        return bar
    }
    
    func makePanGestureRecognizer() -> UIPanGestureRecognizer {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        return panGesture
    }
    
    @objc func handlePan(gesture: UIPanGestureRecognizer){
        viewModel.handlePan(gesture: gesture)
    }
}

// MARK: - CardDeskViewViewModelDelegate
extension CardDeskViewController: CardDeskViewViewModelDelegate {
    func cardDeskViewViewModel(_ cardDeskViewViewModel: CardDeskViewViewModel, didReciveCardViewSlidingEvent event: ObservableEvents.CardViewEvents.SlidingEvent) {
        cardViewControlBar.handle(slidingEvent: event)
        
        delegate?.cardDeskViewController(self, didReciveCardViewSlidingEvent: event)
    }
    
    func cardDeskViewViewModel(_ cardDeskViewViewModel: CardDeskViewViewModel, willPerformCardViewAction direction: SlidingDirection) {
        view.isUserInteractionEnabled = false
        delegate?.cardDeskViewController(self, willPerformCardViewAction: direction)
    }
    
    func cardDeskViewViewModel(_ cardDeskViewViewModel: CardDeskViewViewModel, didPerformCardViewAction direction: SlidingDirection) {
        view.isUserInteractionEnabled = true
        delegate?.cardDeskViewController(self, didPerformCardViewAction: direction)
    }
    
    func cardDeskViewViewModel(_ cardDeskViewViewModel: CardDeskViewViewModel, didDistributCardViewForSingleCard singleCardView: CardView) {
        if !view.subviews.contains(where: { $0 === singleCardView }) {
            singleCardView.delegate = self
            view.insertSubview(singleCardView, at: 0)
            singleCardView.fillSuperView()
        }
        
        viewModel.scaleSizeManager.presentingCardViews = viewModel.cardViews
        viewModel.scaleSizeManager.scaleWaitingCardViews()
    }
    
    func cardDeskViewViewModel(_ cardDeskViewViewModel: CardDeskViewViewModel, didDistributCardViewsForAddedCards presentingCardViews: [CardView]) {
        presentingCardViews.forEach { cardView1 in
            if !view.subviews.contains(where: { $0 === cardView1 }) {
                cardView1.delegate = self
                view.insertSubview(cardView1, at: 0)
                cardView1.fillSuperView()
            }
        }
    }
    
    func cardDeskViewViewModel(_ cardDeskViewViewModel: CardDeskViewViewModel, didGenerateAllCards: Bool) {}
}

// MARK: - CardViewDelegate
extension CardDeskViewController: CardViewDelegate {
    public func cardView(_ cardView: CardView, didTapOutOfIndex direction: CardViewViewModel.OutOfIndexDirection) {
        switch direction {
        case .left:
            hapticsPort.impact(.heavy, intensity: 1.0)
            vibrationAnimationController.doBriefVibration(angle: -5)
        case .right:
            hapticsPort.impact(.heavy, intensity: 1.0)
            vibrationAnimationController.doBriefVibration(angle: 5)
        case .stillIncludeIndex:
            hapticsPort.impact(.medium, intensity: 1.0)
        }
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

// MARK: - CardViewControlBarDelegate
extension CardDeskViewController: CardViewControlBarDelegate {
    public func cardViewControlBar(_ cardViewControlBar: CardViewControlBar, slideAction: CardViewAction) {
        viewModel.doCardViewControlBarEvent(slideAction: slideAction, cards: _cards)
    }
}
 
