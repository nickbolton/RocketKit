#import "PBContainer6ViewController.h"
#import <RocketKit/RocketKit-Swift.h>

@interface PBContainer6ViewController ()

// Private interface goes here.

@end

@implementation PBContainer6ViewController

- (void)didLoadRocketComponent {
    [super didLoadRocketComponent];
    self.component.isContentConstrainedBySafeArea = YES;
}

@end
