//
//  CardView.swift
//  SlidingCard
//
//  Created by Chung Han Hsin on 2024/3/22.
//

import RHInterface
import RHUIComponent
import UIKit

enum CardViewType {
    case basicImageViewCard
    var viewType: CardView.Type {
        switch self {
        case .basicImageViewCard:
            return CardView.self
        }
    }
}

public protocol CardViewDelegate: AnyObject {
    func cardView(_ cardView: CardView, didRemoveCardViewFromSuperView: Bool)
    func cardView(_ cardView: CardView, didTapOutOfIndex direction: CardViewViewModel.OutOfIndexDirection)
}

open class CardView: UIView {
    weak var delegate: CardViewDelegate?
    
    private lazy var slidingAnimationController = SlidingAnimationController(dataSource: self, delegate: self)
    private lazy var panGestureRecognizer = makePanGestureRecognizer()
        
    
    
    var card: Card? { viewModel.card }
    
    public let uid: String
    public let viewModel = CardViewViewModel()
    public init(uid: String) {
        self.uid = uid
        super.init(frame: .zero)
        backgroundColor = .black
        viewModel.delegate = self
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
    
    let uidLabel = UILabel()
    
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        setupLayout()
        addGestureRecognizer(panGestureRecognizer)
    }
    
    override public var description: String {
        return "\(super.description) \nuid: \(uid)"
    }
    
    open func setupLayout() {
        setupViewLayout()
    }
}

// MARK: - Layouts
private extension CardView {
    func setupViewLayout() {
        clipsToBounds = true
        layer.cornerRadius = 20.0
        
        addSubview(imageView)
        imageView.fillSuperView()
        layer.addSublayer(gradientLayer)
        gradientLayer.frame = bounds
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
        
        // TODO: - Remove in the future
        addSubview(uidLabel)
        uidLabel.constraint(centerX: snp.centerX, centerY: snp.centerY, size: .init(width: 100, height: 200))
        uidLabel.text = uid
        uidLabel.textColor = .white
        uidLabel.font = .boldSystemFont(ofSize: 33)
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
        return view
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
        layer.colors = [Color.Neutral.v100, Color.Blue.v50]
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
    
    func makePanGestureRecognizer() -> UIPanGestureRecognizer {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        return panGesture
    }
    
    @objc func handlePan(gesture: UIPanGestureRecognizer){
        slidingAnimationController.handlePan(gesture: gesture)
    }
}

// MARK: - Intenal methods
extension CardView {
    typealias CardViewDirection = SlidingDirection
    func swipe(to direction: CardViewDirection) {
        switch direction {
        case .toLeft:
            leftLabel.alpha = 1.0
        case .toRight:
            rightLabel.alpha = 1.0
        case .toTop:
            topLabel.alpha = 1.0
        case .backToIdentity:
            topLabel.alpha = 0.0
            leftLabel.alpha = 0.0
            rightLabel.alpha = 0.0
        }
        slidingAnimationController.performCardViewActionAnimation(with: direction)
    }
    
    func setCurrentPhotoIndex(shouldAdvanceNextPhoto: Bool) {
        viewModel.setCurrentPhotoIndex(shouldAdvanceNextPhoto: shouldAdvanceNextPhoto)
    }
    
    func setupImageNamesCard(with card: Card) {
        viewModel.setupImageNamesCard(with: card)
    }
    
    func reset() {
        viewModel.reset()
    }
    
    func setupImageURLsCard(with card: Card) {
        viewModel.setupImageURLsCard(with: card)
    }
    
    func updateCardImage(with imageData: Data, at index: Int) {
        viewModel.updateImage(with: imageData, at: index)
    }
}

// MARK: - SlidingAnimationControllerDataSource
extension CardView: SlidingAnimationControllerDataSource {
    var cardView: CardView { self }
}

// MARK: - SlidingAnimationControllerDelegate
extension CardView: SlidingAnimationControllerDelegate {
    func slidingAnimationController(_ SlidingAnimationController: SlidingAnimationController, didSlideChanged direction: SlidingDirection, withTransaltion translation: CGPoint) {
        viewModel.didSlideCahnged(with: direction, withTransaltion: translation)
    }
        
    func slidingAnimationController(_ SlidingAnimationController: SlidingAnimationController, willPerformCardViewAction direction: SlidingDirection) {
        switch direction {
        case .backToIdentity:
            [rightLabel, leftLabel, topLabel].forEach {
                $0.alpha = 0.0
            }
        default: break
        }
    }
    
    func slidingAnimationController(_ SlidingAnimationController: SlidingAnimationController, didFinishSwipeAwayAnimation: Bool) {
        if !didFinishSwipeAwayAnimation { return }
        delegate?.cardView(self, didRemoveCardViewFromSuperView: true)
    }
}

// MARK: - CardViewViewModelDelegate
extension CardView: CardViewViewModelDelegate {
    public func cardViewViewModel(_ cardViewViewModel: CardViewViewModel, didResetCardView: Bool) {
        guard didResetCardView else { return }
        indexBarStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
    
    public func cardViewViewModel(_ cardViewViewModel: CardViewViewModel, didSlideDirection direction: SlidingDirection, withLabelAlpha alpha: CGFloat) {
        switch direction {
        case .toTop:
            topLabel.alpha = alpha
            rightLabel.alpha = 0.0
            leftLabel.alpha = 0.0
            
        case .toRight:
            topLabel.alpha = 0.0
            rightLabel.alpha = alpha
            leftLabel.alpha = 0.0
            
        case .toLeft:
            topLabel.alpha = 0.0
            rightLabel.alpha = 0.0
            leftLabel.alpha = alpha
            
        case .backToIdentity:
            topLabel.alpha = 0.0
            rightLabel.alpha = 0.0
            leftLabel.alpha = 0.0
        }
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
