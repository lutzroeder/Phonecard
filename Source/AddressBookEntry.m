
#import "AddressBookEntry.h"

@implementation AddressBookEntry

@synthesize person;
@synthesize label;
@synthesize identifier;

- (id)init
{
    self = [super init];
    self.label = @"";
    return self;
}

- (void) dealloc
{
    self.label = nil;
    [super dealloc];
}

@end
