
#import <Foundation/Foundation.h>
#import "NSString.h"
#import "ServiceProvider.h"
#import "StorageService.h"

@interface PhoneService : NSObject <UIAlertViewDelegate>
{
    @private
    id<ServiceProvider> _serviceProvider;
    NSString* _phoneNumber;
}

- (id) initWithServiceProvider:(id<ServiceProvider>)serviceProvider;

- (void) call:(NSString*)phoneNumber;

+ (NSString*) formatPhoneNumber:(NSString*)number;

@end
