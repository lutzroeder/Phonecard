
#import "KeyPadLabel.h"

@implementation KeyPadLabel

- (void) tapHandler:(UIGestureRecognizer*) recognizer
{
    [self becomeFirstResponder];
    
    UIMenuController *menu = [UIMenuController sharedMenuController];
    [menu setTargetRect:self.frame inView:self.superview];
    [menu setMenuVisible:YES animated:YES];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    self.userInteractionEnabled = YES;
    
    UIGestureRecognizer* tapGestureRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)] autorelease];
    [self addGestureRecognizer:tapGestureRecognizer];

    return self;
}

- (BOOL) canBecomeFirstResponder
{
    return YES;
}

- (void) copy:(id)sender
{
    UIPasteboard* pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = self.text;  
}

- (void) paste:(id)sender
{
    UIPasteboard* pasteboard = [UIPasteboard generalPasteboard];
    self.text = pasteboard.string;
}

- (BOOL) canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(copy:))
    {
        return YES;
    }
    
    if (action == @selector(paste:))
    {
        UIPasteboard* pasteboard = [UIPasteboard generalPasteboard];
        NSString* string = pasteboard.string;
        if (![NSString isNullOrEmpty:string])
        {
            NSCharacterSet* characterSet = [NSCharacterSet characterSetWithCharactersInString:@"+()-#0123456789 "];
            BOOL enabled = [string rangeOfCharacterFromSet:characterSet.invertedSet].location == NSNotFound;
            return enabled;
        }
    }
    
    return [super canPerformAction:action withSender:sender];
}

@end
