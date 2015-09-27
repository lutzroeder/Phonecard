
#import "Application.h"

@implementation Application

- (id) init
{
    self = [super init];
    [self setDelegate:self];
    _serviceTable = [[NSMutableDictionary alloc] init];
    return self;
}

- (void)dealloc
{
    if (_contactsController != nil)
    {
        [_contactsController release];
        _contactsController = nil;
    }
    [_window release];
    [_serviceTable release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{ 
    StorageService* storageService = [[StorageService alloc] init];
    [_serviceTable setObject:storageService forKey:@"StorageService"];
    
    AddressBookService* addressBookService = [[AddressBookService alloc] init];
    [_serviceTable setObject:addressBookService forKey:@"AddressBookService"];
    
    PhoneService* phoneService = [[PhoneService alloc] initWithServiceProvider:self];
    [_serviceTable setObject:phoneService forKey:@"PhoneService"];

    FavoritesController* favoritesController = [[FavoritesController alloc] initWithServiceProvider:self];
    UINavigationController *favoritesNavigationController = [[NavigationController alloc] initWithRootViewController:favoritesController];
    [favoritesController release];
    
    RecentsController* recentsController = [[RecentsController alloc] initWithServiceProvider:self];
    UINavigationController *recentsNavigationController = [[NavigationController alloc] initWithRootViewController:recentsController];
    [recentsNavigationController.navigationBar updateStyle];
    [recentsController release];

    UITabBarItem* contactsItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemContacts tag:3];
    _contactsController = [[UIViewController alloc] init];
    [_contactsController setTabBarItem:contactsItem];
    [contactsItem release];
    
    UIViewController *keyPadController = [[KeyPadController alloc] initWithServiceProvider:self];

    CardsController* cardsController = [[CardsController alloc] initWithServiceProvider:self];
    UINavigationController *cardsNavigationController = [[NavigationController alloc] initWithRootViewController:cardsController];
    [cardsNavigationController.navigationBar updateStyle];
    [cardsController release];

    UITabBarController* tabBarController = [[UITabBarController alloc] init];
    tabBarController.delegate = self;
    tabBarController.viewControllers = [NSArray arrayWithObjects:
        favoritesNavigationController, 
        recentsNavigationController,
        _contactsController,
        keyPadController,
        cardsNavigationController,
        nil
    ];

    [favoritesNavigationController release];
    [recentsNavigationController release];
    [keyPadController release];
    [cardsNavigationController release];    

    if (storageService.activeCard == nil)
    {
        tabBarController.selectedIndex = 4;
    }

    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    _window.backgroundColor = [UIColor clearColor];
    _window.opaque = NO;
    
    [_window setRootViewController:tabBarController];
    [_window makeKeyAndVisible];

    [tabBarController release];

    [phoneService release];
    [addressBookService release];
    [storageService release];
    
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    StorageService* storageService = [self serviceWithName:@"StorageService"];
    [storageService save];
    
    [_serviceTable removeObjectForKey:@"PhoneService"];
    [_serviceTable removeObjectForKey:@"AddressBookService"];
    [_serviceTable removeObjectForKey:@"StorageService"];
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    NSMutableArray *viewControllers = (NSMutableArray *) tabBarController.viewControllers;

    if (viewController == _contactsController)
    {
        ContactsController *newContactsController = [[ContactsController alloc] initWithServiceProvider:self];
        [newContactsController.navigationBar updateBackgroundImage];
        [viewControllers replaceObjectAtIndex:2 withObject:newContactsController];
        [newContactsController release];
        
        tabBarController.viewControllers = viewControllers;
        
        if (_contactsController != nil)
        {
            [_contactsController release];
            _contactsController = nil;
        }
    }
    
    UINavigationController* favoritesController = [viewControllers objectAtIndex:0];
    [favoritesController popToRootViewControllerAnimated:NO];

    UINavigationController* recentsController = [viewControllers objectAtIndex:1];
    [recentsController popToRootViewControllerAnimated:NO];
}

- (id) serviceWithName:(NSString*)serviceName
{
    return [_serviceTable objectForKey:serviceName];
}

@end
