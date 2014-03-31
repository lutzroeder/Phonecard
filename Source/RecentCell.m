
#import "RecentCell.h"

@implementation RecentCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Favorites"];
 
	self.textLabel.font = [UIFont boldLargeFont];

    if ([[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] intValue] < 7)
	{
		self.detailTextLabel.font = [UIFont systemFontOfSize:12];
	}
	else
	{
		self.detailTextLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
		self.detailTextLabel.textColor = [UIColor lightGrayColor];
    }
	
    self.textLabel.font = [UIFont boldLargeFont];
    self.editingAccessoryType = UITableViewCellAccessoryNone;
    [self updateDetailButton];
    return self;
}

@end
