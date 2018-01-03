#import "_PBContainer106ViewController.h"
#import <RocketKit/RocketKit-Swift.h>

@implementation _PBContainer106ViewController

- (void)loadView {
    id<RocketViewProtocol> rocketView = [LayoutProvider.shared buildViewWithIdentifier:@"78595176-65AE-466F-B747-B17724C1AA17"];
    rocketView.isRootView = YES;
    rocketView.layoutProvider = LayoutProvider.shared;
    self.view = rocketView.view;
}

@end
