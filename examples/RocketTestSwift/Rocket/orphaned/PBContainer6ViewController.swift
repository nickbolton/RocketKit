
import UIKit

class PBContainer6ViewController: _PBContainer6ViewController {
    override func didLoadRocketComponent() {
        super.didLoadRocketComponent()
        component?.isContentConstrainedBySafeArea = true
    }
}
