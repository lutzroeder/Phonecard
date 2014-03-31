
#import "DialContactController.h"

@implementation DialContactController

- (id) initWithAction:(DialAction*)dialAction editMode:(BOOL)editMode;
{
    self = [super init];
    _dialAction = [dialAction retain];
    _editMode = editMode;
    return self;
}

- (void) dealloc
{
    [_dialAction release];
    _dialAction = nil;
    [super dealloc];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.title = [NSLocalizedString(@"Edit {0}", nil) stringByReplacingOccurrencesOfString:@"{0}" withString:[_dialAction label]];

    UITableView* tableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped] autorelease];
    tableView.allowsSelection = YES;
    tableView.allowsSelectionDuringEditing = NO;
    tableView.dataSource = self;
    tableView.delegate = self;
    self.tableView = tableView;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView 
{
	return 1;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section 
{
    return 3;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath 
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Part"];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Part"] autorelease];	
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    switch (indexPath.row)
    {
        case 0:
            cell.textLabel.text = NSLocalizedString(@"Replace '+' With", nil);
            [self tableViewCell:cell setDetailText:[self actionValue:0]];
            break;
        case 1:
            cell.textLabel.text = NSLocalizedString(@"Skip Replacement For", nil);
            [self tableViewCell:cell setDetailText:[self actionValue:1]];
            break;
        case 2:
            cell.textLabel.text = NSLocalizedString(@"Remove Country Code", nil);
            [self tableViewCell:cell setDetailText:[self actionValue:2]];
            break;
    }
    return cell;
}

- (void) tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath 
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row)
    {
        case 0:
            {
                TextController* textController = [[TextController alloc] initWithValue:[self actionValue:0] label:NSLocalizedString(@"Prefix", nil) description:NSLocalizedString(@"The '+' prefix will be replaced with this number (e.g. 011).", nil) keyboardType:UIKeyboardTypeNumberPad maxLength:10 target:self action:@selector(setReplacePrefix:)]; 
                [self.navigationController pushViewController:textController animated:YES];
                [textController release];
            }
            break;
        case 1:
            {
                TextController* textController = [[TextController alloc] initWithValue:[self actionValue:1] label:NSLocalizedString(@"Skip", nil) description:NSLocalizedString(@"Do not replace '+' for this country code (e.g. local country code).", nil) keyboardType:UIKeyboardTypeNumberPad maxLength:3 target:self action:@selector(setSkipReplacement:)]; 
                [self.navigationController pushViewController:textController animated:YES];
                [textController release];
            }
            break;
        case 2:
            {
                TextController* textController = [[TextController alloc] initWithValue:[self actionValue:2] label:NSLocalizedString(@"Country Code", nil) description:NSLocalizedString(@"This country code will be removed before dialing (e.g. 49).", nil) keyboardType:UIKeyboardTypeNumberPad maxLength:3 target:self action:@selector(setRemoveCountryCode:)];
                [self.navigationController pushViewController:textController animated:YES];
                [textController release];
            }
            break;
    }
}

- (void) tableView:(UITableView*)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath*)indexPath
{
}

- (BOOL) tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (void) tableViewCell:(UITableViewCell*)cell setDetailText:(NSString*)value
{
    if ([NSString isNullOrEmpty:value])
    {
        cell.detailTextLabel.text = NSLocalizedString(@"No", nil);
        cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    }
    else
    {
        cell.detailTextLabel.text = value;
        cell.detailTextLabel.textColor = [UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1];
    }
}

- (NSString*) actionValue:(NSInteger)part
{
    NSArray* parts = [[_dialAction value] componentsSeparatedByString:@","];
    if (part < [parts count])
    {
        return [parts objectAtIndex:part];
    }
    return @"";    
}

- (void) setActionValue:(NSInteger)part value:(NSString*)value
{
    NSArray* parts = [[_dialAction value] componentsSeparatedByString:@","];

    NSString* result = @"";
    for (int i = 0; i < 3; i++)
    {
        result = [result stringByAppendingString:(i == part) ? value : ((i < [parts count]) ? [parts objectAtIndex:i] : @"")];
        if (i != 2)
        {
            result = [result stringByAppendingString:@","];
        }
    }
    
    if (![result isEqualToString:_dialAction.value])
    {
        _dialAction.value = result;
    }
}

- (void) setReplacePrefix:(NSString*)value
{
    [self setActionValue:0 value:value];
}

- (void) setSkipReplacement:(NSString*)value
{
    [self setActionValue:1 value:value];    
}

- (void) setRemoveCountryCode:(NSString*)value
{
    [self setActionValue:2 value:value];
}

@end
