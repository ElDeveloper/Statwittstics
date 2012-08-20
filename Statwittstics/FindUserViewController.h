//
//  FindUserViewController.h
//  Statwittstics
//
//  Created by Yoshiki - Vázquez Baeza on 22/04/12.
//  Copyright (c) 2012 Polar Bears Nanotechnology Research ©. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StatwittsticsDefines.h"

#import "PBTKit.h"
#import "GIDAAlertView.h"
#import "HomeViewController.h"

typedef enum {
    FUVCScopeUsers=0,
    FUVCScopeOnlyFriends=1
}FUVCScope;

@class HomeViewController;

@interface FindUserViewController : UITableViewController <UISearchDisplayDelegate, UISearchBarDelegate, UIAlertViewDelegate>{
    PBTUser *researchFellow;
    UISearchBar *theSearchBar;
    HomeViewController *previousViewController;
    
    @private NSMutableArray *searchResults;
    @private GIDAAlertView *alertView;
}

@property (nonatomic, retain) PBTUser *researchFellow;
@property (nonatomic, retain) UISearchBar *theSearchBar;
@property (nonatomic, retain) HomeViewController *previousViewController;

//Private appearance properties
@property (nonatomic, retain) NSMutableArray *searchResults;
@property (nonatomic, retain) GIDAAlertView *alertView;

//The initializer carries a user that allows search queries to be sent to twitter
-(id)initWithResearchFellow:(PBTUser *)theResearchFellow andViewController:(HomeViewController *)someViewController;

-(void)loadResults:(id)sender;
-(void)updateProfilePictureForCellAtIndex:(NSIndexPath *)indexPath;

@end