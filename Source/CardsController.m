
#import "CardsController.h"
#import "CardController.h"
#import "WebViewController.h"

@implementation CardsController

- (id) initWithServiceProvider:(id<ServiceProvider>)serviceProvider
{
    self = [super init];
    _launched = NO;
    _serviceProvider = [serviceProvider retain];
    self.tabBarItem = [[[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Cards", nil) image:[UIImage imageNamed:@"Cards"] tag:5] autorelease];
    return self;
}

- (void) dealloc
{
    [_serviceProvider release];
    _serviceProvider = nil;
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    self.title = NSLocalizedString(@"Cards", nil);
    
    UIButton *cardStoreButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    cardStoreButton.frame = CGRectMake(10, 5, 300, 40);
    [cardStoreButton addTarget:self action:@selector(CardStoreClick:) forControlEvents:UIControlEventTouchUpInside];
    [cardStoreButton setTitle:NSLocalizedString(@"Card Store", nil) forState:UIControlStateNormal];

    UIView *cardStoreButtonView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)] autorelease];
    [cardStoreButtonView addSubview:cardStoreButton];

    UITableView* tableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped] autorelease];

    tableView.dataSource = self;
    tableView.allowsSelection = YES;
    tableView.tableFooterView = cardStoreButtonView;
    self.tableView = tableView;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void) newCard:(BOOL)animated
{
    Card* newCard = [Card newDefaultCard];
    CFUUIDRef uuid = CFUUIDCreate(nil);
    NSString* identifier = (NSString*)CFUUIDCreateString(nil, uuid);
    newCard.identifier = identifier;
    [identifier release];
    CFRelease(uuid);
    
    CardController* cardController = [[CardController alloc] initWithServiceProvider:_serviceProvider card:newCard editMode:NO cardsController:self];
    [self.navigationController pushViewController:cardController animated:animated];
    [cardController release];
    
    [newCard release];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!_launched)
    {
        _launched = YES;
        
        StorageService* storageService = [_serviceProvider serviceWithName:@"StorageService"];
        if (storageService.cards.count == 0)
        {
            [self newCard:NO];
        }
    }
}

- (void) addCard:(Card*)card
{
    StorageService* storageService = [_serviceProvider serviceWithName:@"StorageService"];
    [storageService.cards addObject:card];
    storageService.activeCard = card;
    [storageService save];

    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:(storageService.cards.count - 1) inSection:0], nil] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)removeCard:(Card*)card
{
    StorageService* storageService = [_serviceProvider serviceWithName:@"StorageService"];

    NSInteger index = [storageService.cards indexOfObject:card];
    [storageService.cards removeObjectAtIndex:index];
    [storageService save];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:index inSection:0], nil] withRowAnimation:UITableViewRowAnimationFade];
}

- (void) showCard:(NSInteger)index
{
    StorageService* storageService = [_serviceProvider serviceWithName:@"StorageService"];
    Card* card = [storageService.cards objectAtIndex:index];

    CardController* cardController = [[CardController alloc] initWithServiceProvider:_serviceProvider card:card editMode:YES cardsController:self];
    [self.navigationController pushViewController:cardController animated:YES];
    [cardController release];
}

- (void)CardStoreClick:(id)sender
{
    NSURL* url = [NSURL URLWithString:@"http://www.callingcards.com/ap/t_entry.asp?AffID=8778&text_id=1"];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    
    WebViewController* webViewController = [[[WebViewController alloc] initWithRequest:request] autorelease];
    webViewController.title = NSLocalizedString(@"Card Store", nil);
    
    UINavigationController* navigationController = [[[NavigationController alloc] initWithRootViewController:webViewController] autorelease];
    [self presentModalViewController:navigationController animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView 
{
	return 1;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section 
{
    if (section == 0)
    {
        StorageService* storageService = [_serviceProvider serviceWithName:@"StorageService"];
        return storageService.cards.count + 1;
    }
    return 0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath 
{
    StorageService* storageService = [_serviceProvider serviceWithName:@"StorageService"];
    if (indexPath.section == 0)
    {
        CardCell* cell;
        if (indexPath.row < storageService.cards.count)
        {
            cell = (CardCell*) [tableView dequeueReusableCellWithIdentifier:@"Card"];
            if (cell == nil)
            {
                cell = [[[CardCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Card"] autorelease];
                [cell updateDetailButton];
            }
            
            Card* card = [storageService.cards objectAtIndex:indexPath.row];
            [cell setCheckmark:storageService.activeCard == card];
            [cell.textLabel setText:[NSString isNullOrEmpty:card.name] ? NSLocalizedString(@"My Calling Card", nil) : card.name];
            return cell;
        }
        else
        {
            cell = (CardCell*) [tableView dequeueReusableCellWithIdentifier:@"AddCard"];
            if (cell == nil)
            {
                cell = [[[CardCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AddCard"] autorelease];
            }
            cell.textLabel.text = NSLocalizedString(@"Add Card...", nil);
            return cell;
        }
    }
    
    return nil;
}

- (void) tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath 
{
    StorageService* storageService = [_serviceProvider serviceWithName:@"StorageService"];
    if (indexPath.section == 0)
    {
        if (indexPath.row < storageService.cards.count)
        {
            if (tableView.editing)
            {
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                [self showCard:indexPath.row];
            }
            else
            {
                storageService.activeCard = [storageService.cards objectAtIndex:indexPath.row];
                [storageService save];
                
                for (NSInteger i = 0; i < storageService.cards.count; i++)
                {
                    CardCell* cell = (CardCell*) [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                    [cell setCheckmark:storageService.activeCard == [storageService.cards objectAtIndex:i]];
                }
                
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
            }
        }
        else
        {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [self newCard:YES];
        }
    }
}

- (void)tableView:(UITableView*)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.section == 0)
    {
        StorageService* storageService = [_serviceProvider serviceWithName:@"StorageService"];
        if (indexPath.row < storageService.cards.count)
        {
            [self showCard:indexPath.row];
        }
    }
}

@end
