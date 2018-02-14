
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
            let rocketView = LayoutProvider.shared.buildView(withIdentifier: componentId)
            rocketView?.isRootView = true
            rocketView?.layoutProvider = LayoutProvider.shared
            v = rocketView?.view
        }
        if v == nil {
            v = NSView()
        }
        view = v!
    }
}
