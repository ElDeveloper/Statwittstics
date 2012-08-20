//
//  AboutViewController.m
//  Statwittstics
//
//  Created by Yoshiki - Vázquez Baeza on 17/04/12.
//  Copyright (c) 2012 Polar Bears Nanotechnology Research ©. All rights reserved.
//

#import "AboutViewController.h"

#define TWITTER_USERNAMES_HTML_STRING \
@"<html><head><style>body{background-color:transparent;}</style> </head><body>\
<DIV ALIGN=CENTER><font color=\"#4C4C4C\" face=\"Helvetica\"  size=\"4.5\">\
<a href=\"http://twitter.com/yosmark\">@yosmark</a>, \
<a href=\"http://twitter.com/alexwalls\">@alexwalls</a> & \
<a href=\"http://twitter.com/analaurad\">@analaurad</a>\
</font>\
</DIV>\
</body></html>"

@implementation AboutViewController

@synthesize twitterUsernamesView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self setModalPresentationStyle:UIModalPresentationFormSheet];
        [self setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    }
    return self;
}

-(void)dealloc{
    [twitterUsernamesView release];
    
    [super dealloc];
}

-(void)viewDidLoad{
    [super viewDidLoad];
    
    //This webview is transparent, doesn't bounce and opens links in Safari
    [[[self twitterUsernamesView] scrollView] setBounces:NO];
    [[self twitterUsernamesView] setDelegate:self];
    [[self twitterUsernamesView] setBackgroundColor:[UIColor clearColor]];
    [[self twitterUsernamesView] setOpaque:NO];
    [[self twitterUsernamesView] loadHTMLString:TWITTER_USERNAMES_HTML_STRING baseURL:nil];
}

-(IBAction)dismissCredits:(id)sender{
    [self dismissModalViewControllerAnimated:YES];
}

//Open the links in Safari
-(BOOL)webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType {
    if ( inType == UIWebViewNavigationTypeLinkClicked ) {
        [[UIApplication sharedApplication] openURL:[inRequest URL]];
        return NO;
    }
    return YES;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{    
    //Do not allow portrait, only landscape
    if (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        return NO;
    }
    
	return YES;
}


@end
