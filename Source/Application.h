
#import <UIKit/UIKit.h>
#import "ServiceProvider.h"
#import "StorageService.h"
#import "AddressBookService.h"
#import "PhoneService.h"
#import "NavigationController.h"
#import "FavoritesController.h"
#import "RecentsController.h"
#import "ContactsController.h"
#import "KeyPadController.h"
#import "iOS6_KeyPadController.h"
#import "CardsController.h"
#import "UINavigationBar.h"

@interface Application : UIApplication <UIApplicationDelegate, UITabBarControllerDelegate, ServiceProvider>
{
    NSMutableDictionary* _serviceTable;
	UIWindow* _window;
    UIViewController* _contactsController;
}
@end
