
import Cocoa

public class RocketViewController: NSViewController {
    
    var componentId: String?
    
    public convenience init(componentId: String) {
        self.init()
        self.componentId = componentId
    }
    
    override public func loadView() {
        var v: NSView?
        if  let componentId = componentId {
            var rocketView = RocketLayoutProvider.shared.buildView(withIdentifier: componentId)
            rocketView?.isRootView = true
            rocketView?.layoutProvider = RocketLayoutProvider.shared
            v = rocketView?.view
        }
        if v == nil {
            v = NSView()
        }
        view = v!
    }
}
