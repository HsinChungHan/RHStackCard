//
//  CardViewControlBar.swift
//  Tinder
//
//  Created by Chung Han Hsin on 2021/10/11.
//

import UIKit

public protocol CardViewControlBarDelegate: AnyObject {
    func cardViewControlBar(_ cardViewControlBar: CardViewControlBar, slideAction: CardViewAction)
}

public class CardViewControlBar: UIView {
    weak var delegate: CardViewControlBarDelegate?
    
    lazy var controlButtons = makeControlButtons()
    lazy var controlStackView = makeControlStackView()
    
    var rewindButton: HightlightedButton { controlButtons[getButtonIndex(with: .rewind)] }
    var nopeButton: HightlightedButton { controlButtons[getButtonIndex(with: .nope)] }
    var superLikeButton: HightlightedButton { controlButtons[getButtonIndex(with: .superLike)] }
    var likeButton: HightlightedButton { controlButtons[getButtonIndex(with: .like)] }
    var refreshButton: HightlightedButton { controlButtons[getButtonIndex(with: .refresh)] }
    
    
    let buttonsShouldHaveInitialColor: Bool
    
    init(buttonsShouldHaveInitialColor: Bool) {
        self.buttonsShouldHaveInitialColor = buttonsShouldHaveInitialColor
        super.init(frame: .zero)
        addTargetsForControlButtons()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Interanl functions
private extension CardViewControlBar {
    func setupLayout() {
        addSubview(controlStackView)
        
        controlStackView.fillSuperView()
        
        controlStackView.arrangedSubviews.forEach {
            $0.constrainWidth(40).constrainHeight(40)
            $0.layer.cornerRadius = 40 / 2
            $0.clipsToBounds = true
        }
    }
    
    func setColorAlpha(with action: CardViewAction, alpha: CGFloat) {
        let button = toButton(with: action)
        button.backgroundColor = action.color.withAlphaComponent(alpha)
    }
    
    func resetColorAlpha(except action: CardViewAction) {
        [CardViewAction.nope, CardViewAction.like, CardViewAction.superLike].forEach {
            if $0 != action {
                setColorAlpha(with: $0, alpha: 0.0)
            }
        }
    }
    
    func setSizeAnimation(with action: CardViewAction, scale: CGFloat) {
        let button = toButton(with: action)
        var scaleX = CGFloat(1+scale)
        if scaleX <= 1 {
            button.transform = .identity
            return
        } else if scaleX > 2 {
            scaleX = 2
        }
        let sizeTransformation = CGAffineTransform.init(scaleX: scaleX, y: scaleX)
        button.transform = sizeTransformation
    }
    
    func resetSizeAnimation(except action: CardViewAction) {
        let actions: [CardViewAction] = [.nope, .like, .superLike, .refresh]
        actions.forEach {
            if $0 != action {
                setSizeIdenty(with: $0)
            }
        }
    }
    
    func visualReset(with action: CardViewAction) {
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1, options: .curveEaseOut) {[unowned self] in
            self.setColorAlpha(with: action, alpha: 0)
            self.setSizeIdenty(with: action)
        }
    }
    
    func setSizeIdenty(with action: CardViewAction) {
        toButton(with: action).transform = .identity
    }
    
    func disableAllControls() {
        controlButtons.forEach { $0.isEnabled = false }
    }
    
    func enableAllControls() {
        controlButtons.forEach { $0.isEnabled = true }
    }
    
    func toButton(with action: CardViewAction) -> UIButton {
        switch action {
        case .like:
            return likeButton
        case .nope:
            return nopeButton
        case .superLike:
            return superLikeButton
        case .refresh:
            return refreshButton
        case .rewind:
            return rewindButton
        }
        return UIButton()
    }
}

// MARK : - Internal methods
extension CardViewControlBar {
    public func handleSlideBehaviorLabelAlpha(with slidingEvent: ObservableEvents.CardViewEvents.SlidingEvent) {
        let status = slidingEvent.status
        let translation = slidingEvent.translation
        guard let action = slidingEvent.action else { return }
        if status != .sliding {
            visualReset(with: action)
            return
        }
        
        let translationXDirection = translation.x
        let translationYDirection = translation.y
        
        var alpha: CGFloat = 0.0
        
        switch action {
        case .superLike:
            alpha = (-translationYDirection - abs(translationXDirection) * 1) / 100
            resetSizeAnimation(except: .superLike)
            resetColorAlpha(except: .superLike)
        case .like:
            alpha = translationXDirection / 100
            resetSizeAnimation(except: .like)
            resetColorAlpha(except: .like)
        case .nope:
            alpha = -translationXDirection / 100
            resetSizeAnimation(except: .nope)
            resetColorAlpha(except: .nope)
        default:
            break
        }
        setColorAlpha(with: action, alpha: alpha)
        setSizeAnimation(with: action, scale: alpha)
    }
}

// MARK: - Factory Methods
private extension CardViewControlBar {
    func makeControlButtons() -> [HightlightedButton] {
        let buttons = CardViewAction.allCases.map { slideAction -> HightlightedButton in
            let initialAlpha = (self.buttonsShouldHaveInitialColor == true) ? 1.0 : 0.0
            let button = HightlightedButton.init(normalColor: slideAction.color.withAlphaComponent(initialAlpha), hightlightedColor: slideAction.color.withAlphaComponent(1.0))
            if self.buttonsShouldHaveInitialColor {
                button.backgroundColor = slideAction.color
            }
            button.layer.borderColor = slideAction.color.cgColor
            button.layer.borderWidth = 1.0
            button.setImage(UIImage(named: slideAction.iconName), for: .normal)
            button.imageView?.contentMode = .scaleAspectFit
            return button
        }
        return buttons
    }
    
