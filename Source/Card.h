
#import <Foundation/Foundation.h>
#import "DialAction.h"

@interface Card : NSObject

@property (readwrite, retain) NSString* identifier;
@property (readwrite, retain) NSString* name;
@property (readwrite, retain) NSMutableArray* dialActions;

+ (id) newDefaultCard;

@end
