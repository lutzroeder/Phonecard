
#import <Foundation/Foundation.h>
#import "ServiceProvider.h"
#import "StorageService.h"
#import "CardsController.h"
#import "TextController.h"
#import "NumberController.h"
#import "PauseController.h"
#import "DialContactController.h"
#import "NSString.h"

@interface CardController : UITableViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>
{
    @private
    id<ServiceProvider> _serviceProvider;
    Card* _card;
    BOOL _editMode;
    CardsController* _cardsController;
    UIBarButtonItem* _editButton;
    UIBarButtonItem* _doneButton;
    UIView* _deleteButtonView;
}

- (id) initWithServiceProvider:(id<ServiceProvider>)serviceProvider card:(Card*)card editMode:(BOOL)editMode cardsController:(CardsController*)cardsController;

- (void) tableViewCell:(UITableViewCell*)cell setDetailText:(NSString*)value withDefaultText:(NSString*)defaultValue;
- (void) updateCardName:(NSString*)value;

@end
