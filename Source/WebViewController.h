
#import <Foundation/Foundation.h>

@interface WebViewController : UIViewController <UIWebViewDelegate, UIActionSheetDelegate>
{
}

- (id) initWithRequest:(NSURLRequest*)request;

- (void) stopActivityIndicator;

- (void) cancelButtonClick:(id)sender;
- (void) actionButtonClick:(id)sender;

@end
