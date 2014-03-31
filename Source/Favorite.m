
#import "Favorite.h"

@implementation Favorite

@synthesize phoneNumber;
@synthesize name;
@synthesize label;

- (id)init
{
    self = [super init];
    self.phoneNumber = @"";
    self.name = @"";
    self.label = @"";
    return self;
}

- (void) dealloc
{
    self.phoneNumber = nil;
    self.name = nil;
    self.label = nil;
    [super dealloc];
}

@end
