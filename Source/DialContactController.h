
#import <Foundation/Foundation.h>
#import "StorageService.h"
#import "TextController.h"
#import "NSString.h"

@interface DialContactController : UITableViewController <UITableViewDataSource, UITableViewDelegate>
{
    DialAction* _dialAction;
    BOOL _editMode;
}

- (id) initWithAction:(DialAction*)dialAction editMode:(BOOL)editMode;

- (void) tableViewCell:(UITableViewCell*)cell setDetailText:(NSString*)value;

- (NSString*) actionValue:(NSInteger)part;
- (void) setActionValue:(NSInteger)part value:(NSString*)value;

- (void) setReplacePrefix:(NSString*)value;
- (void) setSkipReplacement:(NSString*)value;
- (void) setRemoveCountryCode:(NSString*)value;

@end