    func makeControlStackView() -> UIStackView {
        let view = UIStackView()
        view.distribution = .equalCentering
        view.axis = .horizontal
        view.spacing = 32
        controlButtons.forEach { view.addArrangedSubview($0) }
        return view
    }
    
    func addTargetsForControlButtons() {
        rewindButton.addTarget(self, action: #selector(handleRewindButtonAction), for: .touchUpInside)
        nopeButton.addTarget(self, action: #selector(handleNopeButtonAction), for: .touchUpInside)
        superLikeButton.addTarget(self, action: #selector(handleSuperLikeButtonAction), for: .touchUpInside)
        likeButton.addTarget(self, action: #selector(handleLikeButtonAction), for: .touchUpInside)
        refreshButton.addTarget(self, action: #selector(handleRefreshButtonAction), for: .touchUpInside)
        
    }
    
    @objc func handleRewindButtonAction(_ sender: HightlightedButton) {
        sender.setIdentityAnimation() {}
//        delegate?.cardViewControlBar(self, slideAction: .rewind)
    }
    
    @objc func handleNopeButtonAction(_ sender: HightlightedButton) {
        sender.setIdentityAnimation() {}
        delegate?.cardViewControlBar(self, slideAction: .nope)
    }
    
    @objc func handleSuperLikeButtonAction(_ sender: HightlightedButton) {
        sender.setIdentityAnimation() {}
        delegate?.cardViewControlBar(self, slideAction: .superLike)
    }
    
    @objc func handleLikeButtonAction(_ sender: HightlightedButton) {
        sender.setIdentityAnimation() {}
        delegate?.cardViewControlBar(self, slideAction: .like)
    }
    
    @objc func handleRefreshButtonAction(_ sender: HightlightedButton) {
        sender.setIdentityAnimation() {}
        delegate?.cardViewControlBar(self, slideAction: .refresh)
    }
}

// MARK: - Helpers
private extension CardViewControlBar {
    func getButtonIndex(with action: CardViewAction) -> Int {
        switch action {
        case .rewind:
            return 0
        case .nope:
            return 1
        case .superLike:
            return 2
        case .like:
            return 3
        case .refresh:
            return 4
        }
    }
    
}
