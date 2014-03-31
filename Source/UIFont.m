
#import "UIFont.h"

@implementation UIFont (Style)

+ (UIFont*) boldLargeFont
{
    if ([[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] intValue] < 7)
    {
        return [UIFont fontWithName:@"Helvetica-Bold" size:20];
    }
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
}

+ (UIFont*) smallFont
{
    return nil;
}

@end
