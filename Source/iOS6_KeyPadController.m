
#import "iOS6_KeyPadController.h"

@implementation iOS6_KeyPadController

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

- (void) numberClick:(id)sender
{
    UIButton* button = (UIButton*)sender;
    NSString* name = [_buttonTable objectAtIndex:button.tag];
    if (![name isEqualToString:@"#"])
    {
        _phoneNumberLabel.text = [_phoneNumberLabel.text stringByAppendingString:name];
        NSNumber* number = (NSNumber*) ([_soundTable objectForKey:name]);
        if (number != nil)
        {
            SystemSoundID soundId = (SystemSoundID) [number intValue];
            AudioServicesPlaySystemSound(soundId);
        }
    }
}

- (void) callClick:(id)sender
{
    PhoneService* phoneService = [_serviceProvider serviceWithName:@"PhoneService"];
    [phoneService call:_phoneNumberLabel.text];
}

- (void) back
{
    if ([_phoneNumberLabel.text length] > 0)
    {
        _phoneNumberLabel.text = [_phoneNumberLabel.text substringToIndex:([_phoneNumberLabel.text length] - 1)];
    }
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

- (void) addImageWithName:(NSString*)name frame:(CGRect)frame
{
    UIImage* image = [[UIImage imageNamed:name] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
    [imageView setFrame:frame];
    [self.view addSubview:imageView];
    [imageView release];
}

- (void) drawImage:(UIImage*)image fromRect:(CGRect)fromRect toRect:(CGRect)toRect
{
    UIGraphicsBeginImageContextWithOptions(fromRect.size, NO, [UIScreen mainScreen].scale);
    [image drawAtPoint:CGPointMake(-fromRect.origin.x, -fromRect.origin.y)];
    UIImage* result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [result drawInRect:toRect];
}

- (UIImage*) stretchImage:(UIImage*)image size:(CGSize)size
{
    CGRect rect = [[UIScreen mainScreen] bounds];
    BOOL tallScreen = (rect.size.height >= 568);
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    CGFloat to = 0;
    CGFloat from = 0;
    CGFloat stretch = tallScreen ? ((size.height - image.size.height) / 2) : 0;    
    CGFloat height = 9;
    [self drawImage:image fromRect:CGRectMake(0, from, image.size.width, height) toRect:CGRectMake(0, to, image.size.width, height)];
    from += height; to += height; height = 5;
    [self drawImage:image fromRect:CGRectMake(0, from, image.size.width, height) toRect:CGRectMake(0, to, image.size.width, height + stretch)];
    from += height; to = to + height + stretch; height = 40;
    [self drawImage:image fromRect:CGRectMake(0, from, image.size.width, height) toRect:CGRectMake(0, to, image.size.width, height)];
    from = from + height; to = to + height; height = 5;
    [self drawImage:image fromRect:CGRectMake(0, from, image.size.width, height) toRect:CGRectMake(0, to, image.size.width, height + stretch)];
    from = from + height; to = to + height+ stretch; height = 9; 
    [self drawImage:image fromRect:CGRectMake(0, from, image.size.width, height) toRect:CGRectMake(0, to, image.size.width, height)];
    UIImage* result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

- (UIButton*) addButtonWithName:(NSString*)name frame:(CGRect)frame
{
    NSString* file = name;
    if ([name isEqualToString:@"+"])
    {
        file = @"Plus";
    }
    else if ([name isEqualToString:@"#"])
    {
        file = @"Route";
    }

    NSString* filePressed = [file stringByAppendingString:@"_"];
    UIImage* image = [self stretchImage:[UIImage imageNamed:file] size:frame.size];
    UIImage* imagePressed = [self stretchImage:[UIImage imageNamed:filePressed] size:frame.size];

    UIButton* button = [[[UIButton alloc] init] autorelease];
    button.tag = [_buttonTable count];
    [_buttonTable addObject:name];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button setBackgroundImage:imagePressed forState:UIControlStateHighlighted];
    [button setFrame:frame];
    [self.view addSubview:button];

    return button;
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
        
        CGRect rect = [[UIScreen mainScreen] bounds];
        BOOL tallScreen = (rect.size.height >= 568);

        CGFloat top = 0;
        CGFloat height = tallScreen ? 112 : 74;

        CGRect phoneNumberLabelRect = CGRectMake(20, 0, 280, height);
        
        [self addImageWithName:@"Number" frame:CGRectMake(0, top, 320, height)];

        top = top + height;

        [self addImageWithName:@"BorderTop" frame:CGRectMake(0, top, 320, 1)];
        
        top = top + 1;
        height = tallScreen ? 77 : 67;
        
        [[self addButtonWithName:@"1" frame:CGRectMake(  0, top, 107, height)] addTarget:self action:@selector(numberClick:) forControlEvents:UIControlEventTouchDown];
        [[self addButtonWithName:@"2" frame:CGRectMake(107, top, 108, height)] addTarget:self action:@selector(numberClick:) forControlEvents:UIControlEventTouchDown];
        [[self addButtonWithName:@"3" frame:CGRectMake(213, top, 107, height)] addTarget:self action:@selector(numberClick:) forControlEvents:UIControlEventTouchDown];
        
        top = top + height;
        
        [[self addButtonWithName:@"4" frame:CGRectMake(  0, top, 107, height)] addTarget:self action:@selector(numberClick:) forControlEvents:UIControlEventTouchDown];
        [[self addButtonWithName:@"5" frame:CGRectMake(107, top, 108, height)] addTarget:self action:@selector(numberClick:) forControlEvents:UIControlEventTouchDown];
        [[self addButtonWithName:@"6" frame:CGRectMake(213, top, 107, height)] addTarget:self action:@selector(numberClick:) forControlEvents:UIControlEventTouchDown];

        top = top + height;

        [[self addButtonWithName:@"7" frame:CGRectMake(  0, top, 107, height)] addTarget:self action:@selector(numberClick:) forControlEvents:UIControlEventTouchDown];
        [[self addButtonWithName:@"8" frame:CGRectMake(107, top, 108, height)] addTarget:self action:@selector(numberClick:) forControlEvents:UIControlEventTouchDown];
        [[self addButtonWithName:@"9" frame:CGRectMake(213, top, 107, height)] addTarget:self action:@selector(numberClick:) forControlEvents:UIControlEventTouchDown];

        top = top + height;
        
        [[self addButtonWithName:@"+" frame:CGRectMake(  0, top, 107, height)] addTarget:self action:@selector(numberClick:) forControlEvents:UIControlEventTouchDown];
        [[self addButtonWithName:@"0" frame:CGRectMake(107, top, 108, height)] addTarget:self action:@selector(numberClick:) forControlEvents:UIControlEventTouchDown];
        [[self addButtonWithName:@"#" frame:CGRectMake(213, top, 107, height)] addTarget:self action:@selector(numberClick:) forControlEvents:UIControlEventTouchDown];
        
        top = top + height;
    
        [self addImageWithName:@"None"  frame:CGRectMake(  0, top, 107, height)];
        [[self addButtonWithName:@"Call" frame:CGRectMake(107, top, 108, height)] addTarget:self action:@selector(callClick:) forControlEvents:UIControlEventTouchUpInside];

         UIButton* backButton = [self addButtonWithName:@"Back" frame:CGRectMake(213, top, 107, height)];
        [backButton addTarget:self action:@selector(backTouchDown:) forControlEvents:UIControlEventTouchDown];
        [backButton addTarget:self action:@selector(backTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [backButton addTarget:self action:@selector(backTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
        
        top = top + height;
        
        [self addImageWithName:@"BorderBottom" frame:CGRectMake(0, top, 320, 1)];
        
        _phoneNumberLabel = [[KeyPadLabel alloc] init];
        _phoneNumberLabel.frame = phoneNumberLabelRect;
        _phoneNumberLabel.textAlignment = UITextAlignmentCenter;
        _phoneNumberLabel.textColor = [UIColor whiteColor];
        _phoneNumberLabel.font = [UIFont systemFontOfSize:40];
        _phoneNumberLabel.backgroundColor = [UIColor clearColor];
        _phoneNumberLabel.text = @"";
        _phoneNumberLabel.adjustsFontSizeToFitWidth = YES;
        [self.view addSubview:_phoneNumberLabel];
    }
}

@end
