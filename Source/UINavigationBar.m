
#import <Foundation/Foundation.h>

@implementation UINavigationBar (Style)

- (void) drawRect:(CGRect)rect 
{
    UIImage* image = [UIImage imageNamed: @"NavigationBar.png"];
    [image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
}

- (void) updateStyle
{
}

- (void) updateBackgroundImage
{
    if ([[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] intValue] < 7)
    {
        self.barStyle = UIBarStyleBlack;
        
        if ([self respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)])
        {
            [self setBackgroundImage:[UIImage imageNamed:@"NavigationBar.png"] forBarMetrics:UIBarMetricsDefault];
        }
    }
}

@end
