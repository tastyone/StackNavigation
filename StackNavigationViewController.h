//
//  StackNavigationViewController.h
//  StackNavigation
//
//  Created by Sangwon Park on 6/12/13.
//

#import <UIKit/UIKit.h>

@interface StackNavigationViewController : UIViewController

@property (readonly) UIViewController* topViewController;

- (id)initWithRootViewController:(UIViewController*)viewController;

- (BOOL)isRootViewController:(UIViewController*)viewController;

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (UIViewController *)popViewControllerAnimated:(BOOL)animated;
- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated; // NOT yet Implement

@end
