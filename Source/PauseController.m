
#import "PauseController.h"

@implementation PauseController

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
    
    self.title = [NSLocalizedString(@"Edit {0}", nil) stringByReplacingOccurrencesOfString:@"{0}" withString:_dialAction.label];

    UITableView* tableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped] autorelease];
    tableView.allowsSelection = YES;
    tableView.allowsSelectionDuringEditing = YES;
    tableView.dataSource = self;
    tableView.delegate = self;
    self.tableView = tableView;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView*)tableView 
{
	return 1;
}

- (NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section 
{
    return 5;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath 
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Pause"];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Pause"] autorelease];
    }

    long row = (indexPath.row + 1);
    NSString* value = [NSString stringWithFormat:@"%ld", row];
    if ([_dialAction.value isEqualToString:value])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    cell.textLabel.text = [value isEqualToString:@"1"] ? NSLocalizedString(@"1 Second", nil) : [NSLocalizedString(@"{0} Seconds", nil) stringByReplacingOccurrencesOfString:@"{0}" withString:value];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    long row = (indexPath.row + 1);
    _dialAction.value = [NSString stringWithFormat:@"%ld", row];
    
    for (int i = 0; i < [tableView numberOfRowsInSection:0]; i++)
    {
        NSString* value = [NSString stringWithFormat:@"%d", (i + 1)];
        UITableViewCell* cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        cell.accessoryType = [value isEqualToString:_dialAction.value] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
