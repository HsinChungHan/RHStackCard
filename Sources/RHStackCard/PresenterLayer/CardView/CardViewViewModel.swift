//
//  CardViewViewModel.swift
//  SlidingCard
//
//  Created by Chung Han Hsin on 2024/3/23.
//

import UIKit

public protocol CardViewViewModelDelegate: AnyObject {
    func cardViewViewModel(_ cardViewViewModel: CardViewViewModel, didTapOutOfIndex direction: CardViewViewModel.OutOfIndexDirection)
    func cardViewViewModel(_ cardViewViewModel: CardViewViewModel, didUpdateCurrentImage image: UIImage, withCurrentImageIndex index: Int)
    func cardViewViewModel(_ cardViewViewModel: CardViewViewModel, didInitImages images: [UIImage])
    func cardViewViewModel(_ cardViewViewModel: CardViewViewModel, didResetCardView: Bool)
    func cardViewViewModel(_ cardViewViewModel: CardViewViewModel, didUpdateActionHint state: CardViewViewModel.ActionHintState)

}

open class CardViewViewModel {
    weak var delegate: CardViewViewModelDelegate?
    var card: (any Card)? = nil
    var currentImageIndex: Int? = nil {
        didSet {
            guard
                let currentImageIndex,
                let images
            else { return }
            delegate?.cardViewViewModel(self, didUpdateCurrentImage: images[currentImageIndex], withCurrentImageIndex: currentImageIndex)
        }
    }
    
    var images: [UIImage]? = nil
}

// MARK: - Sliding Action
extension CardViewViewModel {
    public struct ActionHintState {
        public var leftAlpha: CGFloat
        public var rightAlpha: CGFloat
        public var topAlpha: CGFloat
        
        public static let hidden = ActionHintState(leftAlpha: 0, rightAlpha: 0, topAlpha: 0)
    }
    
    /// 手勢滑動即時回報，VM 產生對應的提示狀態
    func didSlideChanged(direction: SlidingDirection, translation: CGPoint) {
        let tx = translation.x
        let ty = translation.y
        var state: ActionHintState = .hidden
        
        switch direction {
        case .toTop:
            let alpha = max(0, (-ty - abs(tx) * 1) / 100)
            state = ActionHintState(leftAlpha: 0, rightAlpha: 0, topAlpha: alpha)
            
        case .toRight:
            let alpha = max(0, tx / 100)
            state = ActionHintState(leftAlpha: 0, rightAlpha: alpha, topAlpha: 0)
            
        case .toLeft:
            let alpha = max(0, -tx / 100)
            state = ActionHintState(leftAlpha: alpha, rightAlpha: 0, topAlpha: 0)
            
        case .backToIdentity, .none:
            state = .hidden
        }
        
        delegate?.cardViewViewModel(self, didUpdateActionHint: state)
    }
    
    func reset() {
        delegate?.cardViewViewModel(self, didUpdateActionHint: .hidden)
        
        card = nil
        images?.removeAll()
        currentImageIndex = nil
        
        delegate?.cardViewViewModel(self, didResetCardView: true)
    }
}


// MARK: - Internal Methods
extension CardViewViewModel {
    public enum OutOfIndexDirection {
        case left
        case right
        case stillIncludeIndex
    }
    
    func setCurrentPhotoIndex(shouldAdvanceNextPhoto: Bool) {
        guard
            currentImageIndex != nil,
            images != nil
        else { return }
        let addedIndex = shouldAdvanceNextPhoto ? 1 : -1
        let nextPhotoIndex = currentImageIndex! + addedIndex
        guard nextPhotoIndex >= 0 else {
            delegate?.cardViewViewModel(self, didTapOutOfIndex: .left)
            return
        }
        guard nextPhotoIndex <= images!.count - 1 else {
            delegate?.cardViewViewModel(self, didTapOutOfIndex: .right)
            return
        }
        currentImageIndex = nextPhotoIndex
        delegate?.cardViewViewModel(self, didTapOutOfIndex: .stillIncludeIndex)
        delegate?.cardViewViewModel(self, didUpdateCurrentImage: images![currentImageIndex!], withCurrentImageIndex: currentImageIndex!)
    }
    
    func setupImageNamesCard<T: Card>(with card: T) {
        self.card = card
        self.images = card.imageNames.compactMap { UIImage.init(named: $0) }
        delegate?.cardViewViewModel(self, didInitImages: images!)
        currentImageIndex = (images!.isEmpty) ? nil : 0
    }
    
    func setupImageURLsCard<T: Card>(with card: T) {
        self.card = card
        let imagesCount = max(card.imageNames.count, card.imageURLs.count)
        images = Array(repeating: UIImage(), count: imagesCount)
        delegate?.cardViewViewModel(self, didInitImages: images!)
        currentImageIndex = (images!.isEmpty) ? nil : 0
    }
    
    func updateImage(with data: Data, at index: Int) {
        let image = UIImage(data: data) ?? UIImage()
        self.images?[index] = image
        if index == currentImageIndex {
            delegate?.cardViewViewModel(self, didUpdateCurrentImage: image, withCurrentImageIndex: currentImageIndex!)
        }
    }
    
    func updateImages(with names: [String]) {
        let images = names.compactMap { UIImage.init(named: $0) }
        self.images = images
    }
}
