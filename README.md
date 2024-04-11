# RHStackCard


![截圖 2024-04-11 晚上9 57 52](https://github.com/HsinChungHan/RHStackCard/assets/38360195/812a03a0-3d45-4432-be86-6613c0e0d8cc)
RHStackCard is a highly customizable card stack view library built for iOS applications. It supports displaying various types of card views and can precisely monitor user swipe actions.
<table>
  <tr>
    <td>
      <img src="https://github.com/HsinChungHan/RHStackCard/assets/38360195/fc5841bc-c1c8-405b-989b-f22b0f768886" alt="RHDeskCardDemoApp-On IPhone-較短版-1">
    </td>
    <td>
      <img src="https://github.com/HsinChungHan/RHStackCard/assets/38360195/9d2adde6-3efa-4995-967d-000c8cc8164f" alt="RHDeskCardDemoApp-On IPhone-較短版 - 2">
    </td>
  </tr>
</table>





## Features

1. **Highly Customizable CardView and CardModel** - Easily create card views and data models that meet your requirements.
2. **Diverse Card Views Presentation** - Supports various types of CardViews, fulfilling different interface display needs.
3. **Swipe Behavior Monitoring** - Accurately captures users' swipe actions, including movement distance (translation), status, and direction.
   1. Translation: The actual movement distance of the card, a CGPoint type (you can use this value to link to the behavior you define).
   2. Status: Includes five statuses: sliding, endSlide, willDoSwipeAction, willDoBackToIdentity, didDoSwipeAction.
   3. Direction: The direction the card will fly towards after endSlide, including toLeft, toRight, toTop, backToIdentity, none.
4. **Task Management** - Converts each click on the control button into a task and sequentially executes them in the task manager.
5. **Interactive Animation** - When swiping cards, it interacts with nope label, like label, super like label animations and control button animations on the Control Bar.
6. **Card Fly-out Animation** - When swiped to a certain distance, the card will perform a fly-out-of-screen animation.
7. **Supports Local and Remote Images** - Allows inputting local images or image URLs as the picture displayed on the CardView.
8. **Flip and Vibration Feedback** - Performs a slight flip animation and vibration feedback when clicking on the furthest left or right pictures.
9. **Index Bar** - Users can know which picture they are currently viewing through the Index Bar on the CardView.

## How To Use

### Basic Setup

1. **Creating `CardDeskViewController`**:
    - Created through the `CardViewComponentsFactory` of `RHStackCard`.
    - Initialization requires a `dataSource` (to receive the imageURL's domain and cards model) and a `superViewController` (to handle presenting/pushing new ViewControllers).

### Customizing CardView and Card

2. **Customize CardView and Card**:
    - Use the default `BasicCardView` and `BasicCard`, or customize your own CardView and Card.
    - Ensure your customized `CustomCardView` conforms to the `CardView` protocol, and your customized `CustomCard` conforms to the `Card` protocol.
    - Use the `registerCardViewType` method to bind a CustomCardViewID to your `CustomCardView`.

### Data Source Setup

3. **Implementing `CardDeskViewControllerDataSource`**:
    - Enter your image URL Domain (currently does not support multiple different URL Domains).
    - Input your newly created Cards model.

### Monitoring Swipe Actions

4. **Monitoring Swipe Actions**:
    - Create a `SlidingEventObserver` through the `componentFactory`.
    - Add this observer to the `ObservableSlidingAnimation`.
    - Define the behavior upon receiving sliding event notifications.

## Sample Code
```swift
import RHUIComponent
import RHStackCard
import UIKit

class YourViewController: UIViewController {
    let componentFactory = CardViewComponentsFactory()
    lazy var cardDeskViewController = componentFactory.makeCardDeskViewController(with: self, in: self)
    lazy var cardDeskView = cardDeskViewController.view!
    lazy var slidingEventObserver: SlidingEventObserver? = componentFactory.makeSlidingEventObserver()
    
    let CUSTOM_CARD_VIEW_ID = "CustomCardViewID"
    override func viewDidLoad() {
        super.viewDidLoad()
        // setup layout with cardDeskView...
        registerCardView()
        addObserver(with: slidingEventObserver)
        bindEvent()
    }
    
    //
    func registerCardView() {
        cardDeskViewController.registerCardViewType(withCardViewID: CUSTOM_CARD_VIEW_ID, cardViewType: CustomCardView.self)
    }
}

// MARK: - Helpers
extension YourViewController {
    func addObserver(with slidingEventObserver: SlidingEventObserver?) {
        guard let slidingEventObserver else { return }
        ObservableSlidingAnimation.shared.addObserver(slidingEventObserver)
    }
    
    func bindEvent() {
        slidingEventObserver?.didUpdateValue = { slidingEvent in
            // Do something you want to do after receiving event...
        }
    }
}

// MARK: - Factory Methods
extension YourViewController {
    // Define the basic cards model
    private func makeBasicCards() -> [BasicCard] {
        let imageUrls = [
            "https://img.onl/secZNX", "https://img.onl/ZH5sWF", "https://img.onl/svq3BT",
            "https://img.onl/iZFN8N", "https://img.onl/0wemvT", "https://img.onl/7XELcY",
            "https://img.onl/CPKg1e", "https://img.onl/1KYoX8", "https://img.onl/qR1lFr",
            "https://img.onl/4DuU5A", "https://img.onl/buCSyk", "https://img.onl/YtXgXr",
        ]
        
        var cards: [BasicCard] = []
        for i in stride(from: 0, to: imageUrls.count, by: 4) {
            let cardURLs = imageUrls[i ..< min(i + 3, imageUrls.count)].compactMap { URL(string: $0) }
            let card = BasicCard(uid: "\(i / 3)", imageURLs: cardURLs)
            cards.append(card)
        }
        return cards
    }
    
    // Define the custom cards model
    private func makeCustomCards() -> [CustomCard] {
        var cards: [CustomCard] = []
        let totalImages = 191 // There are total 191 images

        for start in stride(from: 2, through: totalImages, by: 5) {
            let end = min(start + 4, totalImages)
            let imageNames = (start...end).map { "AD\($0)" }
            let cardName = "Vogue"
            
            // Set first imageName of each group be CustomCardView's uid
            let uid = "AD\(start)"
            
            let card = CustomCard(uid: uid, imageNames: imageNames, cardViewTypeName: CUSTOM_CARD_VIEW_ID, cardName: cardName)
            cards.append(card)
        }
        return cards
    }
}

// MARK: - CardDeskViewControllerDataSource
extension YourViewController: CardDeskViewControllerDataSource {
    var domainURL: URL? { .init(string: "https://img.onl/") }
    
    var cards: [Card] {
        // You can show multiple different cards together
        makeCustomCards() + makeBasicCards()
    }
}
```

## UML Diagram
![截圖 2024-04-11 下午4 41 23](https://github.com/HsinChungHan/RHStackCard/assets/38360195/72dd74f2-8bc1-4d0a-bacb-e342fe10381f)
You can click [here][1] to refer to the evolution of the overall architecture 🙌 🙌 🙌


Please refer to the above steps for the basic setup and customize and extend according to your specific needs.

Wishing you a smooth development process with RHStackCard!

[1]: https://drive.google.com/file/d/1BRiJ8oPmWHbx3fGlvOD6m_AFSIulCiNq/view?usp=sharing "UML draw.io"
