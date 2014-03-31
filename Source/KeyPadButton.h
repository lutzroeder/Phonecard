
#import <Foundation/Foundation.h>

@interface KeyPadButton : UIButton
{
    NSMutableDictionary* _backgroundColors;
}

- (void)setBackgroundColor:(UIColor*)color forState:(UIControlState)state;
- (UIColor*)backgroundColorForState:(UIControlState)state;

@end
