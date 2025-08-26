//
//  File.swift
//  
//
//  Created by Chung Han Hsin on 2025/8/25.
//

import UIKit

// MARK: - Main Interface Protocol
/// The main interface protocol for RHStackCard framework
/// Provides abstraction for card swiping functionality integration
public protocol RHStackCardInterfaceProtocol {
    
    // MARK: - Properties
    
    /// The card desk view controller that handles the card presentation
    var cardDeskViewController: CardDeskViewController? { get }
    
    /// The card view control bar for manual card actions
    var cardViewControlBar: CardViewControlBar? { get }
    
    // MARK: - Setup Methods
    
    /// Setup the card desk with data source and delegate
    /// - Parameters:
    ///   - dataSource: The data source that provides cards and domain URL
    ///   - delegate: The delegate to handle card events
    /// - Returns: The configured card desk view controller
    @discardableResult
    func setup(
        dataSource: CardDeskViewControllerDataSource,
        delegate: CardDeskViewControllerDelegate
    ) -> CardDeskViewController
    
    /// Fetch the new card from the remote
    func addNewCards()
    
    /// Setup the control bar for manual card actions
    /// - Parameter delegate: The delegate to handle control bar events
    /// - Returns: The configured control bar
    @discardableResult
    func setupControlBar(delegate: CardViewControlBarDelegate) -> CardViewControlBar
    
    // MARK: - Card Registration
    
    /// Register a custom card view type
    /// - Parameters:
    ///   - cardViewID: Unique identifier for the card view type
    ///   - cardViewType: The custom card view class
    func registerCustomCardView(cardViewID: String, cardViewType: CardView.Type)
    
    // MARK: - Control Methods
    
    /// Manually trigger a card action
    /// - Parameter action: The card action to perform
    func performAction(_ action: CardViewAction)
    
    /// Create a sliding event observer for custom handling
    /// - Returns: A new sliding event observer
    func createSlidingEventObserver() -> SlidingEventObserver
}
