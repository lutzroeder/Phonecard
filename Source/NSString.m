
#import "NSString.h"

@implementation NSString (isNullOrEmpty)

+ (BOOL) isNullOrEmpty:(NSString*)string 
{
    return (string == nil) || ([string length] == 0);
}

@end
