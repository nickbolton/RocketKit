#import "_PBContainer15ViewController.h"
#import <RocketKit/RocketKit-Swift.h>

@interface _PBContainer15ViewController()

@property (nonatomic, strong) id<ComponentView> componentView;

@end

@implementation _PBContainer15ViewController

- (void)loadView {
    self.componentView = [LayoutProvider.shared buildViewWithIdentifier:@"4EB71825-C7B1-45AD-8ACA-067F7EE7F55F"];
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
