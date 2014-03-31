
#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "ServiceProvider.h"
#import "PhoneService.h"
#import "KeyPadButton.h"
#import "KeyPadLabel.h"

@interface KeyPadController : UIViewController
{
    id<ServiceProvider> _serviceProvider;
    KeyPadLabel* _phoneNumberLabel;
    UIButton* _backButton;
    NSTimer* _timer;
    NSMutableDictionary* _soundTable;
    NSMutableArray* _buttonTable;
}

- (id) initWithServiceProvider:(id<ServiceProvider>)serviceProvider;

@end
