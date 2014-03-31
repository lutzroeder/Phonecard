
#import "FavoriteCell.h"

@implementation FavoriteCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Favorites"];
    self.detailTextLabel.textColor = [UIColor lightGrayColor];
	
	if ([[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] intValue] < 7)
	{
		self.detailTextLabel.font = [UIFont boldSystemFontOfSize:15];
	}
	else
	{
		self.detailTextLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
	}
	
    self.textLabel.font = [UIFont boldLargeFont];
    self.editingAccessoryType = UITableViewCellAccessoryNone;
    [self updateDetailButton];
    return self;
}

- (void)layoutSubviews
{
    CGFloat width = self.textLabel.frame.size.width;
    CGRect frame = self.detailTextLabel.frame;

    [super layoutSubviews];
	
    if (self.showingDeleteConfirmation)
    {
        self.textLabel.frame = CGRectMake(self.textLabel.frame.origin.x, self.textLabel.frame.origin.y, width, self.textLabel.frame.size.height);
        self.detailTextLabel.frame = frame;
        self.detailTextLabel.hidden = YES;
    }
    else
    {
        self.detailTextLabel.hidden = NO;
    }    
}

@end
