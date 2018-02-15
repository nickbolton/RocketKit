#import "_PBContainer6ViewController.h"
#import <RocketKit/RocketKit-Swift.h>

@interface _PBContainer6ViewController()

@property (nonatomic, strong) id<ComponentView> componentView;

@end

@implementation _PBContainer6ViewController

- (void)loadView {
    self.componentView = [LayoutProvider.shared buildViewWithIdentifier:@"DB84DAEA-CA05-49F7-83AA-22A72869A6E5"];
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
