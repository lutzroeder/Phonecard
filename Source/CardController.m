
#import "CardController.h"

@implementation CardController

- (id) initWithServiceProvider:(id<ServiceProvider>)serviceProvider card:(Card*)card editMode:(BOOL)editMode cardsController:(CardsController*)cardsController;
{
    self = [super init];
    _serviceProvider = [serviceProvider retain];
    _card = [card retain];
    _editMode = editMode;
    _cardsController = [cardsController retain];
    return self;
}

- (void) dealloc
{
    [_serviceProvider release];
    _serviceProvider = nil;

    [_card release];
    _card = nil;
    [_cardsController release];
    _cardsController = nil;

    [_editButton release];
    _editButton = nil;
    [_doneButton release];
    _doneButton = nil;
    [_deleteButtonView release];
    _deleteButtonView = nil;

    [super dealloc];
}

- (BOOL) modernStyle
{
    return !([[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] intValue] < 7);
}

- (void) viewDidLoad
{
    [super viewDidLoad];

    self.title = !_editMode ? NSLocalizedString(@"New Card", nil) : NSLocalizedString(@"Edit Card", nil);
    _editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editClick:)];
    _doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:(_editMode ? UIBarButtonSystemItemDone : UIBarButtonSystemItemSave) target:self action:@selector(doneClick:)];

    if (!self.modernStyle)
    {
        UIButton* deleteButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        deleteButton.frame = CGRectMake(10, 5, 300, 44);
        [deleteButton setTitle:NSLocalizedString(@"Delete Card", nil) forState:UIControlStateNormal];
        [deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [deleteButton.titleLabel setShadowOffset:CGSizeMake(0, -1)];
        [deleteButton.titleLabel setFont:[UIFont boldSystemFontOfSize:[UIFont buttonFontSize] + 2]];
        [deleteButton setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.3] forState:UIControlStateNormal];
        [deleteButton setBackgroundImage:[[UIImage imageNamed:@"DeleteButton"] stretchableImageWithLeftCapWidth:26 topCapHeight:22] forState:UIControlStateNormal];
        [deleteButton setBackgroundImage:[[UIImage imageNamed:@"DeleteButton_"] stretchableImageWithLeftCapWidth:26 topCapHeight:22] forState:UIControlStateHighlighted];
        [deleteButton addTarget:self action:@selector(deleteClick:) forControlEvents:UIControlEventTouchUpInside];
        _deleteButtonView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 64)];
        [_deleteButtonView addSubview:deleteButton];
    }
        
    if (_editMode)
    {
        self.navigationItem.rightBarButtonItem = _editButton;
    }

    if ([[_card dialActions] count] == 0)
    {
        DialAction* action;
        action = [[DialAction alloc] initWithName:@"access" value:@""];
        [[_card dialActions] addObject:action];
        [action release];
        action = [[DialAction alloc] initWithName:@"contact" value:@""];
        [[_card dialActions] addObject:action];
        [action release];
    }

    UITableView* tableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped] autorelease];
    tableView.allowsSelection = NO;
    tableView.allowsSelectionDuringEditing = YES;
    tableView.dataSource = self;
    tableView.delegate = self;
    self.tableView = tableView;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.editing)
    {
        [self.tableView reloadData];
    }
    else if (!_editMode)
    {
        [self.tableView reloadData];
        [self setEditing:YES animated:NO];
    }
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if (!_editMode)
    {
        if (!self.editing)
        {
            [self setEditing:YES animated:NO];
        }
    }
}

- (void) editClick:(id)sender
{
    if (!self.editing)
    {
        [self setEditing:YES animated:YES];
    }
}

- (void) doneClick:(id)sender
{
    if (self.editing)
    {
        [self setEditing:NO animated:YES];
    }
    if (!_editMode)
    {
        [_cardsController addCard:_card];
        [_cardsController.navigationController popViewControllerAnimated:YES];
    }
    
    StorageService* storageService = [_serviceProvider serviceWithName:@"StorageService"];
    [storageService save];
}

