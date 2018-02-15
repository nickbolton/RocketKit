
import Cocoa

public class RocketViewController: NSViewController {
    
    var componentId: String?
    public var componentView: ComponentView?
    public var component: RocketComponent? { return componentView?.component }

    public convenience init(componentId: String) {
        self.init()
        self.componentId = componentId
    }
    
    override public func loadView() {
        var v: NSView?
        if  let componentId = componentId {
            componentView = LayoutProvider.shared.buildView(withIdentifier: componentId)
            componentView?.isRootView = true
            componentView?.layoutProvider = LayoutProvider.shared
            v = componentView?.view
        }
        view = v ?? NSView()
    }
}
