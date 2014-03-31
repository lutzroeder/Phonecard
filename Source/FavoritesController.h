
#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "ServiceProvider.h"
#import "AddressBookService.h"
#import "StorageService.h"
#import "PeoplePickerNavigationController.h"
#import "FavoriteCell.h"
#import "StorageService.h"
#import "NSString.h"
#import "UINavigationBar.h"

@interface FavoritesController : UITableViewController <UITableViewDataSource, UITableViewDelegate, ABPeoplePickerNavigationControllerDelegate>
{
    id<ServiceProvider> _serviceProvider;
    UIBarButtonItem* _addButton;
}

- (id) initWithServiceProvider:(id<ServiceProvider>)serviceProvider;

- (void) updateEditButton;
- (void) showDetails:(Favorite*)favorite;

@end
