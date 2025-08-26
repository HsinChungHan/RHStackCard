//
//  CardViewComponentsFactory.swift
//  SlidingCard
//
//  Created by Chung Han Hsin on 2024/3/27.
//

import UIKit

public class StackCardCoordinator {
    public init() {}

    public func makeCardDeskViewController(with dataSource: CardDeskViewControllerDataSource, assignDelegate delegate: CardDeskViewControllerDelegate) -> CardDeskViewController {
        let cardDeskViewController = CardDeskViewController.init(dataSource: dataSource)
        cardDeskViewController.delegate = delegate
        return cardDeskViewController
    }
    
    public func makeCardViewControlBar(with delegate: CardViewControlBarDelegate) -> CardViewControlBar {
        let bar = CardViewControlBar(buttonsShouldHaveInitialColor: false)
        bar.delegate = delegate
        return bar
    }
    
    public func makeSlidingEventObserver() -> SlidingEventObserver {
        return SlidingEventObserver()
    }
}
