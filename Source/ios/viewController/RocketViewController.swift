
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
            var rocketView = LayoutProvider.shared.buildView(withIdentifier: componentId)
            rocketView?.isRootView = true
            rocketView?.layoutProvider = LayoutProvider.shared
            v = rocketView?.view
        }
        if v == nil {
            v = UIView()
        }
        view = v!
    }
}
