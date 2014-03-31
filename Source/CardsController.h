
#import <Foundation/Foundation.h>
#import "ServiceProvider.h"
#import "CardCell.h"
#import "StorageService.h"
#import "NavigationController.h"
#import "NSString.h"
#import "UITableViewCell.h"

@interface CardsController : UITableViewController <UITableViewDataSource>
{
    @private
    id<ServiceProvider> _serviceProvider;
    BOOL _launched;    
}

- (id) initWithServiceProvider:(id<ServiceProvider>)serviceProvider;

- (void) addCard:(Card*)card;
- (void) removeCard:(Card*)card;

@end
