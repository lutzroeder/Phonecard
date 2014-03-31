
#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@interface AddressBookEntry : NSObject

@property (readwrite, assign) ABRecordRef person;
@property (readwrite, retain) NSString* label;
@property (readwrite, assign) NSInteger identifier;

@end
