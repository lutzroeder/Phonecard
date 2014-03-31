
#import <Foundation/Foundation.h>

@protocol ServiceProvider <NSObject>

@required

- (id) serviceWithName:(NSString*)serviceName;

@end