- (void) deleteClick:(id)sender
{
    UIActionSheet* actionSheet = [[UIActionSheet alloc] init];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    actionSheet.destructiveButtonIndex = 0;
    actionSheet.cancelButtonIndex = 1;
    actionSheet.delegate = self;
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Delete Card", nil`)];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
    [actionSheet showInView:self.navigationController.parentViewController.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    if (buttonIndex == 0)
    {
        [_cardsController removeCard:_card];
        [self.navigationController popViewControllerAnimated:YES];
    }			
}

- (void) setEditing:(BOOL)editing animated:(BOOL)animated
{
    [self.tableView beginUpdates];
    [self.tableView setEditing:editing animated:animated];
    if (editing)
    {
        if (_editMode)
        {
            [self.navigationItem setHidesBackButton:YES animated:YES];

            if (!self.modernStyle)
            {
                self.tableView.tableFooterView = _deleteButtonView;
            }
            else
            {
                [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:2], nil] withRowAnimation:UITableViewRowAnimationTop];
            }
        }
        else
        {
            if (!self.modernStyle)
            {
                UIView* view = [[UIView alloc] init];
                self.tableView.tableFooterView = view;
                [view release];
            }
        }

        self.navigationItem.rightBarButtonItem = _doneButton;
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:[_card.dialActions count] inSection:1], [NSIndexPath indexPathForRow:([_card.dialActions count] + 1) inSection:1], nil] withRowAnimation:UITableViewRowAnimationTop];
    }
    else
    {
        if (_editMode)
        {
            [self.navigationItem setHidesBackButton:NO animated:YES];
            self.navigationItem.rightBarButtonItem = _editButton;
        }

        if (!self.modernStyle)
        {
            UIView* view = [[UIView alloc] init];
            self.tableView.tableFooterView = view;
            [view release];
        }
        else if (_editMode)
        {
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:2], nil] withRowAnimation:UITableViewRowAnimationTop];
        }

        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:([_card.dialActions count] + 1) inSection:1], [NSIndexPath indexPathForRow:[_card.dialActions count] inSection:1], nil] withRowAnimation:UITableViewRowAnimationTop];
    }

    [self.tableView endUpdates];
    [super setEditing:editing animated:animated];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView 
{
	return 3;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section 
{
    if (section == 0)
    {
        return 1;
    }
    else if (section == 1)
    {
        return tableView.editing ? ([_card.dialActions count] + 2) : [_card.dialActions count];
    }
    else if (section == 2)
    {
        return (tableView.editing && _editMode && self.modernStyle) ? 1 : 0;
    }
    return 0;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)
    {
        if (indexPath.row >= [_card.dialActions count]) 
        {
            return UITableViewCellEditingStyleInsert;
        }

        DialAction* dialAction = [_card.dialActions objectAtIndex:indexPath.row];
        if ([@"pause" isEqualToString:dialAction.name] || [@"pin" isEqualToString:dialAction.name] || [@"dial" isEqualToString:dialAction.name])
        {
            return UITableViewCellEditingStyleDelete;
        }
    }
    
    return UITableViewCellEditingStyleNone;    
}

