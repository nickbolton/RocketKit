//
//  ViewController.m
//  RocketTestObjc
//
//  Created by Nick Bolton on 5/7/17.
//  Copyright © 2017 Pixelbleed LLC. All rights reserved.
//

#import "ViewController.h"
#import <RocketKit/RocketKit-Swift.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    RocketComponent *component = [[LayoutProvider shared] componentByIdentifier:@"9AF4A96E-8872-4C81-B2F9-5522214FD9D7"];
    if (component != nil) {
        component.textDescriptor.text = @"What in the world is happening here??";
        
        NSTimeInterval delayInSeconds = 3.0f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            component.textDescriptor.textAttributes.textAlignment = .center
            component.textDescriptor.text = "Weeee\nYo!"
            
            if var view = LayoutProvider.shared.view(with: component.identifier) {
                view.component = component
                view.updateText(animationDuration: 0.0)
            }
        });
    }
}

@end
