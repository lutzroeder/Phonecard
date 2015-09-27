
#import "PhoneService.h"

@implementation PhoneService

- (id) initWithServiceProvider:(id<ServiceProvider>)serviceProvider;
{
    self = [super init];
    _serviceProvider = [serviceProvider retain];
    _phoneNumber = @"";
    return self;    
}

- (void) dealloc
{
    [_phoneNumber release];
    _phoneNumber = nil;
    [_serviceProvider release];
    _serviceProvider = nil;
    [super dealloc];
}

+ (NSString*) getPauseString:(NSString*)length
{
    NSString* version = [[UIDevice currentDevice] systemVersion];
    BOOL useComma = [version hasPrefix:@"5."] || [version hasPrefix:@"6."] || [version hasPrefix:@"7."] || [version hasPrefix:@"8."];
    
    int count;
    if (![[NSScanner scannerWithString:length] scanInt:&count])
    {
        return useComma ? @",," : @"pp";
    }
    
    NSString* text = @"";
    for (int i = 0; i < count; i++)
    {
        text = [text stringByAppendingString:useComma ? @"," : @"p"];
    }
    return text;
}

+ (NSString*) applyCard:(Card*)card phoneNumber:(NSString*)number;
{
    NSString* accessNumber = @"";
    
    for (int i = 0; i < card.dialActions.count; i++)
    {
        DialAction* action = (DialAction*) [card.dialActions objectAtIndex:i];
        if ([@"access" isEqualToString:action.name])
        {
            accessNumber = [accessNumber stringByAppendingString:action.value];
        }
        else if ([@"pin" isEqualToString:action.name])
        {
            accessNumber = [accessNumber stringByAppendingString:action.value];                    
        }
        else if ([@"pause" isEqualToString:action.name])
        {
            accessNumber = [accessNumber stringByAppendingString:[self getPauseString:action.value]];
        }
        else if ([@"dial" isEqualToString:action.name])
        {
            accessNumber = [accessNumber stringByAppendingString:action.value];
        }
        else if ([@"contact" isEqualToString:action.name])
        {
            number = [number stringByReplacingOccurrencesOfString:@" " withString:@""];
            NSArray* parts = [action.value componentsSeparatedByString:@","];
            
            // Remove country code
            if ((parts.count > 2) && ([((NSString*)[parts objectAtIndex:2]) length] != 0))
            {
                NSString* code = [@"+" stringByAppendingString:(NSString*)[parts objectAtIndex:2]];					
                if ([[number substringToIndex:code.length] isEqualToString:code])
                {
                    number = [number substringFromIndex:code.length];
                }
            }
            
            // Replace '+' with ...
            if ((parts.count > 0) && (number.length > 0) && [[number substringToIndex:1] isEqualToString:@"+"])
            {
                // Skip replacement
                if ((parts.count < 2) || ([((NSString*)[parts objectAtIndex:1]) length] == 0) || ![number hasPrefix:[@"+" stringByAppendingString:[parts objectAtIndex:1]]])
                {
                    NSString* skipReplacement = (NSString*) [parts objectAtIndex:0];
                    number = [skipReplacement stringByAppendingString:[number stringByReplacingOccurrencesOfString:@"+" withString:@""]];
                }
            }
            accessNumber = [accessNumber stringByAppendingString:number];
        }
    }
    
    return accessNumber;
}

+ (NSString*) applyUrl:(NSString*)number;
{
    return [@"tel:" stringByAppendingString:[PhoneService formatPhoneNumber:[number stringByReplacingOccurrencesOfString:@"+" withString:@""]]];
}

+ (BOOL) hasAccessNumber:(Card*)card;
{
    for (int i = 0; i < card.dialActions.count; i++)
    {
        DialAction* action = (DialAction*) [card.dialActions objectAtIndex:i];
        if (([action.name isEqualToString:@"access"]) && (action.value != nil) && (action.value.length > 0))
        {
            return YES;
        }
    }
    return NO;
}

