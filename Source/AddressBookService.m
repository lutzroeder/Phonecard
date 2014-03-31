
#import "AddressBookService.h"

@implementation AddressBookService

- (void) dealloc
{
    if (_addressBook != nil)
    {
        CFRelease(_addressBook);
        _addressBook = nil;
    }
    [super dealloc];
}

- (AddressBookEntry*) getPhoneEntry:(NSString*)phoneNumber
{
    if (_addressBook == nil)
    {
        _addressBook = ABAddressBookCreate();
    }
    
    AddressBookEntry* entry = nil;
    
    NSString* currentNumber = [PhoneService formatPhoneNumber:phoneNumber];
    
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(_addressBook);
    CFIndex count = ABAddressBookGetPersonCount(_addressBook);
    for (NSUInteger i = 0; i < count; i++)
    {
        ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
        ABMultiValueRef multiValue = ABRecordCopyValue(person, kABPersonPhoneProperty);
        CFIndex multiValueCount = ABMultiValueGetCount(multiValue);
        for (int j = 0; j < multiValueCount; j++)
        {
            NSString* phoneNumber = (NSString*) ABMultiValueCopyValueAtIndex(multiValue, j);
            NSString* formattedPhoneNumber = [PhoneService formatPhoneNumber:phoneNumber];
            if ([currentNumber isEqualToString:formattedPhoneNumber])
            {
                entry = [[[AddressBookEntry alloc] init] autorelease];
                entry.person = person;
                entry.identifier = j;
                entry.label = @"";

                NSString* label = (NSString*) ABMultiValueCopyLabelAtIndex(multiValue, j);
                if ([@"_$!<Mobile>!$_" isEqualToString:label])
                {
                    entry.label = NSLocalizedString(@"Mobile", nil);
                }
                else if ([@"_$!<Work>!$_" isEqualToString:label])
                {
                    entry.label = NSLocalizedString(@"Work", nil);
                }
                else if ([@"_$!<Home>!$_" isEqualToString:label])
                {
                    entry.label = NSLocalizedString(@"Home", nil);
                }
                else if ([@"_$!<Main>!$_" isEqualToString:label])
                {
                    entry.label = NSLocalizedString(@"Main", nil);
                }
                else if ([@"_$!<Other>!$_" isEqualToString:label])
                {
                    entry.label = NSLocalizedString(@"Other", nil);
                }
                else if (![label hasPrefix:@"_$!"])
                {
                    entry.label = label;
                }
                CFRelease(label);
            }
            CFRelease(phoneNumber);
        }
        CFRelease(multiValue);
    }
    CFRelease(allPeople);
    
    return entry;
}

- (ABPersonViewController*) getPersonViewController:(NSString*)phoneNumber
{
    AddressBookEntry* entry = [self getPhoneEntry:phoneNumber];
    if (entry != nil)
    {	
        ABPersonViewController* personViewController = [[ABPersonViewController alloc] init];
        [personViewController setAllowsEditing:NO];
        [personViewController setDisplayedPerson:entry.person];
        [personViewController setHighlightedItemForProperty:kABPersonPhoneProperty withIdentifier:entry.identifier];
        return [personViewController autorelease];
    }
    return nil;
}

- (void) updateFavorite:(Favorite*)favorite
{
    NSString* phoneNumber = favorite.phoneNumber;
    AddressBookEntry* entry = [self getPhoneEntry:phoneNumber];
    if (entry != nil)
    {
        NSString* compositeName = (NSString*) ABRecordCopyCompositeName(entry.person);
        favorite.name = compositeName;
        [compositeName release];
        
        favorite.label = entry.label;
    }
    else
    {
        favorite.name = @"";
        favorite.label = @"";
    }
}

@end
