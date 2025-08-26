<div align="center">
    <img src="https://github.com/HsinChungHan/RHStackCard/assets/38360195/812a03a0-3d45-4432-be86-6613c0e0d8cc" alt="截圖 2024-04-11 晚上9 57 52">
</div>

# RHStackCard
RHStackCard is a powerful and highly customizable iOS card stack component built with Clean Architecture + MVVM pattern. Inspired by popular dating apps, RHStackCard provides smooth animations, memory optimization strategies, and extensive customization options.

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





## ✨ Features

### 🏗️ Architecture Design
- **Clean Architecture + MVVM**: Completely platform-agnostic Domain and Data layers
- **Protocol-oriented design**: Easy to test and extend
- **Dependency injection**: Low-coupled component design
- **Swift Package Manager**: Fully encapsulated, use only through `RHStackCardInterface`

### 🎨 Highly Customizable
- **Custom Card Models**: Create your card data by conforming to `Card` protocol
- **Custom Card Views**: Build custom UI components by inheriting from `CardView`
- **Flexible Interface**: Simplified usage through `RHStackCardInterface`

### 🚀 Memory Optimization
- **CardViewPool Mechanism**: Similar to UITableViewCell recycling mechanism
- **Maximum 3 Cards**: Maximum of 3 cards displayed simultaneously on screen
- **Smart Recycling**: Pre-generate 3 CardViews for each Card Type for reuse
- **Efficient Management**: Ensures memory usage efficiency and management

### ⚡ Task Management System
- **ActionTaskManager**: Prevents missed operations during rapid tapping
- **Task Queue**: Queues user taps for sequential execution
- **Animation Synchronization**: Executes next task after card animation completes
- **No-miss Guarantee**: Ensures every user operation gets executed

### 🎯 Rich Interactive Effects
- **Sliding Gradient Effects**: Dynamic visual feedback for Like, Nope, SuperLike
- **Haptic Feedback**: Vibration effects when tapping photos
- **Index Indicator**: Real-time display of current photo page
- **Flip Animation**: Card flip effect when reaching the last photo
- **Scale Effects**: Dynamic scaling of background cards when swiping the first card

### 🖼️ Image Caching System
- **Auto Caching**: Intelligent image caching mechanism
- **Cache First**: Priority check for local cache
- **Network Fallback**: Auto download from server when no cache
- **Auto Save**: Automatically save to local cache after download
- **Custom Network Layer**: Self-developed network and cache frameworks integrated via SPM

## How To Use

### Basic Setup

1. **Creating `CardDeskViewController`**:
    - Created through the `RHStackCardInterface` of `RHStackCard`.
    - Initialization requires a `dataSource` (to receive the imageURL's domain and cards model).

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
import SnapKit
import UIKit

class UserPageViewController: UIViewController {
    private var cardDeskView: UIView { viewModel.cardDeskView }
    private lazy var viewModel = makeUserPageViewMdoel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDeskCardView()
        viewModel.viewDidLoad()
    }
}

// MARK: - Private helpers
extension UserPageViewController {
    func makeUserPageViewMdoel() -> UserPageViewModel {
        let repo = UserRepository()
        let usecase = UserUsecase(repo: repo)
        let viewModel = UserPageViewModel(usecase: usecase)
        viewModel.delegate = self
        return viewModel
    }
    
    func setupDeskCardView() {
        let cardDeskViewController = viewModel.setupDeskCardView()
        addChild(cardDeskViewController)
        view.addSubview(cardDeskViewController.view)
        
        let cardWidth = UIScreen.main.bounds.width - 96
        cardDeskViewController.view.constraint(
            centerX: view.snp.centerX,
            centerY: view.snp.centerY,
            padding: .init(top: 32, left: 0, bottom: 0, right: 0),
            size: .init(width: cardWidth, height: cardWidth * 16 / 9)
        )
        cardDeskViewController.didMove(toParent: self)
    }
}

extension UserPageViewController: UserPageViewModelDelegate {
    func userVM(_ vm: UserPageViewModel, didChangeState state: UserPageState) {
        // Toggle the loading indicator based on state
    }
    
    func userVM(_ vm: UserPageViewModel, didUpdateCards cards: [UserCard]) {
        vm.addUserCards()
    }
}
```

## UML Diagram
🚨🚨🚨 Needs to be updated based on the existing architecture 🚨🚨🚨
![截圖 2024-04-11 下午4 41 23](https://github.com/HsinChungHan/RHStackCard/assets/38360195/72dd74f2-8bc1-4d0a-bacb-e342fe10381f)
You can click [here][1] to refer to the evolution of the overall architecture 🙌 🙌 🙌

## Demo App
You can click [here][2] to refer to the Demo App 🙌 🙌 🙌

Please refer to the above steps for the basic setup and customize and extend according to your specific needs.

Wishing you a smooth development process with RHStackCard 🥳 🥳 🥳

[1]: https://drive.google.com/file/d/1BRiJ8oPmWHbx3fGlvOD6m_AFSIulCiNq/view?usp=sharing "UML draw.io"
[2]: https://github.com/HsinChungHan/RHCardStackDemoApp.git "RHStackCardDemoApp"
