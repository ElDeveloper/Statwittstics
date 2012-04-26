//
//  FindUserViewController.m
//  Statwittstics
//
//  Created by Yoshiki - Vázquez Baeza on 22/04/12.
//  Copyright (c) 2012 Polar Bears Nanotechnology Research ©. All rights reserved.
//

#import "FindUserViewController.h"

@implementation FindUserViewController

@synthesize theSearchBar, searchResults, spinner;

#pragma mark - UITableViewController Life-cycle
-(id)initWithStyle:(UITableViewStyle)style{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        //This class is only defined with a modal behavior
        [self setModalPresentationStyle:UIModalPresentationFormSheet];
        [self setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        
        //Create and init the toolbar
        theSearchBar=[[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        [theSearchBar setShowsScopeBar:YES];
        [theSearchBar setTintColor:[UIColor darkGrayColor]];
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

-(void)viewDidLoad{
    [super viewDidLoad];
}

-(void)viewDidUnload{
    [super viewDidUnload];
}

-(void)dealloc{
    [theSearchBar release];
    [searchResults release];
    
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
    
    [[self searchDisplayController] setActive:NO animated:YES];
}

-(void)willFilterContentForSearchText:(NSString*)searchText scope:(NSString*)scope{
    
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];    
    
    // Configure the cell...
    if (cell == nil) {
        cell=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    //Load the PBTUser ...
    [[cell textLabel] setText:[[searchResults objectAtIndex:[indexPath row]] username]];
    [[cell detailTextLabel] setText:[[searchResults objectAtIndex:[indexPath row]] realName]];
    
    return cell;
}

#pragma mark - UITableViewDelegate Methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60; //This has yet to be defined 
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
    
    //Begin search ...
    [PBTUtilities user:nil requestUsersWithKeyword:[searchBar text] andResponseHandler:^(NSArray *arrayOfSubjects) {
        
        //There is something inside the array
        if ([searchResults count] != 0) {
            //Clear it
            [searchResults removeAllObjects];
        }
        
        //Now add all the new objects at the beginning
        [searchResults insertObjects:arrayOfSubjects atIndexes:0];
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
