//
//  File.swift
//  
//
//  Created by Chung Han Hsin on 2025/8/25.
//

import UIKit

// MARK: - Concrete Implementation
/// Concrete implementation of RHStackCardInterfaceProtocol
public class RHStackCardInterface: RHStackCardInterfaceProtocol {
    
    // MARK: - Public Properties
    public private(set) var cardDeskViewController: CardDeskViewController?
    public private(set) var cardViewControlBar: CardViewControlBar?
    
    // MARK: - Private Properties
    private let coordinator: StackCardCoordinator
    private weak var parentViewController: UIViewController?
    
    // MARK: - Initialization
    public init(coordinator: StackCardCoordinator = StackCardCoordinator()) {
        self.coordinator = coordinator
    }
    
    // MARK: - RHStackCardInterfaceProtocol Implementation
    @discardableResult
    public func setup(
        dataSource: CardDeskViewControllerDataSource,
        delegate: CardDeskViewControllerDelegate,
        in parentViewController: UIViewController
    ) -> CardDeskViewController {
        self.parentViewController = parentViewController
        
        let cardDeskVC = coordinator.makeCardDeskViewController(
            with: dataSource,
            in: parentViewController,
            assignDelegate: delegate
        )
        
        self.cardDeskViewController = cardDeskVC
        return cardDeskVC
    }
    
    @discardableResult
    public func setupControlBar(delegate: CardViewControlBarDelegate) -> CardViewControlBar {
        let controlBar = coordinator.makeCardViewControlBar(with: delegate)
        self.cardViewControlBar = controlBar
        return controlBar
    }
    
    public func registerCustomCardView(cardViewID: String, cardViewType: CardView.Type) {
        cardDeskViewController?.registerCardViewType(withCardViewID: cardViewID, cardViewType: cardViewType)
    }
    
    public func performAction(_ action: CardViewAction) {
        cardDeskViewController?.triggerTaskManager(slideAction: action)
    }
    
    public func createSlidingEventObserver() -> SlidingEventObserver {
        return coordinator.makeSlidingEventObserver()
    }
}
