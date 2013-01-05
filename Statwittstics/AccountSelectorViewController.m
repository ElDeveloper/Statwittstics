//
//  AccountSelectorViewController.m
//  Statwittstics
//
//  Created by Yoshiki - Vázquez Baeza on 26/12/12.
//  Copyright (c) 2012 Polar Bears Nanotechnology Research ©. All rights reserved.
//

#import "AccountSelectorViewController.h"

#import <Accounts/Accounts.h>

@interface AccountSelectorViewController (PrivateAPI)


@end

@implementation AccountSelectorViewController

@synthesize accounts, completionHandler;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
		accounts = nil;
		completionHandler = nil;
    }
    return self;
}

-(id)initWithAccounts:(NSArray *)theAccounts andCompletionHandler:(ASCompletionHandler)completion{
	[self initWithStyle:UITableViewStyleGrouped];

	accounts=[[NSArray alloc] initWithArray:theAccounts];
	completionHandler=Block_copy(completion);

	return self;
}

-(void)dealloc{
	if ([self accounts] != nil) {
		[accounts release];
	}

	if ([self completionHandler] != nil) {
		[completionHandler release];
	}

	[super dealloc];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    // Return the number of rows in the section.
    return [accounts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	ACAccount *someAccount=[accounts objectAtIndex:[indexPath row]];

	if (cell == nil) {
		cell=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        [[cell imageView] setContentMode:UIViewContentModeCenter];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
	}

    // Configure the cell...
	[[cell textLabel] setText:[NSString stringWithFormat:@"@%@",[someAccount username]]];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	return NSLocalizedString(@"Please select an account to access the Twitter API", @"Account Selector Header");
}
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
	return NSLocalizedString(@"This account will grant you access to private content, such as friend's information that maybe private to the public.", @"Account Selector Footer");
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	[self dismissModalViewControllerAnimated:YES];


	[self completionHandler]([[self accounts] objectAtIndex:[indexPath row]], nil);
}

@end
