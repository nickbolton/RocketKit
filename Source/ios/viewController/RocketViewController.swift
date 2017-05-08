
import UIKit

public class RocketViewController: UIViewController {
    
    var componentId: String?
    
    public convenience init(componentId: String) {
        self.init()
        self.componentId = componentId
    }
    
    override public func loadView() {
        var v: UIView?
        if  let componentId = componentId {
            let rocketView = RocketLayoutProvider.shared.buildView(withIdentifier: componentId)
            rocketView?.isRootView = true
            rocketView?.layoutProvider = RocketLayoutProvider.shared
            v = rocketView?.view
        }
        if v == nil {
            v = UIView()
        }
        view = v
    }
}
