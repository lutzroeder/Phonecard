
#import "NavigationController.h"

@implementation NavigationController

- (id) initWithRootViewController:(UIViewController*)rootViewController
{
    self = [super initWithRootViewController:rootViewController];

    [self.navigationBar updateBackgroundImage];
    
    return self;
}

@end
