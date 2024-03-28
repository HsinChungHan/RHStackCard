//
//  CardViewControlBar.swift
//  Tinder
//
//  Created by Chung Han Hsin on 2021/10/11.
//

import UIKit

protocol CardViewControlBarDelegate: AnyObject {
    func cardViewControlBar(_ cardViewControlBar: CardViewControlBar, slideAction: CardViewAction)
}

class CardViewControlBar: UIView {
    weak var delegate: CardViewControlBarDelegate?
    
    lazy var controlButtons = makeControlButtons()
    lazy var controlStackView = makeControlStackView()
    
    var rewindButton: HightlightedButton { controlButtons[CardViewAction.rewind.rawValue] }
    var nopeButton: HightlightedButton { controlButtons[CardViewAction.nope.rawValue] }
    var superLikeButton: HightlightedButton { controlButtons[CardViewAction.superLike.rawValue] }
    var likeButton: HightlightedButton { controlButtons[CardViewAction.like.rawValue] }
    var refreshButton: HightlightedButton { controlButtons[CardViewAction.refresh.rawValue] }
    
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}

// MARK: - Interanl functions
extension CardViewControlBar {
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
        switch action {
        case .nope:
            nopeButton.backgroundColor = action.color.withAlphaComponent(alpha)
        case .superLike:
            superLikeButton.backgroundColor = action.color.withAlphaComponent(alpha)
        case .like:
            likeButton.backgroundColor = action.color.withAlphaComponent(alpha)
        default:
            break
        }
    }
    
    func setSizeAnimation(with action: CardViewAction, scale: CGFloat) {
        var scaleX = CGFloat(1+scale)
        
        var button: UIButton
        switch action {
        case .nope:
            button = nopeButton
        case .superLike:
            button = superLikeButton
        case .like:
            button = likeButton
        default:
            return
        }
        
        if scaleX <= 1 {
            button.transform = .identity
            return
        } else if scaleX > 2 {
            scaleX = 2
        }
        let sizeTransformation = CGAffineTransform.init(scaleX: scaleX, y: scaleX)
        button.transform = sizeTransformation
    }
    
    func visualReset(with action: CardViewAction) {
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1, options: .curveEaseOut) {[unowned self] in
            self.setColorAlpha(with: action, alpha: 0)
            self.setSizeIdenty(with: action)
        }
    }
    
    func setSizeIdenty(with action: CardViewAction) {
        var button: UIButton
        switch action {
        case .nope:
            button = nopeButton
        case .superLike:
            button = superLikeButton
        case .like:
            button = likeButton
        case .refresh:
            button = refreshButton
        default:
            return
        }
        button.transform = .identity
    }
    
    private func disableAllControls() {
        controlButtons.forEach { $0.isEnabled = false }
    }
    
    private func enableAllControls() {
        controlButtons.forEach { $0.isEnabled = true }
    }
}

// MARK : - Internal methods
extension CardViewControlBar {
    func handleSlideBehaviorLabelAlpha(with slidingEvent: ObservableEvents.CardViewEvents.SlidingEvent) {
        let status = slidingEvent.status
        let translation = slidingEvent.translation
        guard let action = slidingEvent.action else { return }
        if status == .performSlidingAction {
            visualReset(with: action)
            return
        }
        
        let translationXDirection = translation.x
        let translationYDirection = translation.y
        
        var alpha: CGFloat = 0.0
        
        switch action {
        case .superLike:
            alpha = (-translationYDirection - abs(translationXDirection) * 1) / 100
        case .like:
            alpha = translationXDirection / 100
        case .nope:
            alpha = -translationXDirection / 100
        default:
            break
        }
        setColorAlpha(with: action, alpha: alpha)
        setSizeAnimation(with: action, scale: alpha)
    }
}

// MARK: - Lazy init
extension CardViewControlBar {
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
        disableAllControls()
        sender.setIdentityAnimation(duration: 0.5) {
            self.enableAllControls()
        }
        delegate?.cardViewControlBar(self, slideAction: .rewind)
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

