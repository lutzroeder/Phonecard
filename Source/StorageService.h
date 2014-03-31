
#import <Foundation/Foundation.h>
#import "Card.h"
#import "Favorite.h"
#import "Recent.h"

@interface StorageService : NSObject
{
    NSMutableArray* favorites;
    NSMutableArray* recents;
    NSMutableArray* cards;    
}

@property (readonly, retain) NSMutableArray* favorites;
@property (readonly, retain) NSMutableArray* recents;
@property (readonly, retain) NSMutableArray* cards;
@property (readwrite, retain) Card* activeCard;

- (void) save;

@end
