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

public final class CardViewControlBar: UIView {
    weak var delegate: CardViewControlBarDelegate?
    private let viewModel = CardViewControlBarViewModel()

    private lazy var controlButtons = makeControlButtons()
    private lazy var controlStackView = makeControlStackView()

    private var rewindButton: HightlightedButton { controlButtons[getButtonIndex(with: .rewind)] }
    private var nopeButton: HightlightedButton { controlButtons[getButtonIndex(with: .nope)] }
    private var superLikeButton: HightlightedButton { controlButtons[getButtonIndex(with: .superLike)] }
    private var likeButton: HightlightedButton { controlButtons[getButtonIndex(with: .like)] }
    private var refreshButton: HightlightedButton { controlButtons[getButtonIndex(with: .refresh)] }

    private let buttonsShouldHaveInitialColor: Bool

    init(buttonsShouldHaveInitialColor: Bool) {
        self.buttonsShouldHaveInitialColor = buttonsShouldHaveInitialColor
        super.init(frame: .zero)
        viewModel.delegate = self
        addTargetsForControlButtons()
        setupLayout()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - Internal APIs (driven by external calls or user gestures)
extension CardViewControlBar {
    func handle(slidingEvent: ObservableEvents.CardViewEvents.SlidingEvent) {
        viewModel.handle(slidingEvent: slidingEvent)
    }
    
    /*
     Centralize the control of whether interactions are allowed in the ViewModel—for example,
     temporarily lock the UI during animations,
     while sending network requests, to prevent double-taps, or when the card stack is empty.
     */
    func setControlsEnabled(_ enabled: Bool) {
        viewModel.controlsEnabled = enabled
    }
}

// MARK: - private helpers
private extension CardViewControlBar {
    func apply(state: CardViewControlBarViewModel.State) {
        for action in [CardViewAction.nope, .like, .superLike] {
            let btn = toButton(with: action)
            let a = state.alpha[action] ?? 0
            let s = state.scale[action] ?? 1

            btn.backgroundColor = action.color.withAlphaComponent(a)
            if s <= 1 {
                btn.transform = .identity
            } else {
                btn.transform = CGAffineTransform(scaleX: s, y: s)
            }
        }
    }

    func setupLayout() {
        addSubview(controlStackView)
        controlStackView.fillSuperView()
        controlStackView.arrangedSubviews.forEach {
            $0.constrainWidth(40).constrainHeight(40)
            $0.layer.cornerRadius = 20
            $0.clipsToBounds = true
        }
    }

    func toButton(with action: CardViewAction) -> UIButton {
        switch action {
        case .like:      return likeButton
        case .nope:      return nopeButton
        case .superLike: return superLikeButton
        case .refresh:   return refreshButton
        case .rewind:    return rewindButton
        }
    }

    func makeControlButtons() -> [HightlightedButton] {
        let buttons = CardViewAction.allCases.map { slideAction -> HightlightedButton in
            let initialAlpha = (self.buttonsShouldHaveInitialColor == true) ? 1.0 : 0.0
            let button = HightlightedButton(
                normalColor: slideAction.color.withAlphaComponent(initialAlpha),
                hightlightedColor: slideAction.color.withAlphaComponent(1.0)
            )
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

    func getButtonIndex(with action: CardViewAction) -> Int {
        switch action {
        case .rewind:  return 0
        case .nope:    return 1
        case .superLike: return 2
        case .like:    return 3
        case .refresh: return 4
        }
    }
}

// MARK: - CardViewControlBarViewModelDelegate
extension CardViewControlBar: CardViewControlBarViewModelDelegate {
    func controlBarVM(_ vm: CardViewControlBarViewModel, didUpdate state: CardViewControlBarViewModel.State) {
        apply(state: state)
    }

    func controlBarVM(_ vm: CardViewControlBarViewModel, didSetControlsEnabled enabled: Bool) {
        controlButtons.forEach { $0.isEnabled = enabled }
    }
}
