
#import <Foundation/Foundation.h>

@interface TextController : UITableViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
{
    NSString* _value;
    UIKeyboardType _keyboardType;
    NSInteger _maxLength;
    NSObject* _target;
    SEL _selector;
}

- (id) initWithValue:(NSString*)value label:(NSString*)label description:(NSString*)description keyboardType:(UIKeyboardType)keyboardType maxLength:(NSInteger)maxLength target:(id)target action:(SEL)selector;

- (void) cancelClick:(id)sender;
- (void) saveClick:(id)sender;
- (void) save;
- (void) editingChanged:(id)sender;
- (void) commit:(NSString*)value;

@end
