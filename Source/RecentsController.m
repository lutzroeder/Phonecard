
#import "RecentsController.h"

@implementation RecentsController

- (id) initWithServiceProvider:(id<ServiceProvider>)serviceProvider
{
    self = [super init];

    _serviceProvider = [serviceProvider retain];
    
    self.tabBarItem = [[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemRecents tag:2] autorelease];

    self.tableView.dataSource = self;
    self.tableView.delegate = self;

    StorageService* storageService = [_serviceProvider serviceWithName:@"StorageService"];
    [storageService addObserver:self forKeyPath:@"recents" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];

    return self;
}

- (void) dealloc
{
    [_trashButton release];
    _trashButton = nil;

    if (_serviceProvider)
    {
        StorageService* storageService = [_serviceProvider serviceWithName:@"StorageService"];
        [storageService.recents removeObserver:self forKeyPath:@""];
        
        [_serviceProvider release];
        _serviceProvider = nil;
    }

    [super dealloc];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.navigationController popToRootViewControllerAnimated:NO];
    
    if (_trashButton == nil)
    {
        self.title = NSLocalizedString(@"Recents", nil);
        _trashButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(trashClick:)];
        [self updateTrashButton];
    }
}

- (void) observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context
{
    StorageService* storageService = [_serviceProvider serviceWithName:@"StorageService"];
    if ((object == storageService) && ([keyPath isEqualToString:@"recents"]))
    {
        [self update];
    }
}

- (void) trashClick:(id)sender
{
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:NSLocalizedString(@"Clear All Recents", nil) otherButtonTitles:nil];
    [actionSheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
    [actionSheet showInView:self.navigationController.parentViewController.view];
    [actionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    if (buttonIndex == 0)
    {
        StorageService* storageService = [_serviceProvider serviceWithName:@"StorageService"];
        [storageService.recents removeAllObjects];
        [storageService save];
        [self update];
    }
}

- (void) updateTrashButton
{
    StorageService* storageService = [_serviceProvider serviceWithName:@"StorageService"];
    self.navigationItem.rightBarButtonItem = storageService.recents.count == 0 ? nil : _trashButton;
}

- (void) update
{
    [self updateTrashButton];
    [self.tableView reloadData];
}

- (void) showDetails:(Recent*)recent
{
    AddressBookService* addressBookService = [_serviceProvider serviceWithName:@"AddressBookService"];
    
    ABPersonViewController* personViewController = [addressBookService getPersonViewController:recent.phoneNumber];
    if (personViewController != nil)
    {
        UINavigationController* navigationController = (UINavigationController*) self.parentViewController;
        [navigationController pushViewController:personViewController animated:YES];
    }
}

- (BOOL) modernStyle
{
	return !([[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] intValue] < 7);
}

- (NSInteger) numberOfSectionsInTableView:(UITableView*)tableView 
{
	return 1;
}

- (NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section 
{
    StorageService* storageService = [_serviceProvider serviceWithName:@"StorageService"];
    return storageService.recents.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return (self.modernStyle) ? 48 : [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath 
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Recents"];
    if (cell == nil)
    {
        cell = [[[RecentCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Recents"] autorelease];
    }

    StorageService* storageService = [_serviceProvider serviceWithName:@"StorageService"];
    Recent* recent = [storageService.recents objectAtIndex:indexPath.row];
    NSString* phoneNumber = recent.phoneNumber;
    
    AddressBookService* addressBookService = [_serviceProvider serviceWithName:@"AddressBookService"];
    AddressBookEntry* entry = [addressBookService getPhoneEntry:phoneNumber];
    if (entry != nil)
    {
        NSString* compositeName = (NSString*) ABRecordCopyCompositeName(entry.person);
        cell.textLabel.text = compositeName;
        [compositeName release];
    }
    else
    {
        cell.textLabel.text = phoneNumber;
    }
    
    NSDateFormatter* timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setLocale:[NSLocale currentLocale]];
    [timeFormatter setDateStyle:NSDateFormatterNoStyle];
    [timeFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    
    NSDate* now = [[NSDate alloc] init];
    NSDate* date = recent.dateTime;

    if ([[dateFormatter stringFromDate:date] isEqualToString:[dateFormatter stringFromDate:now]])
    {
        cell.detailTextLabel.text = [timeFormatter stringFromDate:date]; 
    }
    else
    {
        cell.detailTextLabel.text = [dateFormatter stringFromDate:date];
    }
    
    [now release];
    [timeFormatter release];
    [dateFormatter release];
    
    return cell;    
}

- (void) tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath 
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    StorageService* storageService = [_serviceProvider serviceWithName:@"StorageService"];
    Recent* recent = [storageService.recents objectAtIndex:indexPath.row];

    PhoneService* phoneService = [_serviceProvider serviceWithName:@"PhoneService"];
    [phoneService call:recent.phoneNumber];
}

- (void) tableView:(UITableView*)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath*)indexPath
{
    StorageService* storageService = [_serviceProvider serviceWithName:@"StorageService"];
    Recent* recent = [storageService.recents objectAtIndex:indexPath.row];
    [self showDetails:recent];
}

@end
