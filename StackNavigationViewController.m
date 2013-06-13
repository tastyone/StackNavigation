//
//  StackNavigationViewController.m
//  StackNavigation
//
//  Created by Sangwon Park on 6/12/13.
//

#import "StackNavigationViewController.h"

@interface StackNavigationViewController () <UINavigationBarDelegate>
@property (strong) UIViewController* rootViewController;

@property (strong) IBOutlet UINavigationBar* navigationBar;
@property (strong) IBOutlet UIView* contentView;
@end

@implementation StackNavigationViewController

- (id)initWithRootViewController:(UIViewController*)viewController;
{
    self = [super init];
    if ( self ) {
        self.rootViewController = viewController;
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    CGFloat topToolbarHeight = 0.f;
    CGFloat bottomToolbarHeight = 0.f;
    
    // load navigationBar
    if ( topToolbarHeight > 0.f ) {
        self.navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0.f, 0.f, self.view.frame.size.width, topToolbarHeight)];
        self.navigationBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.navigationBar.delegate = self;
    } else {
        self.navigationBar = nil;
    }
    
    // load contentView
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0.f, topToolbarHeight, self.view.frame.size.width, self.view.frame.size.height-topToolbarHeight-bottomToolbarHeight)];
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    // add subviews
    [self.view addSubview:self.contentView];
    [self.view addSubview:self.navigationBar];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ( self.rootViewController ) {
        [self pushViewController:self.rootViewController animated:NO];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.topViewController beginAppearanceTransition:YES animated:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.topViewController endAppearanceTransition];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.topViewController beginAppearanceTransition:NO animated:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.topViewController endAppearanceTransition];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)backButtonItemTouched:(UIBarButtonItem*)backButton
{
    NSLog(@"backButtonItemTouched: %@", backButton);
}


- (BOOL)isRootViewController:(UIViewController*)viewController;
{
    return ([self.childViewControllers count] > 0 && [self.childViewControllers objectAtIndex:0] == viewController);
}


/*
 * oldChild will hide
 * newChild will show
 * if reversed is NO, newChild will scale up to Identity and oldChild will scale down
 * if reversed is YES, newChild will scale down to Identity and oldChild
 */
- (void)transiteFromChild:(UIViewController*)oldChild toChild:(UIViewController*)newChild animated:(BOOL)animated reversed:(BOOL)reversed completion:(void(^)(void))completion
{
    if ( !animated ) {
        oldChild.view.transform = CGAffineTransformIdentity;
        oldChild.view.hidden = YES;
        oldChild.view.alpha = 0.f;
        
        newChild.view.transform = CGAffineTransformIdentity;
        newChild.view.hidden = NO;
        newChild.view.alpha = 1.f;
        
        completion();
    } else {
        CGAffineTransform large = CGAffineTransformMakeScale(1.25f, 1.25f);
        CGAffineTransform small = CGAffineTransformMakeScale(0.75f, 0.75f);
        
        oldChild.view.hidden = NO;
        newChild.view.hidden = NO;
        
        oldChild.view.transform = CGAffineTransformIdentity;
        newChild.view.transform = reversed ? large : small;
        
        [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            oldChild.view.transform = reversed ? small : large;
            newChild.view.transform = CGAffineTransformIdentity;
            
            oldChild.view.alpha = 0.f;
            newChild.view.alpha = 1.f;
        } completion:^(BOOL finished) {
            if ( !finished ) {
                oldChild.view.hidden = YES;
            }
            
            completion();
        }];
    }
}

- (void)pushViewController:(UIViewController *)newChild animated:(BOOL)animated;
{
    NSLog(@"pushViewController: %@ animated: %d", newChild, animated);
    
    UIViewController* oldChild = nil;
    if ( self.childViewControllers && self.childViewControllers.count > 0 ) {
        oldChild = [self.childViewControllers lastObject];
    }
    
    [oldChild beginAppearanceTransition:NO animated:animated];
    [newChild beginAppearanceTransition:YES animated:animated];
    
    // addChildViewController
    [newChild willMoveToParentViewController:self];
    [self addChildViewController:newChild];
    
    // add newChild.view
    newChild.view.frame = self.contentView.bounds;
    [self.contentView addSubview:newChild.view];
    
    // push navigationItem into self.navigationBar
    if ( self.navigationBar ) {
        [self.navigationBar pushNavigationItem:newChild.navigationItem animated:NO];
    }
    
    // show/hide views (with animation)
    if ( oldChild != nil ) {
        newChild.view.alpha = 0.f;
        newChild.view.hidden = NO;
        
        [self transiteFromChild:oldChild toChild:newChild animated:animated reversed:NO completion:^{
            [newChild didMoveToParentViewController:self];
            
            [oldChild endAppearanceTransition];
            [newChild endAppearanceTransition];
        }];
    }
    
    NSLog(@"childViewControllers: %@", self.childViewControllers);
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated;
{
    NSLog(@"popViewControllerAnimated: %d", animated);
    
    if ( !self.childViewControllers || self.childViewControllers.count < 1 ) return nil;
    
    // get lastChild to be popped
    UIViewController* lastChild = nil;
    if ( self.childViewControllers && self.childViewControllers.count > 0 ) {
        lastChild = [self.childViewControllers lastObject];
    }
    
    // get newly activeChild
    UIViewController* activeChild = nil;
    if ( self.childViewControllers && self.childViewControllers.count > 1 ) {
        activeChild = [self.childViewControllers objectAtIndex:(self.childViewControllers.count-2)];
    }
    
    [lastChild beginAppearanceTransition:NO animated:animated];
    [activeChild beginAppearanceTransition:YES animated:animated];
    
    // removeChildViewController
    [lastChild willMoveToParentViewController:nil];
    [lastChild removeFromParentViewController];
    
    // show/hide views (with animation)
    if ( activeChild ) {
        
        [self transiteFromChild:lastChild toChild:activeChild animated:animated reversed:YES completion:^{
            [lastChild.view removeFromSuperview];
            [lastChild didMoveToParentViewController:nil];
            
            [lastChild endAppearanceTransition];
            [activeChild endAppearanceTransition];
        }];
    }
    
    NSLog(@"childViewControllers: %@", self.childViewControllers);
    
    return activeChild;
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated;
{
    if ( self.childViewControllers.count < 2 ) return nil;
    NSMutableArray* popedViewControllers = [[NSMutableArray alloc] initWithCapacity:(self.childViewControllers.count-1)];
    while (self.childViewControllers.count > 1) {
        UIViewController* popedViewController = [self popViewControllerAnimated:animated];
        [popedViewControllers addObject:popedViewController];
    }
    return popedViewControllers;
}




#pragma mark - Methods overriding

- (UIViewController*)topViewController
{
    return [self.childViewControllers lastObject];
}


#pragma mark - UINavigationBarDelegate methods
/*
- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPushItem:(UINavigationItem *)item; // called to push. return NO not to.
{
    return YES;
}
- (void)navigationBar:(UINavigationBar *)navigationBar didPushItem:(UINavigationItem *)item;    // called at end of animation of push or immediately if not animated
{
    NSLog(@"didPushItem: %@", item);
}
- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item;  // same as push methods
{
    if ( ![self.navigationBar.items containsObject:item] ) return NO;
    NSLog(@"shouldPopItem: %@", item);
    [self popViewControllerAnimated:YES];
    return YES;
}
- (void)navigationBar:(UINavigationBar *)navigationBar didPopItem:(UINavigationItem *)item;
{
    NSLog(@"didPopItem: %@", item);
}
*/
@end
