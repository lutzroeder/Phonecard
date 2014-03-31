
#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "ServiceProvider.h"
#import "PhoneService.h"

@interface ContactsController : ABPeoplePickerNavigationController <UINavigationControllerDelegate, ABPeoplePickerNavigationControllerDelegate>
{
    id<ServiceProvider> _serviceProvider;
}

- (id) initWithServiceProvider:(id<ServiceProvider>)serviceProvider;

@end
