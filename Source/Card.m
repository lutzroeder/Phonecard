
#import "Card.h"

@implementation Card

@synthesize identifier;
@synthesize name;
@synthesize dialActions;

- (id)init
{
    self = [super init];
    self.identifier = @"";
    self.name = @"";
    NSMutableArray* actions = [[NSMutableArray alloc] init];
    self.dialActions = actions;
    [actions release];
    return self;
}

- (void) dealloc
{
    self.identifier = nil;
    self.name = nil;
    self.dialActions = nil;
    [super dealloc];
}

+ (id) newDefaultCard
{
    Card *card = [[Card alloc] init];
    
    DialAction* action;
    action = [[DialAction alloc] initWithName:@"access" value:@""];
    [card.dialActions addObject:action];
    [action release];
    action = [[DialAction alloc] initWithName:@"pause" value:@"2"];
    [card.dialActions addObject:action];
    [action release];
    action = [[DialAction alloc] initWithName:@"pin" value:@""];
    [card.dialActions addObject:action];
    [action release];
    action = [[DialAction alloc] initWithName:@"pause" value:@"2"];
    [card.dialActions addObject:action];
    [action release];
    action = [[DialAction alloc] initWithName:@"contact" value:@",,"];
    [card.dialActions addObject:action];
    [action release];
    
    return card;
}

@end
