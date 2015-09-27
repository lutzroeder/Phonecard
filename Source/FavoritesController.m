
#import "FavoritesController.h"

@implementation FavoritesController

- (id) initWithServiceProvider:(id<ServiceProvider>)serviceProvider
{
    self = [super init];
    _serviceProvider = [serviceProvider retain];
    self.tabBarItem = [[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemFavorites tag:0] autorelease];
    return self;
}

- (void) dealloc
{
    [_addButton release];
    _addButton = nil;
    [_serviceProvider release];
    _serviceProvider = nil;
    [super dealloc];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (_addButton == nil)
    {
        self.title = NSLocalizedString(@"Favorites", nil);
        _addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonClick:)];
        self.navigationItem.rightBarButtonItem = _addButton;
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        [self updateEditButton];
    }
}

- (void) viewWillDisappear:(BOOL)animated
{
    [self setEditing:NO animated:YES];
    [super viewWillDisappear:animated];
}

- (void) setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    self.navigationItem.rightBarButtonItem = editing ? nil : _addButton;
}

- (void) updateEditButton
{
    StorageService* storageService = [_serviceProvider serviceWithName:@"StorageService"];
    UIBarButtonItem* rightBarButtonItem = (storageService.favorites.count == 0) ? nil : self.editButtonItem;
    [self.navigationItem setLeftBarButtonItem:rightBarButtonItem animated:YES];
}

- (void) addButtonClick:(id)sender
{
	// Launch PeoplePicker only showing phone numbers.
    ABPeoplePickerNavigationController* peoplePickerNavigationController = [[PeoplePickerNavigationController alloc] init];
    [peoplePickerNavigationController.navigationBar updateStyle];
	peoplePickerNavigationController.displayedProperties = [NSArray arrayWithObject:[NSNumber numberWithInt:kABPersonPhoneProperty]];
	peoplePickerNavigationController.peoplePickerDelegate = self;
    peoplePickerNavigationController.navigationBar.topItem.prompt = NSLocalizedString(@"Choose a contact to add to Favorites", nil);
    [self presentViewController:peoplePickerNavigationController animated:YES completion:nil];
    [peoplePickerNavigationController release];
}

- (void) showDetails:(Favorite*)favorite
{
    AddressBookService* addressBookService = [_serviceProvider serviceWithName:@"AddressBookService"];
    
    ABPersonViewController* personViewController = [addressBookService getPersonViewController:favorite.phoneNumber];
    if (personViewController != nil)
    {
        UINavigationController* navigationController = (UINavigationController*) self.parentViewController;
        [navigationController pushViewController:personViewController animated:YES];   
    }

    [addressBookService updateFavorite:favorite];
}
     
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController*)peoplePicker;
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
	return YES;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    ABMultiValueRef multiValue = ABRecordCopyValue(person, property);
    CFIndex index = ABMultiValueGetIndexForIdentifier(multiValue, identifier);
	NSString* phoneNumber = (NSString*) ABMultiValueCopyValueAtIndex(multiValue, index);
    
	Favorite* favorite = [[Favorite alloc] init];
    favorite.phoneNumber = phoneNumber;
    
    CFRelease(multiValue);
    [phoneNumber release];
    
    AddressBookService* addressBookService = [_serviceProvider serviceWithName:@"AddressBookService"];
    [addressBookService updateFavorite:favorite];
    
    StorageService* storageService = [_serviceProvider serviceWithName:@"StorageService"];
    [storageService.favorites addObject:favorite];
    [storageService save];
    
    [favorite release];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [self updateEditButton];

    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:(storageService.favorites.count - 1) inSection:0], nil] withRowAnimation:UITableViewRowAnimationTop];

    return NO;
}

- (BOOL) modernStyle
{
	return !([[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] intValue] < 7);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView 
{
	return 1;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section 
{
    StorageService* storageService = [_serviceProvider serviceWithName:@"StorageService"];
    return storageService.favorites.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return (self.modernStyle) ? 48 : [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath 
{
    FavoriteCell* cell = (FavoriteCell*) [tableView dequeueReusableCellWithIdentifier:@"Favorites"];
    if (cell == nil)
    {
        cell = [[[FavoriteCell alloc] init] autorelease];
    }

    StorageService* storageService = [_serviceProvider serviceWithName:@"StorageService"];
    Favorite* favorite = [storageService.favorites objectAtIndex:indexPath.row];
    if ([NSString isNullOrEmpty:favorite.name] || [NSString isNullOrEmpty:favorite.label])
    {
        AddressBookService* addressBookService = [_serviceProvider serviceWithName:@"AddressBookService"];
        [addressBookService updateFavorite:favorite];
    }

    cell.textLabel.text = [NSString isNullOrEmpty:favorite.name] ? favorite.phoneNumber : favorite.name;
    cell.detailTextLabel.text = [favorite.label lowercaseString];
    return cell;
}

- (void) tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath 
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    StorageService* storageService = [_serviceProvider serviceWithName:@"StorageService"];
    Favorite* favorite = [storageService.favorites objectAtIndex:indexPath.row];

    PhoneService* phoneService = [_serviceProvider serviceWithName:@"PhoneService"];
    [phoneService call:favorite.phoneNumber];
}

- (void)tableView:(UITableView*)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath*)indexPath
{
    StorageService* storageService = [_serviceProvider serviceWithName:@"StorageService"];
    Favorite* favorite = [storageService.favorites objectAtIndex:indexPath.row];
    [self showDetails:favorite];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        StorageService* storageService = [_serviceProvider serviceWithName:@"StorageService"];
        [storageService.favorites removeObjectAtIndex:indexPath.row];
        [storageService save];

        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationTop];
        [self updateEditButton];
        [self setEditing:NO animated:YES];
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    StorageService* storageService = [_serviceProvider serviceWithName:@"StorageService"];
    Favorite* favorite = [[storageService.favorites objectAtIndex:sourceIndexPath.row] retain];
    [storageService.favorites removeObjectAtIndex:sourceIndexPath.row];
    [storageService.favorites insertObject:favorite atIndex:destinationIndexPath.row];
    [favorite release];
    [storageService save];
}

@end
