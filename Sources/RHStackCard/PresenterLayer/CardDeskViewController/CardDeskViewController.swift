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
    }
    
    public func registerCardViewType(withCardViewID cardViewID: String, cardViewType: CardView.Type) {
        CardViewTypeManager.register(withCardViewID: cardViewID, cardViewType: cardViewType)
    }
    
    private func registerCardViewType() {
        registerCardViewType(withCardViewID: "BasicCardView", cardViewType: BasicCardView.self)
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
