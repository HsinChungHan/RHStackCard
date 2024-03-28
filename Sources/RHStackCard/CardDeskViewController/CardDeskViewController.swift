//
//  CardDeskViewController.swift
//  SlidingCard
//
//  Created by Chung Han Hsin on 2024/3/23.
//

import UIKit

protocol CardDeskViewControllerDataSource: AnyObject {
    var cards: [Card] { get }
    var domainURL: URL? { get }
}

class CardDeskViewController: UIViewController {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addGestureRecognizer(tapGestureRecognizer)
        viewModel.addCards(with: _cards)
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
    func addInSuperViewController(with superViewController: UIViewController) {
        superViewController.addChild(self)
        didMove(toParent: superViewController)
    }
    
    func doAppendNewCardsTask(with cards: [Card]) {
        addNewCards(with: cards)
        taskManager.markCurrentTaskAsFinished()
    }
    
    func doSwipeCardViewTask(with direction: SlidingDirection) {
        currentCardView?.swipe(to: direction)
    }
    
    func slideTopCardView(with action: @escaping TaskManager.Task) {
        taskManager.addSlideOutAction(action)
    }
    
    // TODO: - Remove in the future
    func addNewCards(with cards: [Card]) {
        viewModel.addCards(with: cards)
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
    func cardView(_ cardView: CardView, didTapOutOfIndex direction: CardViewViewModel.OutOfIndexDirection) {
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
    
    func cardView(_ cardView: CardView, didRemoveCardViewFromSuperView: Bool) {
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
