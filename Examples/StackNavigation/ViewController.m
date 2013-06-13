//
//  ViewController.m
//  StackNavigation
//
//  Created by Sangwon Park on 6/12/13.
//  Copyright (c) 2013 bootstlab.com. All rights reserved.
//

#import "ViewController.h"
#import "StackNavigationViewController.h"

#define USE_ANIMATION YES

@interface ViewController ()

@property (strong) IBOutlet UILabel* label;
@property (strong) IBOutlet UIButton* backButton;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.label.text = self.description;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    BOOL isRoot = [(StackNavigationViewController*)self.parentViewController isRootViewController:self];
    self.backButton.hidden = isRoot;
    
//    if ( isRoot ) {
//        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
//        [self.parentViewController setWantsFullScreenLayout:NO];
//    } else {
//        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
//        [self.parentViewController setWantsFullScreenLayout:YES];
//        CGRect frame = self.parentViewController.view.frame;
//        frame.origin.y = 0.f;
//        self.parentViewController.view.frame = frame;
//    }
    
    NSLog(@"viewWillAppear: %@", self);
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    NSLog(@"viewWillDisappear: %@", self);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Orientations

// New Autorotation support.
- (BOOL)shouldAutorotate NS_AVAILABLE_IOS(6_0);
{
    return YES;
}
- (NSUInteger)supportedInterfaceOrientations NS_AVAILABLE_IOS(6_0);
{
    return UIInterfaceOrientationMaskAll;
}
// Returns interface orientation masks.
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation NS_AVAILABLE_IOS(6_0);
{
    return UIInterfaceOrientationPortrait;
}


#pragma mark - Event handlers

- (IBAction)goButtonTouched:(id)sender
{
    NSLog(@"goButtonTouched: %@ of %@", sender, self);
    
    static NSArray* colors = nil;
    if ( colors == nil ) {
        colors = [NSArray arrayWithObjects:[UIColor whiteColor], [UIColor lightGrayColor], [UIColor yellowColor], [UIColor magentaColor], [UIColor greenColor], nil];
    }
    
    ViewController* detailViewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    UIColor* selectedColor = [colors objectAtIndex:([self.parentViewController.childViewControllers count]%colors.count)];
    detailViewController.view.backgroundColor = selectedColor;
    [(StackNavigationViewController*)self.parentViewController pushViewController:detailViewController animated:USE_ANIMATION];
}

- (IBAction)backButtonTouched:(id)sender
{
    NSLog(@"backButtonTouched: %@", self);
    
    [(StackNavigationViewController*)self.parentViewController popViewControllerAnimated:USE_ANIMATION];
}

- (IBAction)backToRootButtonTouched:(id)sender
{
    NSLog(@"backToRootButtonTouched: %@", self);
    
    [(StackNavigationViewController*)self.parentViewController popToRootViewControllerAnimated:NO]; //USE_ANIMATION];
}

@end
