
#import <Foundation/Foundation.h>
#import "StorageService.h"

@interface PauseController : UITableViewController <UITableViewDataSource, UITableViewDelegate>
{
    DialAction* _dialAction;
    BOOL _editMode;
}

- (id) initWithAction:(DialAction*)dialAction editMode:(BOOL)editMode;

@end
