//
//  CardView.swift
//  SlidingCard
//
//  Created by Chung Han Hsin on 2024/3/22.
//

import RHUIComponent
import UIKit

public protocol CardViewDelegate: AnyObject {    
    func cardView(_ cardView: CardView, didTapOutOfIndex direction: CardViewViewModel.OutOfIndexDirection)
}

open class CardView: UIView {
    weak var delegate: CardViewDelegate?
        
    public var card: (any Card)? { viewModel.card }
    
    public let uid: String
    public let viewModel = CardViewViewModel()

    public required init(uid: String) {
        self.uid = uid
        super.init(frame: .zero)
        backgroundColor = .white
        viewModel.delegate = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handlePhotoTap(_:)))
        addGestureRecognizer(tap)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate lazy var imageView = makePhotoImageView()
    fileprivate lazy var informationLabel = makeInformationLabel()
    fileprivate lazy var gradientLayer = makeGradientLayer()
    fileprivate lazy var indexBarStackView = makeIndexBarStackView()
    
    fileprivate lazy var rightLabel = makeBehaviorLabel(text: CardViewAction.like.title, color: CardViewAction.like.color)
    fileprivate lazy var topLabel = makeBehaviorLabel(text: CardViewAction.superLike.title, color: CardViewAction.superLike.color)
    fileprivate lazy var leftLabel = makeBehaviorLabel(text: CardViewAction.nope.title, color: CardViewAction.nope.color)
    
    public lazy var uidLabel = makeUIDLabel()
    
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        setupLayout()
    }
    
    override public var description: String {
        return "\(super.description) \nuid: \(uid)"
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = imageView.bounds
    }
    
    open func setupLayout() {
        setupViewLayout()
    }
}

// MARK: - Intenal APIs
extension CardView {
    typealias CardViewDirection = SlidingDirection
    func swipe(to direction: CardViewDirection) {
        viewModel.didSwipeAway(direction: direction)
    }
    
    func setCurrentPhotoIndex(shouldAdvanceNextPhoto: Bool) {
        viewModel.setCurrentPhotoIndex(shouldAdvanceNextPhoto: shouldAdvanceNextPhoto)
    }
    
    func setupImageNamesCard<T: Card>(with card: T) {
        viewModel.setupImageNamesCard(with: card)
    }
    
    func reset() {
        viewModel.reset()
    }
    
    func setupImageURLsCard<T: Card>(with card: T) {
        viewModel.setupImageURLsCard(with: card)
    }
    
    func updateCardImage(with imageData: Data, at index: Int) {
        viewModel.updateImage(with: imageData, at: index)
    }
    
    func setActionLabelsToBeTransparent() {
        leftLabel.alpha = 0.0
        rightLabel.alpha = 0.0
        topLabel.alpha = 0.0
    }
}

// MARK: - CardViewViewModelDelegate
extension CardView: CardViewViewModelDelegate {
    public func cardViewViewModel(_ cardViewViewModel: CardViewViewModel, didResetCardView: Bool) {
        guard didResetCardView else { return }
        indexBarStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
    
    public func cardViewViewModel(_ vm: CardViewViewModel, didUpdateActionHint state: CardViewViewModel.ActionHintState) {
        leftLabel.alpha  = state.leftAlpha
        rightLabel.alpha = state.rightAlpha
        topLabel.alpha   = state.topAlpha
    }
    
    public func cardViewViewModel(_ cardViewViewModel: CardViewViewModel, didInitImages images: [UIImage]) {
        initIndexBar(with: images.count)
    }
    
    public func cardViewViewModel(_ cardViewViewModel: CardViewViewModel, didTapOutOfIndex direction: CardViewViewModel.OutOfIndexDirection) {
        delegate?.cardView(self, didTapOutOfIndex: direction)
    }
    
    public func cardViewViewModel(_ cardViewViewModel: CardViewViewModel, didUpdateCurrentImage image: UIImage, withCurrentImageIndex index: Int) {
        imageView.image = image
        updateIndexBar(with: index)
    }
}

// MARK: - Layouts
private extension CardView {
    func setupViewLayout() {
        backgroundColor = .white
        clipsToBounds = true
        layer.cornerRadius = 20.0
        
        addSubview(imageView)
        imageView.fillSuperView()
        [rightLabel, topLabel, leftLabel, indexBarStackView].forEach {
            addSubview($0)
        }
        rightLabel.constraint(top: snp.top, bottom: nil, leading: snp.leading, trailing: nil, padding: .init(top: 24, left: 24, bottom: 0, right: 0))
        leftLabel.constraint(top: snp.top, bottom: nil, leading: nil, trailing: snp.trailing, padding: .init(top: 24, left: 0, bottom: 0, right: 24))

        topLabel.constraint(bottom: snp.bottom, centerX: snp.centerX, padding: .init(top: 0, left: 0, bottom: 80, right: 0))
        leftLabel.rotate(degrees: 20)
        rightLabel.rotate(degrees: -20)
        topLabel.rotate(degrees: -20)
        indexBarStackView.constraint(top: snp.top, bottom: nil, leading: snp.leading, trailing: snp.trailing, padding: .init(top: 8, left: 16, bottom: 0, right: 16), size: .init(width: 0, height: 4))
        
        addSubview(uidLabel)
        uidLabel.constraint(centerX: snp.centerX, centerY: snp.centerY, size: .init(width: 100, height: 200))
    }
    
