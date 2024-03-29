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
    
    func cardViewViewModel(_ cardViewViewModel: CardViewViewModel, didSlideDirection direction: SlidingDirection, withLabelAlpha alpha: CGFloat)
    
    func cardViewViewModel(_ cardViewViewModel: CardViewViewModel, didResetCardView: Bool)
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
    
    func didSlideCahnged(with direction: SlidingDirection, withTransaltion translation: CGPoint) {
        let translationXDirection = translation.x
        let translationYDirection = translation.y
        var alpha: CGFloat = 0.0
        switch direction {
        case .toTop:
            alpha = (-translationYDirection - abs(translationXDirection) * 1) / 100
        case .toRight:
            alpha = translationXDirection / 100
        case .toLeft:
            alpha = -translationXDirection / 100
        case .backToIdentity:
            break
        }
        delegate?.cardViewViewModel(self, didSlideDirection: direction, withLabelAlpha: alpha)
    }
    
    func reset() {
        didSlideCahnged(with: .backToIdentity, withTransaltion: CGPoint(x: 0, y: 0))
        card = nil
        images?.removeAll()
        currentImageIndex = nil
        delegate?.cardViewViewModel(self, didResetCardView: true)
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
