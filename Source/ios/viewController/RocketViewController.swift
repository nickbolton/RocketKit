
import UIKit

@IBDesignable open class RocketViewController: UIViewController {
    
    var componentId: String?
    public var componentView: ComponentView?
    public var component: RocketComponent? { return componentView?.component }
    
    @IBInspectable public var isContentConstrainedBySafeArea: Bool = false {
        didSet {
            component?.isContentConstrainedBySafeArea = isContentConstrainedBySafeArea
        }
    }
    
    public convenience init(componentId: String) {
        self.init()
        self.componentId = componentId
    }
    
    override open func loadView() {
        var v: UIView?
        if  let componentId = componentId {
            componentView = LayoutProvider.shared.buildView(withIdentifier: componentId)
            componentView?.component?.isContentConstrainedBySafeArea = isContentConstrainedBySafeArea
            componentView?.isRootView = true
            componentView?.layoutProvider = LayoutProvider.shared
            v = componentView?.view
        }
        view = v ?? UIView()
    }
}
