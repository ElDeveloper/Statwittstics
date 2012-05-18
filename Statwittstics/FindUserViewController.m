//
//  FindUserViewController.m
//  Statwittstics
//
//  Created by Yoshiki - Vázquez Baeza on 22/04/12.
//  Copyright (c) 2012 Polar Bears Nanotechnology Research ©. All rights reserved.
//

#import "FindUserViewController.h"

@implementation FindUserViewController

@synthesize researchFellow, theSearchBar, searchResults, alertView, previousViewController;

#pragma mark - UITableViewController Life-cycle

-(id)initWithResearchFellow:(PBTUser *)theResearchFellow andViewController:(HomeViewController *)someViewController{
    //The class only implements UITableViewStylePlain, this is a direct dependency
    //over the fact that the users are presented in custom plain-style cells
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        //Allow the wide-use of the account
        researchFellow=[theResearchFellow retain];
        [self setPreviousViewController:someViewController];
        alertView=[[GIDAAlertView alloc] initAlertWithSpinnerAndMessage:NSLocalizedString(@"Searching For Users", @"Searching For Users String")];
        [alertView setCenter:CGPointMake(270, 160)];
        
        //This class is only defined with a modal behavior
        [self setModalPresentationStyle:UIModalPresentationFormSheet];
        [self setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        
        //Create and init the toolbar
        theSearchBar=[[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 540, 44)];
        [theSearchBar setShowsScopeBar:YES];
        [theSearchBar setTintColor:[UIColor blackColor]];
        [theSearchBar setScopeButtonTitles:[NSArray arrayWithObjects:NSLocalizedString(@"Users", @"Users String"), NSLocalizedString(@"Friends", @"Friends String"), nil]];
        [theSearchBar setDelegate:self];
        [theSearchBar setShowsCancelButton:YES];
        [theSearchBar setKeyboardType:UIKeyboardTypeTwitter];
        [[self tableView] setTableHeaderView:theSearchBar];
        
        //Create the search display controller
        UISearchDisplayController *searchController = [[UISearchDisplayController alloc] initWithSearchBar:theSearchBar contentsController:self];
        [searchController setDelegate:self];
        [searchController setSearchResultsDelegate:self];
        [searchController setSearchResultsDataSource:self];
        
        //Init the array
        searchResults=[[NSMutableArray alloc] initWithObjects:nil];
        
        //Memory management
        [searchController release];
    }
    return self;
}

//Allow the keyboard to be hidden after every search done by the user
-(BOOL)disablesAutomaticKeyboardDismissal {
    return NO;
}

-(void)viewDidLoad{
    [super viewDidLoad];
}

-(void)dealloc{
    [researchFellow release];
    [theSearchBar release];
    [searchResults release];
    [alertView release];
    [previousViewController release];
    
    [super dealloc];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{    
    return YES;
}

#pragma mark - FindUserViewController Behavioral Methods
-(void)loadResults{
    //Upadate the GUI, remember the GUI can only be updated in the Main Thread    
    [[self tableView] beginUpdates];
    [[self tableView] reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationBottom];
    [[self tableView] endUpdates];
    
    //Download have stopped, let the user know about this
    [alertView hideAlertWithSpinner];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

-(void)updateProfilePictureForCellAtIndex:(NSIndexPath *)indexPath{
    //Avoid a big oneliner by dividing it into various pieces
    UITableViewCell *needsUpdate=[[self tableView] cellForRowAtIndexPath:indexPath];
    NSData *theImageData=[[searchResults objectAtIndex:[indexPath row]] imageData];    
    UIImage *theImage=[UIImage imageWithData:theImageData];
    [[needsUpdate imageView] setImage:theImage];
}

#pragma mark - UITableViewControllerDataSource Methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    // Return the number of sections.
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    // Return the number of rows in the section.
    return [searchResults count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    static NSData *placeHolderData;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];    
    PBTUser *currentUser=nil;
    
    // Configure the cell...
    if (cell == nil) {
        cell=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        [[cell imageView] setContentMode:UIViewContentModeCenter];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    
    //This is an static variable, fixed with the data representation of the user-placeholder
    if (placeHolderData == nil) {
        placeHolderData=UIImagePNGRepresentation([UIImage imageNamed:@"ProfilePicturePlaceholder.png"]);
    }
    
    //Load the PBTUser to avoid some overhead
    currentUser=[searchResults objectAtIndex:[indexPath row]];
    
    //Update the interface
    [[cell textLabel] setText:[currentUser username]];
    [[cell detailTextLabel] setText:[currentUser realName]];
    
    //Check if the request has already been completed
    if ([currentUser imageData] == nil) {
        //Set the placeholder into place
        [currentUser setImageData:placeHolderData];
        [[cell imageView] setImage:[UIImage imageWithData:[currentUser imageData]]];
    
        //Asycnchronously request the image in a regular size
        [currentUser requestProfilePictureWithSize:TAImageSizeNormal andHandler:^{
            
            //When we get the data back, call on the main thread the update of the user interface
            [self performSelectorOnMainThread:@selector(updateProfilePictureForCellAtIndex:) withObject:indexPath waitUntilDone:NO];
        }];
    }
    else {
        //If we already have the data, just show it
        [[cell imageView] setImage:[UIImage imageWithData:[currentUser imageData]]];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate Methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60; //This has yet to be defined 
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //Dismiss the view controller
    [self dismissModalViewControllerAnimated:YES];
    
    [previousViewController setSubjectOfAnalysis:[searchResults objectAtIndex:[indexPath row]]];
    [previousViewController performSelectorOnMainThread:@selector(downloadTweets) withObject:nil waitUntilDone:NO];
    //[previousViewController loadUser:[searchResults objectAtIndex:[indexPath row]]];
}

#pragma mark - UISearchDisplayControllerDelegate Methods
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    if (searchOption == -1) {
        return YES;
    }
    return NO;
}

#pragma mark - UISearchBarDelegate Methods
//This method is called everytime the userhits return in the keyboard
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    //Building a mutable array since a search bar can't be sent to a thread, in this
    //array you are able to pass the information comming from UISearchBar
    NSMutableArray *requestArray = [[NSMutableArray alloc] initWithObjects:
                                    [NSString stringWithFormat:@"%@",[[searchBar scopeButtonTitles] objectAtIndex:[searchBar selectedScopeButtonIndex]]],
                                    [NSString stringWithFormat:@"%@",[searchBar text]], nil];
    [requestArray autorelease];
    
    //Hide the search controller, this will lead to the keyboard to be dismissed
    [[self searchDisplayController] setActive:NO animated:YES];
    
    //User interface changes to show that data is being downloaded
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [alertView presentAlertWithSpinner];
    
    //Begin search ...
    [PBTUtilities user:researchFellow requestUsersWithKeyword:[searchBar text] andResponseHandler:^(NSArray *arrayOfSubjects) {
        
        //If there is something inside the array (try to avoid some over-head)
        if ([searchResults count] != 0) {
            //Clear it
            [searchResults removeAllObjects];
        }
        
        //Now add all the new objects at the beginning
        [searchResults addObjectsFromArray:arrayOfSubjects];
        
        //Update the interface on the main thread
        [self performSelectorOnMainThread:@selector(loadResults) withObject:nil waitUntilDone:NO];
    }]; 
}

//This method is called when the cancel button is pressed
-(void)searchBarCancelButtonClicked:(UISearchBar *) searchBar{
    //Remove the view controller from the screen
    [self dismissModalViewControllerAnimated:YES];
}

-(void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar{
    NSLog(@"AWESOME:%s", __PRETTY_FUNCTION__);
}

@end
