
#import "WebViewController.h"

@implementation WebViewController

- (id) initWithRequest:(NSURLRequest*)request;
{
    self = [super init];

    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonClick:)] autorelease];
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonClick:)] autorelease];    

    UIWebView* webView = [[[UIWebView alloc] init] autorelease];
    webView.delegate = self;
    [webView loadRequest:request];
    [self setView:webView];

    return self;
}

- (void) stopActivityIndicator
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void) webViewDidStartLoad:(UIWebView *)webView
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void) webViewDidFinishLoad:(UIWebView *)webView;
{
    [self stopActivityIndicator];    
}

- (void) cancelButtonClick:(id)sender
{
    [self stopActivityIndicator];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void) actionButtonClick:(id)sender
{
    UIActionSheet* actionSheet = [[UIActionSheet alloc] init];
    [actionSheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Open in Safari", nil)];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
    [actionSheet setCancelButtonIndex:1];
    [actionSheet setDelegate:self];
    [actionSheet showInView:self.view.window];
    [actionSheet release];
}

- (void) actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        UIWebView* webView = (UIWebView*) self.view;
        NSURL* url = webView.request.URL;

        UIApplication* application = [UIApplication sharedApplication];
        if ([application canOpenURL:url])
        {
            [application openURL:url];
        }
    }
}

@end
