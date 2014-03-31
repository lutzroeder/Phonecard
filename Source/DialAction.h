
#import <Foundation/Foundation.h>

@interface DialAction : NSObject

@property (readwrite, retain) NSString* name;
@property (readwrite, retain) NSString* value;

- (id) initWithName:(NSString *)actionName value:(NSString *)actionValue;

- (NSString*) label;

@end