- (BOOL) tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath 
{
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CardName"];
            if (cell == nil)
            {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"CardName"] autorelease];
            }
            
            cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = NSLocalizedString(@"Card Name", nil);

            if ([NSString isNullOrEmpty:_card.name])
            {
                cell.detailTextLabel.text = NSLocalizedString(@"My Calling Card", nil);
                cell.detailTextLabel.textColor = [UIColor lightGrayColor];
            }
            else
            {
                cell.detailTextLabel.text = _card.name;
                cell.detailTextLabel.textColor = [UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1];
            }
            return cell;
        }
    }
    else if (indexPath.section == 1)
    {
        if (indexPath.row < [_card.dialActions count])
        {
            UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"DialAction"];
            if (cell == nil)
            {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"DialAction"] autorelease];
            }
            
            DialAction* action = (DialAction*) [_card.dialActions objectAtIndex:indexPath.row];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = action.label;
            
            if ([@"access" isEqualToString:action.name])
            {
                [self tableViewCell:cell setDetailText:action.value withDefaultText:NSLocalizedString(@"1 (800) XXX-XXXX", nil)];
            }
            else if ([@"pause" isEqualToString:action.name])
            {
                if ([NSString isNullOrEmpty:action.value])
                {
                    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
                    cell.detailTextLabel.text = @"?";
                }
                else
                {
                    cell.detailTextLabel.textColor = [UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1];
                    cell.detailTextLabel.text = [@"1" isEqualToString:action.value] ? NSLocalizedString(@"1 Second", nil) : [NSLocalizedString(@"{0} Seconds", nil) stringByReplacingOccurrencesOfString:@"{0}" withString:action.value];
                }
            }
            else if ([@"pin" isEqualToString:action.name])
            {
                [self tableViewCell:cell setDetailText:action.value withDefaultText:NSLocalizedString(@"None", nil)];
            }						
            else if ([@"dial" isEqualToString:action.name])
            {
                [self tableViewCell:cell setDetailText:action.value withDefaultText:@"XXX"];
            }
            else if ([@"contact" isEqualToString:action.name])
            {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.detailTextLabel.text = @"";
            }
            return cell;
        }
        else
        {
            UITableViewCell* cell = [[[UITableViewCell alloc] init] autorelease];
            switch (indexPath.row - [_card.dialActions count])
            {
                case 0: cell.textLabel.text = NSLocalizedString(@"Add Pause", nil); break;
                case 1: cell.textLabel.text = NSLocalizedString(@"Add Custom Number", nil); break;
            }					
            return cell;
        }
    }
    else if (indexPath.section == 2)
    {
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Delete"];
        if (cell == nil)
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Delete"] autorelease];

        }
        cell.textLabel.textColor = [UIColor redColor];
        cell.textLabel.text = NSLocalizedString(@"Delete Card", nil);
        return cell;
    }
    return nil;
}

- (void) tableViewCell:(UITableViewCell*)cell setDetailText:(NSString*)value withDefaultText:(NSString*)defaultValue
{
    if ([NSString isNullOrEmpty:value])
    {
        cell.detailTextLabel.textColor = [UIColor lightGrayColor];
        cell.detailTextLabel.text = defaultValue;
    }
    else
    {
        cell.detailTextLabel.textColor = [UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1];
        cell.detailTextLabel.text = value;
    }
}

- (void) updateCardName:(NSString*)value
{
    _card.name = value;
    if (_editMode)
    {
        StorageService* storageService = [_serviceProvider serviceWithName:@"StorageService"];
        [storageService save];
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        TextController* textController = [[TextController alloc] initWithValue:_card.name label:NSLocalizedString(@"Card Name", nil) description:@"" keyboardType:UIKeyboardTypeDefault maxLength:16 target:self action:@selector(updateCardName:)];
        [self.navigationController pushViewController:textController animated:YES];
        [textController release];
    }
    
    if (indexPath.section == 1)
    {
        if (indexPath.row < [_card.dialActions count])
        {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            DialAction* action = (DialAction*) [_card.dialActions objectAtIndex:indexPath.row];
            
            if ([@"pause" isEqualToString:action.name])
            {
                PauseController* pauseController = [[PauseController alloc] initWithAction:action editMode:_editMode];
                [self.navigationController pushViewController:pauseController animated:YES];
                [pauseController release];
            }
            else if ([@"contact" isEqualToString:action.name])
            {
                DialContactController* dialContactController = [[DialContactController alloc] initWithAction:action editMode:_editMode];
                [self.navigationController pushViewController:dialContactController animated:YES];
                [dialContactController release];
            }
            else if ([@"access" isEqualToString:action.name])
            {
                NumberController* numberController = [[NumberController alloc] initWithAction:action description:NSLocalizedString(@"Enter the card access number.", nil) keyboardType:UIKeyboardTypeNumberPad editMode:_editMode];
                [self.navigationController pushViewController:numberController animated:YES];
                [numberController release];
            }
            else if ([@"pin" isEqualToString:action.name])
            {
                NumberController* numberController = [[NumberController alloc] initWithAction:action description:NSLocalizedString(@"Enter the card PIN number.", nil) keyboardType:UIKeyboardTypeNumberPad editMode:_editMode];
                [self.navigationController pushViewController:numberController animated:YES];
                [numberController release];
            }
            else if ([@"dial" isEqualToString:action.name])
            {
                NumberController* numberController = [[NumberController alloc] initWithAction:action description:@"" keyboardType:UIKeyboardTypePhonePad editMode:_editMode];
                [self.navigationController pushViewController:numberController animated:YES];
                [numberController release];
            }
        }
        else
        {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [self tableView:tableView commitEditingStyle:UITableViewCellEditingStyleInsert forRowAtIndexPath:indexPath];
        }
    }
    
    if (indexPath.section == 2)
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self deleteClick:tableView];
    }
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return (section == 1) ? NSLocalizedString(@"Dial Sequence", nil) : @"";
}

- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ((indexPath.section == 0) || (indexPath.section == 1));
}

- (void) tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    if (sourceIndexPath.section == 1)
    {
        DialAction* action = [[_card.dialActions objectAtIndex:sourceIndexPath.row] retain];
        [_card.dialActions removeObjectAtIndex:sourceIndexPath.row];
        [_card.dialActions insertObject:action atIndex:destinationIndexPath.row];
        [action release];
        if (_editMode)
        {
            StorageService* storageService = [_serviceProvider serviceWithName:@"StorageService"];
            [storageService save];
        }
    }
}

- (BOOL) tableView:(UITableView*)tableView canMoveRowAtIndexPath:(NSIndexPath*)indexPath
{
    if ((indexPath.section == 1) && (indexPath.row < [_card.dialActions count]))
    {
        DialAction* action = (DialAction*) [_card.dialActions objectAtIndex:indexPath.row];
        return (![@"access" isEqualToString:action.name]) && (![@"contact" isEqualToString:action.name]);
    }
    return NO;
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (editingStyle) 
    {
        case UITableViewCellEditingStyleInsert:
            if (indexPath.row == [_card.dialActions count])
            {
                DialAction* action = [[DialAction alloc] initWithName:@"pause" value:@"2"];
                [_card.dialActions addObject:action];
                [action release];
                
                [tableView insertRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:([_card.dialActions count] - 1) inSection:1], nil] withRowAnimation:UITableViewRowAnimationTop];

                if (_editMode)
                {
                    StorageService* storageService = [_serviceProvider serviceWithName:@"StorageService"];
                    [storageService save];
                }
            }
            
            if (indexPath.row == [_card.dialActions count] + 1)
            {
                DialAction* action = [[DialAction alloc] initWithName:@"dial" value:@""];
                [_card.dialActions addObject:action];
                [action release];
                
                [tableView insertRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:([_card.dialActions count] - 1) inSection:1], nil] withRowAnimation:UITableViewRowAnimationTop];

                if (_editMode)
                {
                    StorageService* storageService = [_serviceProvider serviceWithName:@"StorageService"];
                    [storageService save];
                }
            }
            break;

        case UITableViewCellEditingStyleDelete:
            [_card.dialActions removeObjectAtIndex:indexPath.row];
            if (_editMode)
            {
                StorageService* storageService = [_serviceProvider serviceWithName:@"StorageService"];
                [storageService save];
            }
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case UITableViewCellEditingStyleNone:
            break;
    }
}

- (NSIndexPath*) tableView:(UITableView*)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath*)sourceIndexPath toProposedIndexPath:(NSIndexPath*)proposedDestinationIndexPath
{
    if (sourceIndexPath.section != proposedDestinationIndexPath.section)
    {
        return sourceIndexPath;
    }
    if (proposedDestinationIndexPath.row >= [_card.dialActions count])
    {
        return sourceIndexPath;
    }
    return proposedDestinationIndexPath;
}

@end
