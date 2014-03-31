
#import "NumberController.h"

@implementation NumberController

- (id)init
{
    self = [super init];
    return self;
}

- (id) initWithAction:(DialAction*)dialAction description:(NSString*)description keyboardType:(UIKeyboardType)keyboardType editMode:(BOOL)editMode;
{
    self = [super initWithValue:dialAction.value label:[dialAction label] description:description keyboardType:keyboardType maxLength:32 target:self action:@selector(commit:)];
    _dialAction = [dialAction retain];
    _editMode = editMode;
    return self;
}

- (void) dealloc
{
    [_dialAction release];
    _dialAction = nil;
    [super dealloc];
}

- (void) commit:(NSString*)value
{
    _dialAction.value = [value retain];
}

@end
