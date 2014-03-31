
#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "ServiceProvider.h"
#import "PhoneService.h"
#import "KeyPadLabel.h"

@interface iOS6_KeyPadController : UIViewController
{
    @private
    id<ServiceProvider> _serviceProvider;
    KeyPadLabel* _phoneNumberLabel;
    NSMutableDictionary* _soundTable;
    NSMutableArray* _buttonTable;
    NSTimer* _timer;
}

- (id) initWithServiceProvider:(id<ServiceProvider>)serviceProvider;

@end