+ (NSString*) formatPhoneNumber:(NSString*)number
{
    number = [number stringByReplacingOccurrencesOfString:@"(" withString:@""];
    number = [number stringByReplacingOccurrencesOfString:@")" withString:@""];
    number = [number stringByReplacingOccurrencesOfString:@"-" withString:@""];
    number = [number stringByReplacingOccurrencesOfString:@" " withString:@""];
    number = [number stringByReplacingOccurrencesOfString:@"\xc2\xa0" withString:@""];
    return number;
}

- (void) invokeCall:(NSString*)number
{
    Recent* recent = [[Recent alloc] init];
    recent.phoneNumber = _phoneNumber;
    recent.dateTime = [[[NSDate alloc] init] autorelease];
    
    StorageService* storageService = [_serviceProvider serviceWithName:@"StorageService"];
    [[storageService mutableArrayValueForKey:@"recents"] insertObject:recent atIndex:0];
    [storageService save];
 
    NSURL* url = [NSURL URLWithString:number];
    UIApplication* application = [UIApplication sharedApplication];
    if ([application canOpenURL:url])
    {
        [application openURL:url];
    }
    else
    {
        UIAlertView* alertView = [[[UIAlertView alloc] init] autorelease];
        alertView.tag = 3;
        alertView.delegate = self;
        alertView.message = [NSLocalizedString(@"Calling '{0}' is not supported on this device.", nil) stringByReplacingOccurrencesOfString:@"{0}" withString:number];
        [alertView addButtonWithTitle:NSLocalizedString(@"OK", nil)];
        [alertView show];
    }

    [recent release];
}

- (void) call:(NSString*)phoneNumber
{
    [_phoneNumber release];
    _phoneNumber = [phoneNumber retain];
    
    StorageService* storageService = [_serviceProvider serviceWithName:@"StorageService"];
    Card* card = storageService.activeCard;
    if ((card == nil) || (card.dialActions.count == 0))
    {
        UIAlertView* cardView = [[[UIAlertView alloc] init] autorelease];
        cardView.tag = 1;
        cardView.delegate = self;
        cardView.message = NSLocalizedString(@"Call without using a calling card?", nil);
        [cardView addButtonWithTitle:NSLocalizedString(@"No", nil)];
        [cardView addButtonWithTitle:NSLocalizedString(@"Yes", nil)];
        [cardView show];
        return;
    }
    
    NSString* number = [PhoneService applyCard:card phoneNumber:_phoneNumber];
    number = [PhoneService applyUrl:number];
    
    if (![PhoneService hasAccessNumber:card])
    {
        UIAlertView* accessView = [[UIAlertView alloc] init];
        [accessView setTag:2];
        [accessView setDelegate:[self retain]];
        [accessView addButtonWithTitle:NSLocalizedString(@"No", nil)];
        [accessView addButtonWithTitle:NSLocalizedString(@"Yes", nil)];
        [accessView setMessage:[NSLocalizedString(@"Call '{0}' without a calling card access number?", nil) stringByReplacingOccurrencesOfString:@"{0}" withString:number]];
        [accessView show];
        [accessView release];
        return;
    }
    
    [self invokeCall:number];
}

- (void) alertView:(UIAlertView*)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex;
{
    if ((alertView.tag == 1) && (buttonIndex == 1))
    {
        NSString* number = [PhoneService formatPhoneNumber:_phoneNumber];
        number = [PhoneService applyUrl:number];
        [self invokeCall:number];
    }
    else if ((alertView.tag == 2) && (buttonIndex == 1))
    {
        StorageService* storageService = [_serviceProvider serviceWithName:@"StorageService"];
        NSString* number = [PhoneService applyCard:storageService.activeCard phoneNumber:_phoneNumber];
        number = [PhoneService applyUrl:number];
        [self invokeCall:number];
    }
}

@end