    func initIndexBar(with counts: Int) {
        indexBarStackView.arrangedSubviews.forEach {
            indexBarStackView.removeArrangedSubview($0)
        }
        for index in 0 ..< counts {
            let view = UIView()
            view.backgroundColor = (index == viewModel.currentImageIndex) ? Constant.Bar.selectedColor : Constant.Bar.unselectedColor
            indexBarStackView.addArrangedSubview(view)
        }
    }
    
    func updateIndexBar(with currentIndex: Int) {
        indexBarStackView.arrangedSubviews.forEach { $0.backgroundColor = Constant.Bar.unselectedColor }
        indexBarStackView.arrangedSubviews[currentIndex].backgroundColor = Constant.Bar.selectedColor
    }
}

// MARK: - Factory Methods
fileprivate extension CardView {
    enum Constant {
        enum Bar {
            static let selectedColor = Color.Neutral.v0
            static let unselectedColor = Color.Neutral.v600
        }
    }
    
    func makePhotoImageView() -> UIImageView {
        let view = UIImageView()
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        view.layer.addSublayer(gradientLayer)
        return view
    }
    
    func makeUIDLabel() -> UILabel {
        let label = UILabel()
        label.text = uid
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 33)
        return label
    }
    
    func makeInformationLabel() -> UILabel {
        let view = UILabel()
        view.textColor = Color.Neutral.v0
        view.font = UIFont.systemFont(ofSize: 28, weight: .semibold)
        view.lineBreakMode = .byWordWrapping
        view.numberOfLines = 3
        return view
    }
    
    func makeGradientLayer() -> CAGradientLayer {
        let layer = CAGradientLayer()
        layer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        layer.locations = [0.5, 1.0]
        return layer
    }
    
    func visualEffectView() -> UIVisualEffectView {
        let blurEffect = UIBlurEffect.init(style: .regular)
        let visualEffectView = UIVisualEffectView.init(effect: blurEffect)
        return visualEffectView
    }
    
    func makeIndexBarStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 4.0
        stackView.distribution = .fillEqually
        return stackView
    }
    
    func makeInsetLabel(text: String, textInsets: UIEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 0) , textAlignment: NSTextAlignment = .center, textColor: UIColor = .black, font: UIFont = .systemFont(ofSize: 20), numberOfLines: Int = 1) -> InsetLabel{
        let label = InsetLabel(textInsets: textInsets)
        label.text = text
        label.textAlignment = textAlignment
        label.textColor = textColor
        label.font = font
        label.numberOfLines = numberOfLines
        return label
    }
    
    func makeBehaviorLabel(text: String, color: UIColor) -> UILabel {
        let view = makeInsetLabel(text: text, textInsets: .init(top: 6, left: 6, bottom: 6, right: 6), textColor: color, font: .systemFont(ofSize: 60, weight: .bold), numberOfLines: 0)
        view.layer.cornerRadius = 5.0
        view.layer.borderWidth = 5.0
        view.layer.borderColor = color.cgColor
        view.clipsToBounds = true
        view.alpha = 0.0
        return view
    }
    
    @objc private func handlePhotoTap(_ gesture: UITapGestureRecognizer) {
        let x = gesture.location(in: self).x
        let shouldAdvanceNextPhoto = x > bounds.midX
        setCurrentPhotoIndex(shouldAdvanceNextPhoto: shouldAdvanceNextPhoto)
    }
}
