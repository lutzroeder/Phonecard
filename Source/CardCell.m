
#import "CardCell.h"

@implementation CardCell

static UIImage* checkmarkImage = nil;
static UIImage* checkmarkImageSelected = nil;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    if (checkmarkImage == nil)
    {
        checkmarkImage = [UIImage imageNamed:@"Checkmark"];
    }
    if (checkmarkImageSelected == nil)
    {
        checkmarkImageSelected = [UIImage imageNamed:@"Checkmark_"];
    }

    self.imageView.image = checkmarkImage;
    self.imageView.highlightedImage = checkmarkImageSelected;
    self.imageView.hidden = YES;
    return self;
}

- (BOOL)checkmark
{
    return !self.imageView.hidden;
}

- (void)setCheckmark:(BOOL)value
{
    self.imageView.hidden = !value;
    self.textLabel.textColor = value ? [UIColor colorWithRed:56/256 green:84/256 blue:135/256 alpha:1] : [UIColor blackColor];
}

@end
