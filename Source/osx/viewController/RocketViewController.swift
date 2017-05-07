
import Cocoa

public class RocketViewController: NSViewController {
    
    var componentId = ""
    
    public convenience init(componentId: String) {
        self.init()
        self.componentId = componentId
    }
    
    override public func loadView() {
        let rocketView = RocketLayoutProvider.shared.buildView(withIdentifier: componentId)
        rocketView?.isRootView = true
        rocketView?.layoutProvider = RocketLayoutProvider.shared
        if let v = rocketView?.view {
            view = v
        } else {
            view = NSView()
        }
    }
}
