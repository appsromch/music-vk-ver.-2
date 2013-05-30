//
//  vkLogin.m
//  knowhat
//
//  Created by David Dreval on 12.02.12.
//  Copyright (c) 2012 D3 Apps. All rights reserved.
//

#import "vkLogin.h"
//#import "ViewController.h"

@implementation vkLogin
@synthesize delegate, vkWebView, appID;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithRed:2/255.0f green:144/255.0f blue:217/255.0f alpha:1]];
    indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [indicator setFrame:CGRectMake(self.view.frame.size.width/2 - 22, self.view.frame.size.height/2 - 22, 44, 44)];
    [indicator startAnimating];
    [self.view addSubview:indicator];
    // Do any additional setup after loading the view from its nib.
    if(!vkWebView){
        self.vkWebView = [[UIWebView alloc] initWithFrame:self.view.bounds];
        vkWebView.delegate = self;
        vkWebView.scalesPageToFit = YES;
        [vkWebView setHidden:YES];
        [self.view addSubview:vkWebView];
    }
    appID = [NSString stringWithFormat:@"2863107"];
    if(!appID) {
        [self dismissModalViewControllerAnimated:YES];
        return;
    }
    NSString *authLink = [NSString stringWithFormat:@"http://api.vk.com/oauth/authorize?client_id=%@&scope=wall,friends,audio,groups,offline&redirect_uri=http://api.vk.com/blank.html&display=touch&response_type=token", appID];
    NSURL *url = [NSURL URLWithString:authLink];
    [vkWebView loadRequest:[NSURLRequest requestWithURL:url]];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    vkWebView.delegate = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Web View Delegate

- (BOOL)webView:(UIWebView *)aWbView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSURL *URL = [request URL];
    // Пользователь нажал Отмена в веб-форме
    if ([[URL absoluteString] isEqualToString:@"http://api.vk.com/blank.html#error=access_denied&error_reason=user_denied&error_description=User%20denied%20your%20request"]) {
        [super dismissModalViewControllerAnimated:YES];
        return NO;
    }
	//NSLog(@"Request: %@", [URL absoluteString]); 
	return YES;
}

-(void)webViewDidStartLoad:(UIWebView *)webView {
    
}

- (void) vkLogOut {

    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *logout = @"http://api.vk.com/oauth/logout";
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:logout] 
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData 
                                                       timeoutInterval:60.0]; 
    [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    [ud removeObjectForKey:@"VKAccessToken"];
    [ud setObject:@"1" forKey:@"VKAccessTokenDate"];
    [ud synchronize];
    NSLog(@"Autologin done");
    [self viewDidLoad];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    [vkWebView setHidden:NO];
    [indicator stopAnimating];
    [indicator removeFromSuperview];
    if ([vkWebView.request.URL.absoluteString rangeOfString:@"security breach"].location != NSNotFound) {
        [self vkLogOut];
        return;
    }
    
    if ([vkWebView.request.URL.absoluteString rangeOfString:@"access_token"].location != NSNotFound) {
        NSString *accessToken = [self stringBetweenString:@"access_token=" 
                                                andString:@"&" 
                                              innerString:[[[webView request] URL] absoluteString]];
        NSString *expireStr = [self stringBetweenString:@"expires_in=" 
                                                andString:@"&" 
                                              innerString:[[[webView request] URL] absoluteString]];
        NSArray *userAr = [[[[webView request] URL] absoluteString] componentsSeparatedByString:@"&user_id="];
        NSString *user_id = [userAr lastObject];
        NSLog(@"User id: %@", user_id);
        if(user_id){
            [[NSUserDefaults standardUserDefaults] setObject:user_id forKey:@"VKAccessUserId"];
        }
        
        if(accessToken){
            [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:@"token"];
            NSNumber *num = [NSNumber numberWithFloat:[[NSDate date] timeIntervalSince1970]];
            NSInteger numToUd = [num intValue] + [expireStr intValue];
            [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d", numToUd] forKey:@"VKAccessTokenDate"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
      //  [(ViewController *)delegate authComplete];
        [self dismissModalViewControllerAnimated:YES];
    } else if ([vkWebView.request.URL.absoluteString rangeOfString:@"error"].location != NSNotFound) {
        [self dismissModalViewControllerAnimated:YES];
    }
    
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Methods

- (NSString*)stringBetweenString:(NSString*)start 
                       andString:(NSString*)end 
                     innerString:(NSString*)str 
{
    NSScanner* scanner = [NSScanner scannerWithString:str];
    [scanner setCharactersToBeSkipped:nil];
    [scanner scanUpToString:start intoString:NULL];
    if ([scanner scanString:start intoString:NULL]) {
        NSString* result = nil;
        if ([scanner scanUpToString:end intoString:&result]) {
            return result;
        }
    }
    return nil;
}


@end
