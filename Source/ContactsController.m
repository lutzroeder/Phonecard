
#import "ContactsController.h"

@implementation ContactsController

- (id) initWithServiceProvider:(id<ServiceProvider>)serviceProvider
{
    self = [super init];
 
    _serviceProvider = [serviceProvider retain];
    
    self.delegate = self;
    self.tabBarItem = [[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemContacts tag:3] autorelease];
    self.displayedProperties = [NSArray arrayWithObject:[NSNumber numberWithInt:kABPersonPhoneProperty]];
    self.peoplePickerDelegate = self;

    return self;
}

- (void) dealloc
{
    [_serviceProvider release];
    _serviceProvider = nil;
    [super dealloc];
}

- (void) navigationController:(UINavigationController*)navigationController willShowViewController:(UIViewController*)viewController animated:(BOOL)animated
{
    // Hide the cancel button (setAllowsCancel:YES)
    viewController.navigationItem.rightBarButtonItem = nil;
}

- (void) peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController*)peoplePicker;
{
}

- (BOOL) peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
	return YES;
}

- (BOOL) peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    ABMultiValueRef multiValue = ABRecordCopyValue(person, property);
    CFIndex index = ABMultiValueGetIndexForIdentifier(multiValue, identifier);
    NSString* phoneNumber = (NSString*) ABMultiValueCopyValueAtIndex(multiValue, index);
    CFRelease(multiValue);
    
    PhoneService* phoneService = [_serviceProvider serviceWithName:@"PhoneService"];
    [phoneService call:phoneNumber];

    [phoneNumber release];
    
	return NO;
}

@end
