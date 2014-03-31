
#import <Foundation/Foundation.h>
#import "AddressBookEntry.h"
#import "Favorite.h"
#import "PhoneService.h"

@interface AddressBookService : NSObject
{
    @private
    ABAddressBookRef _addressBook;
}

- (AddressBookEntry*) getPhoneEntry:(NSString*) phoneNumber;
- (ABPersonViewController*) getPersonViewController:(NSString*) phoneNumber;
- (void) updateFavorite:(Favorite*) favorite;

@end
