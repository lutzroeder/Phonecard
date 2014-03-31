
#import "Recent.h"

@implementation Recent

@synthesize phoneNumber;
@synthesize dateTime;

- (id)init
{
    self = [super init];
    self.phoneNumber = @"";
	NSDate* now = [[NSDate alloc] init];
    self.dateTime = now;
	[now release];
    return self;
}

- (void) dealloc
{
    self.phoneNumber = nil;
    self.dateTime = nil;
    [super dealloc];
}

@end
