
#import "DialAction.h"

@implementation DialAction

@synthesize name;
@synthesize value;

- (id)init
{
    self = [super init];
    self.name = @"";
    self.value = @"";
    return self;
}

- (id) initWithName:(NSString *)actionName value:(NSString *)actionValue
{
    self = [super init];
    self.name = [actionName retain];
    self.value = [actionValue retain];
    return self;
}

- (void) dealloc
{
    self.name = nil;
    self.value = nil;
    [super dealloc];
}

- (NSString*) label
{
    if ([@"dial" isEqualToString:name])
    {
        return NSLocalizedString(@"Dial", nil);
    }
    if ([@"pause" isEqualToString:name])
    {
        return NSLocalizedString(@"Pause", nil);
    }
    if ([@"access" isEqualToString:name])
    {
        return NSLocalizedString(@"Dial Access", nil);
    }
    if ([@"pin" isEqualToString:name])
    {
        return NSLocalizedString(@"PIN", nil);
    }
    if ([@"contact" isEqualToString:name])
    {
        return NSLocalizedString(@"Dial Contact", nil);
    }
    return @"";
}

@end
