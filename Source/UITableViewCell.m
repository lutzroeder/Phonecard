
#import "UITableViewCell.h"

@implementation UITableViewCell (Style)

- (void) updateDetailButton
{
    if ([[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] intValue] < 7)
    {
        self.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    else
    {
        self.accessoryType = UITableViewCellAccessoryDetailButton;
    }
}

@end
