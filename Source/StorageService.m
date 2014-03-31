
#import "StorageService.h"

@implementation StorageService

@synthesize favorites;
@synthesize recents;
@synthesize cards;
@synthesize activeCard;

- (id) init
{
    self = [super init];
    self->favorites = [[NSMutableArray alloc] init];
    self->recents = [[NSMutableArray alloc] init];
    self->cards = [[NSMutableArray alloc] init];
    self.activeCard = nil;
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
    
    @try 
    {
        [self.favorites removeAllObjects];
        NSArray* favoritesArray = [defaults objectForKey:@"Favorites"];
        if (favoritesArray != nil)
        {
            for (int i = 0; i < [favoritesArray count]; i++)
            {
                NSDictionary* table = (NSDictionary*) [favoritesArray objectAtIndex:i];
                Favorite* favorite = [[Favorite alloc] init];
                favorite.phoneNumber = ([table objectForKey:@"PhoneNumber"] != nil) ? [table objectForKey:@"PhoneNumber"] : @"";
                favorite.name = ([table objectForKey:@"Name"] != nil) ? [table objectForKey:@"Name"] : @"";
                favorite.name = ([table objectForKey:@"Label"] != nil) ? [table objectForKey:@"Label"] : @"";
                [self.favorites addObject:favorite];
                [favorite release];
            }
        }
    }
    @catch (NSException *exception) 
    {
        [self.favorites removeAllObjects];
    }
    
    
    @try 
    {
        [[self mutableArrayValueForKey:@"recents"] removeAllObjects];
        NSArray* recentsArray = [defaults objectForKey:@"Recents"];
        if (recentsArray != nil)
        {
            for (int i = 0; i < [recentsArray count]; i++)
            {
                NSDictionary* table = (NSDictionary*) [recentsArray objectAtIndex:i];
                Recent* recent = [[Recent alloc] init];
                recent.phoneNumber = ([table objectForKey:@"PhoneNumber"] != nil) ? [table objectForKey:@"PhoneNumber"] : @"";
                recent.dateTime = (NSDate*) [table objectForKey:@"DateTime"];
                [[self mutableArrayValueForKey:@"recents"] addObject:recent];
                [recent release];
            }
        }
    }
    @catch (NSException *exception) 
    {
        [[self mutableArrayValueForKey:@"recents"] removeAllObjects];
    }
    
    @try 
    {
        [self.cards removeAllObjects];
        self.activeCard = nil;
        NSArray* cardsArray = [defaults objectForKey:@"Cards"];
        if (cardsArray != nil)
        {
            for (int i = 0; i < [cardsArray count]; i++)
            {
                NSDictionary* cardTable = (NSDictionary*) [cardsArray objectAtIndex:i];
                Card* card = [[Card alloc] init];
                card.identifier = [cardTable objectForKey:@"Identifier"];
                card.name = [cardTable objectForKey:@"Name"];
                
                NSArray* actionsArray = (NSArray*) [cardTable objectForKey:@"DialActions"];
                if (actionsArray != nil)
                {
                    for (int j = 0; j < [actionsArray count]; j++)
                    {
                        NSDictionary* actionTable = (NSDictionary*) [actionsArray objectAtIndex:j];
                        DialAction* action = [[DialAction alloc] init];
                        action.name = [actionTable objectForKey:@"Name"];
                        action.value = [actionTable objectForKey:@"Value"];
                        [card.dialActions addObject:action];
                        [action release];
                    }
                }
                
                if ([card.dialActions count] == 0)
                {
                    DialAction* action = [[DialAction alloc] initWithName:@"contact" value:@""];
                    [card.dialActions addObject:action];
                    [action release];
                }
                
                [self.cards addObject:card];
                [card release];
            }
        }
        
        NSString* activeCardIdentifier = [defaults objectForKey:@"ActiveCard"];
        if ((activeCardIdentifier != nil) && ([activeCardIdentifier length] > 0))
        {
            for (int i = 0; i < [self.cards count]; i++)
            {
                Card* card = [self.cards objectAtIndex:i];
                if ([activeCardIdentifier isEqualToString:card.identifier])
                {
                    self.activeCard = card;
                    break;
                }
            }
        }
    }
    @catch (NSException *exception) 
    {
        [self.cards removeAllObjects];
        self.activeCard = nil;
    }

    return self;
}

- (void) dealloc
{
    [self->favorites release];
    [self->recents release];
    [self->cards release];
    self.activeCard = nil;
    [super dealloc];
}

- (void) save
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];

    NSMutableArray* favoritesArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self.favorites count]; i++)
    {
        Favorite* favorite = (Favorite*) [self.favorites objectAtIndex:i];

        NSMutableDictionary* favoriteTable = [[NSMutableDictionary alloc] init];
        [favoriteTable setObject:favorite.phoneNumber forKey:@"PhoneNumber"];
        [favoriteTable setObject:favorite.name forKey:@"Name"];
        [favoriteTable setObject:favorite.label forKey:@"Label"];
    
        [favoritesArray addObject:favoriteTable];
        [favoriteTable release];
    }

    NSMutableArray* recentsArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self.recents count]; i++)
    {
        Recent* recent = (Recent*) [self.recents objectAtIndex:i];
        
        NSMutableDictionary* recentTable = [[NSMutableDictionary alloc] init];
        [recentTable setObject:recent.phoneNumber forKey:@"PhoneNumber"];
        [recentTable setObject:recent.dateTime forKey:@"DateTime"];
        
        [recentsArray addObject:recentTable];
        [recentTable release];
    }
        
    NSMutableArray* cardsArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self.cards count]; i++)
    {
        Card* card = (Card*) [self.cards objectAtIndex:i];
        
        NSMutableArray* dialActionsArray = [[NSMutableArray alloc] init];        
        for (int j = 0; j < [card.dialActions count]; j++)
        {
            DialAction* action = (DialAction*) [card.dialActions objectAtIndex:j];
     
            NSMutableDictionary* actionTable = [[NSMutableDictionary alloc] init];
            [actionTable setObject:action.name forKey:@"Name"];
            [actionTable setObject:action.value forKey:@"Value"];
            
            [dialActionsArray addObject:actionTable];
            [actionTable release];
        }
        
        NSMutableDictionary* cardTable = [[NSMutableDictionary alloc] init];
        [cardTable setObject:card.identifier forKey:@"Identifier"];
        [cardTable setObject:card.name forKey:@"Name"];
        [cardTable setObject:dialActionsArray forKey:@"DialActions"];

        [cardsArray addObject:cardTable];
        [dialActionsArray release];
        [cardTable release];
    }

    [defaults setObject:favoritesArray forKey:@"Favorites"];
    [defaults setObject:cardsArray forKey:@"Cards"];
    [defaults setObject:recentsArray forKey:@"Recents"];
    
    if (self.activeCard != nil)
    {
        [defaults setObject:self.activeCard.identifier forKey:@"ActiveCard"];
    }    

    [defaults synchronize];
    
    [recentsArray release];
    [cardsArray release];
    [favoritesArray release];
}

@end
