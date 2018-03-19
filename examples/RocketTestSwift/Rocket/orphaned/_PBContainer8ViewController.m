#import "_PBContainer8ViewController.h"
#import <RocketKit/RocketKit-Swift.h>

@interface _PBContainer8ViewController()

@property (nonatomic, strong) id<ComponentView> componentView;

@end

@implementation _PBContainer8ViewController

- (void)loadView {
    self.componentView = [LayoutProvider.shared buildViewWithIdentifier:@"5BA80577-5D38-4B37-89C4-5B4DD327F2C7"];
    [self didLoadRocketComponent];
    self.componentView.isRootView = YES;
    self.componentView.layoutProvider = LayoutProvider.shared;
    self.view = self.componentView.view;
}

- (void)didLoadRocketComponent {
}

- (RocketComponent *)component {
    return self.componentView.component;
}

@end
