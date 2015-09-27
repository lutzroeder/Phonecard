
#import "KeyPadController.h"

@implementation KeyPadController

- (id) initWithServiceProvider:(id<ServiceProvider>)serviceProvider
{
    self = [super init];
    
    _serviceProvider = [serviceProvider retain];
    
    self.tabBarItem = [[[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Keypad", nil) image:[UIImage imageNamed:@"KeyPad"] tag:4] autorelease];
    
    return self;
}

- (void) dealloc
{
    [_serviceProvider release];
    _serviceProvider = nil;
    
    if (_soundTable != nil)
    {
        [_soundTable release];
        _soundTable = nil;
    }
    
    [_backButton release];
    
    if (_phoneNumberLabel != nil)
    {
        [_phoneNumberLabel removeObserver:self forKeyPath:@"text"];
        [_phoneNumberLabel release];
        _phoneNumberLabel = nil;
    }
    
    [self stopTimer];
    [super dealloc];
}

- (void) stopTimer
{
    if (_timer != nil)
    {
        [_timer invalidate];
        [_timer release];
        _timer = nil;
    }
}

- (void) back
{
    if ([_phoneNumberLabel.text length] > 0)
    {
        _phoneNumberLabel.text = [_phoneNumberLabel.text substringToIndex:([_phoneNumberLabel.text length] - 1)];
    }

    [_backButton setHidden:([_phoneNumberLabel.text length] == 0)];
}

- (void) backTimer:(id)sender
{
    [self stopTimer];
    [self back];
    _timer = [[NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(backTimer:) userInfo:nil repeats:NO] retain];
}

- (void) backTouchDown:(id)sender
{
    [self stopTimer];
    _timer = [[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(backTimer:) userInfo:nil repeats:NO] retain];
}

- (void) backTouchUpOutside:(id)sender
{
    [self stopTimer];
}

- (void) backTouchUpInside:(id)sender
{
    [self stopTimer];
    [self back];
}

- (void) addSoundWithName:(NSString*)name soundName:(NSString*)resource
{
    SystemSoundID soundId;
    NSURL* url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:resource ofType:@"aif"]];
    AudioServicesCreateSystemSoundID((CFURLRef) url, &soundId);
    [_soundTable setObject:[NSNumber numberWithInt:soundId] forKey:name];
}

- (void) numberClick:(id)sender
{
    UIButton* button = (UIButton*)sender;
    NSString* name = [_buttonTable objectAtIndex:button.tag];
    
    _phoneNumberLabel.text = [_phoneNumberLabel.text stringByAppendingString:name];

    NSNumber* number = (NSNumber*) ([_soundTable objectForKey:name]);
    if (number != nil)
    {
        SystemSoundID soundId = (SystemSoundID) [number intValue];
        AudioServicesPlaySystemSound(soundId);
    }
}

- (void) updateBackButton
{
    [_backButton setHidden:([_phoneNumberLabel.text length] == 0)];
}

- (void) callClick:(id)sender
{
    PhoneService* phoneService = [_serviceProvider serviceWithName:@"PhoneService"];
    [phoneService call:_phoneNumberLabel.text];
}

- (UIButton*) addButtonWithName:(NSString*)name title:(NSString*)title position:(CGPoint)point size:(CGFloat)size
{
    KeyPadButton* button = [[[KeyPadButton alloc] init] autorelease];
    button.tag = [_buttonTable count];
    [_buttonTable addObject:name];

    button.frame = CGRectMake(point.x - (size / 2), point.y - (size / 2), size, size);
    
    button.layer.cornerRadius = size / 2;
    button.layer.borderColor = [UIColor colorWithWhite:0.271 alpha:1].CGColor;
    button.layer.borderWidth = 1.5f;

    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    UIFont* titleFont = [UIFont fontWithName:@"HelveticaNeue-Thin" size:36];
    UIFont* subtitleFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:9];
    
    NSMutableAttributedString* titleText = [[NSMutableAttributedString alloc] initWithString:title];
    [titleText addAttributes:[NSDictionary dictionaryWithObject:titleFont forKey:NSFontAttributeName] range:NSMakeRange(0, 1)];

    if ([title length] > 1)
    {
        [[button titleLabel] setNumberOfLines:2];
        [titleText addAttributes:[NSDictionary dictionaryWithObject:subtitleFont forKey:NSFontAttributeName] range:NSMakeRange(1, [title length] - 1)];
    }

    [button setAttributedTitle:titleText forState:UIControlStateNormal];
    [titleText release];

    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [button setBackgroundColor:[UIColor clearColor] forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor colorWithWhite:0.271 alpha:1] forState:UIControlStateHighlighted];
    
    [self.view addSubview:button];
    
    return button;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ((_phoneNumberLabel == object) && ([@"text" isEqualToString:keyPath]))
    {
        [self updateBackButton];
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_phoneNumberLabel == nil)
    {
        _buttonTable = [[NSMutableArray alloc] init];
        
        _soundTable = [[NSMutableDictionary alloc] init];
        [self addSoundWithName:@"+" soundName:@"Plus"];
        [self addSoundWithName:@"#" soundName:@"Route"];
        for (int i = 0; i < 10; i++)
        {
            NSString* name = [NSString stringWithFormat:@"%d", i];
            [self addSoundWithName:name soundName:name];
        }
        
        self.view = [[UIView alloc] init];
        self.view.backgroundColor = [UIColor colorWithWhite:0.95686 alpha:1.0];
        
        CGRect rect = [[UIScreen mainScreen] bounds];
        BOOL tallScreen = (rect.size.height >= 568);

        CGRect phoneNumberLabelRect = CGRectMake(45, 0, 230, 100);
        
        _phoneNumberLabel = [[KeyPadLabel alloc] init];
        _phoneNumberLabel.frame = phoneNumberLabelRect;
        _phoneNumberLabel.textAlignment = NSTextAlignmentCenter;
        _phoneNumberLabel.textColor = [UIColor blackColor];
        _phoneNumberLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:36];
        _phoneNumberLabel.backgroundColor = [UIColor clearColor];
        _phoneNumberLabel.text = @"";
        _phoneNumberLabel.adjustsFontSizeToFitWidth = YES;
        [_phoneNumberLabel addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:NULL];

        CGFloat left = tallScreen ? 65 : 71.5;
        CGFloat middle = 320 / 2;
        CGFloat right = tallScreen ? 255 : 247.5;
        CGFloat size = tallScreen ? 75 : 68;
        CGFloat top = tallScreen ? 137 : 121;
        CGFloat height = tallScreen ? 86 : 74;
        CGRect callFrame = tallScreen ? CGRectMake(16, 442, 288, 66) : CGRectMake(36, 384, 248, 44);
        
        [[self addButtonWithName:@"1" title:@"1\n   " position:CGPointMake(left, top) size:size] addTarget:self action:@selector(numberClick:) forControlEvents:UIControlEventTouchDown];
        [[self addButtonWithName:@"2" title:@"2\nA B C" position:CGPointMake(middle, top) size:size] addTarget:self action:@selector(numberClick:) forControlEvents:UIControlEventTouchDown];
        [[self addButtonWithName:@"3" title:@"3\nD E F" position:CGPointMake(right, top) size:size] addTarget:self action:@selector(numberClick:) forControlEvents:UIControlEventTouchDown];
        
        top = top + height;
        
        [[self addButtonWithName:@"4" title:@"4\nG H I" position:CGPointMake(left, top) size:size] addTarget:self action:@selector(numberClick:) forControlEvents:UIControlEventTouchDown];
        [[self addButtonWithName:@"5" title:@"5\nJ K L" position:CGPointMake(middle, top) size:size] addTarget:self action:@selector(numberClick:) forControlEvents:UIControlEventTouchDown];
        [[self addButtonWithName:@"6" title:@"6\nM N O" position:CGPointMake(right, top) size:size] addTarget:self action:@selector(numberClick:) forControlEvents:UIControlEventTouchDown];
        
        top = top + height;
        
        [[self addButtonWithName:@"7" title:@"7\nP Q R S" position:CGPointMake(left, top) size:size] addTarget:self action:@selector(numberClick:) forControlEvents:UIControlEventTouchDown];
        [[self addButtonWithName:@"8" title:@"8\nT U V"  position:CGPointMake(middle, top) size:size] addTarget:self action:@selector(numberClick:) forControlEvents:UIControlEventTouchDown];
        [[self addButtonWithName:@"9" title:@"9\nW X Y Z" position:CGPointMake(right, top) size:size] addTarget:self action:@selector(numberClick:) forControlEvents:UIControlEventTouchDown];
        
        top = top + height;
        
        [[self addButtonWithName:@"+" title:@"+\n "  position:CGPointMake(left,   top) size:size] addTarget:self action:@selector(numberClick:) forControlEvents:UIControlEventTouchDown];
        [[self addButtonWithName:@"0" title:@"0\n " position:CGPointMake(middle, top) size:size] addTarget:self action:@selector(numberClick:) forControlEvents:UIControlEventTouchDown];
        [[self addButtonWithName:@"#" title:@"#\n "  position:CGPointMake(right,  top) size:size] addTarget:self action:@selector(numberClick:) forControlEvents:UIControlEventTouchDown];
        
        KeyPadButton* callButton = [[[KeyPadButton alloc] init] autorelease];
        callButton.frame = callFrame;
        callButton.layer.cornerRadius = 5;
        callButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:28];
        [callButton setTitle:NSLocalizedString(@"Call", nil) forState:UIControlStateNormal];
        [callButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [callButton setBackgroundColor:[UIColor colorWithRed:0.325f green:0.843f blue:0.412f alpha:1] forState:UIControlStateNormal];
        [callButton setBackgroundColor:[UIColor colorWithRed:0.169f green:0.447f blue:0.220f alpha:1] forState:UIControlStateHighlighted];
        [self.view addSubview:callButton];
        [callButton addTarget:self action:@selector(callClick:) forControlEvents:(UIControlEventTouchUpInside)];
        
        
        _backButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [_backButton setBackgroundImage:[UIImage imageNamed:@"BackButton"] forState:UIControlStateNormal];
        [_backButton setBackgroundImage:[UIImage imageNamed:@"BackButton"] forState:UIControlStateHighlighted];
        [_backButton setFrame:CGRectMake(275, 41 - 8, 40, 32)];
        [_backButton addTarget:self action:@selector(backTouchDown:) forControlEvents:UIControlEventTouchDown];
        [_backButton addTarget:self action:@selector(backTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [_backButton addTarget:self action:@selector(backTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
        [_backButton setHidden:YES];
        [self.view addSubview:_backButton];

        [self.view addSubview:_phoneNumberLabel];
    }
}

@end
