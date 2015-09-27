
#import "TextController.h"

@implementation TextController

- (id) initWithValue:(NSString*)value label:(NSString*)label description:(NSString*)description keyboardType:(UIKeyboardType)keyboardType maxLength:(NSInteger)maxLength target:(id)target action:(SEL)selector
{
    self = [super init];

    _value = [value retain];
    _keyboardType = keyboardType;
    _maxLength = maxLength;
    _target = [target retain];
    _selector = selector;
    
    self.title = [NSLocalizedString(@"Edit {0}", nil) stringByReplacingOccurrencesOfString:@"{0}" withString:label];
    
    UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelClick:)];
    UIBarButtonItem* saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveClick:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    self.navigationItem.rightBarButtonItem = saveButton;
    [cancelButton release];
    [saveButton release];
    
    UIView* view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)] autorelease];
    if ((description != nil) && ([description length] > 0))
    {
        UILabel* headerLabel = [[[UILabel alloc] initWithFrame:CGRectMake(20, 10, 280, 50)] autorelease];
        headerLabel.text = description;
        headerLabel.font = [UIFont systemFontOfSize:[UIFont labelFontSize]];
        headerLabel.textColor = [UIColor colorWithRed:87.0f/255.0f green:108.0f/255.0f blue:137.0f/255.0f alpha:1];
        headerLabel.shadowColor = [UIColor colorWithWhite:0.9 alpha:1];
        headerLabel.shadowOffset = CGSizeMake(0, 1);
        headerLabel.backgroundColor = [UIColor clearColor];
        headerLabel.textAlignment = NSTextAlignmentCenter;
        headerLabel.lineBreakMode = NSLineBreakByWordWrapping;
        headerLabel.numberOfLines = 2;
        headerLabel.opaque = YES;
        [view addSubview:headerLabel];
    }
    
    UITableView* tableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped] autorelease];
    // tableView.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Background.png"]] autorelease];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.tableHeaderView = view;
    self.tableView = tableView;

    return self;
}

- (void) dealloc
{
    [_value release];
    _value = nil;
    [_target release];
    _target = nil;
    [super dealloc];
}

- (void) cancelClick:(id)sender
{
    UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    UITextField* field = (UITextField*) [cell.contentView viewWithTag:1];
    [field resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) saveClick:(id)sender
{
    [self save];
}

- (void) save
{
    UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    UITextField* field = (UITextField*) [cell.contentView viewWithTag:1];
    [field resignFirstResponder];
    [self commit:field.text];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) commit:(NSString*)value
{
    if (_target != nil)
    {
        [_target performSelector:_selector withObject:value];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView 
{
	return 1;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section 
{
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath 
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Text"];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] init] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UITextField* field = [[UITextField alloc] init];
        field.tag = 1;
        field.font = [UIFont systemFontOfSize:28];
        field.textColor = [UIColor colorWithRed:50/255 green:79/255 blue:133/255 alpha:1];
        field.textAlignment = NSTextAlignmentCenter;
        field.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        field.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        field.autocorrectionType = UITextAutocorrectionTypeNo;
        field.autocapitalizationType = UITextAutocapitalizationTypeNone;
        field.frame = CGRectMake(cell.frame.origin.x + 10, cell.frame.origin.y, cell.frame.size.width - 38, cell.frame.size.height);
        field.keyboardType = _keyboardType;
        field.delegate = self;
        [field addTarget:self action:@selector(editingChanged:) forControlEvents:UIControlEventEditingChanged]; 
        [cell.contentView addSubview:field];
        [field release];
    }
    
    NSString* text = [_value copy];
    UITextField* textField = (UITextField*) [cell.contentView viewWithTag:1];
    [textField setText:text];
    [textField becomeFirstResponder];
    [text release];
    return cell;
}

- (void)editingChanged:(id)sender
{
    UITextField* textField = (UITextField*) sender;

    if ([textField.text length] > _maxLength)
    {
        textField.text = _value;
    }
    else
    {
        [_value release];
        _value = [textField.text copy];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self save];
    return YES;
}

@end
