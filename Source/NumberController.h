
#import <Foundation/Foundation.h>
#import "TextController.h"
#import "StorageService.h"

@interface NumberController : TextController
{
    DialAction* _dialAction;
    BOOL _editMode;
}

- (id) initWithAction:(DialAction*)dialAction description:(NSString*)description keyboardType:(UIKeyboardType)keyboardType editMode:(BOOL)editMode;

@end
