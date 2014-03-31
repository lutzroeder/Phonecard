
#import "KeyPadButton.h"

@implementation KeyPadButton

- (void) dealloc
{
    if (_backgroundColors != nil)
    {
        [_backgroundColors release];
    }
    
    [super dealloc];
}

- (void) setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];

    if (highlighted)
    {
        self.backgroundColor = [self backgroundColorForState:UIControlStateHighlighted];
        self.titleLabel.textColor = [self titleColorForState:UIControlStateHighlighted];
    }
    else
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        self.backgroundColor = [self backgroundColorForState:UIControlStateNormal];
        self.titleLabel.textColor = [self titleColorForState:UIControlStateNormal];;
        [UIView commitAnimations];
    }
}

- (void)setBackgroundColor:(UIColor*)color forState:(UIControlState)state
{
    if (_backgroundColors == nil)
    {
        _backgroundColors = [[NSMutableDictionary alloc] init];
    }
        
    [_backgroundColors setObject:color forKey:[NSNumber numberWithInt:state]];
        
    if (self.backgroundColor == nil)
    {
        [self setBackgroundColor:color];
    }
}

- (UIColor*) backgroundColorForState:(UIControlState)state
{
    UIColor* color = [_backgroundColors objectForKey:[NSNumber numberWithInt:state]];
    return (color != nil) ? color : self.backgroundColor;
}

@end
