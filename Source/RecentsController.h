
#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "ServiceProvider.h"
#import "AddressBookService.h"
#import "StorageService.h"
#import "PhoneService.h"
#import "RecentCell.h"
#import "UITableViewCell.h"
#import "UIFont.h"

@interface RecentsController : UITableViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>
{
    id<ServiceProvider> _serviceProvider;
    UIBarButtonItem* _trashButton;
}

- (id) initWithServiceProvider:(id<ServiceProvider>)serviceProvider;

- (void) trashClick:(id)sender;

- (void) update;
- (void) updateTrashButton;

- (void) showDetails:(Recent*)recent;

@end
