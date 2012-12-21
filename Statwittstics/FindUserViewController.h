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

typedef enum {
    FUVCScopeUsers=0,
    FUVCScopeOnlyFriends=1
}FUVCScope;

@protocol FindUserViewControllerDelegate;

@interface FindUserViewController : UITableViewController <UISearchDisplayDelegate, UISearchBarDelegate, UIAlertViewDelegate>{
	id<FindUserViewControllerDelegate> delegate;

    PBTUser *researchFellow;
    UISearchBar *theSearchBar;

    @private NSMutableArray *searchResults;
    @private GIDAAlertView *alertView;
}

@property (assign) id<FindUserViewControllerDelegate> delegate;

@property (nonatomic, retain) PBTUser *researchFellow;
@property (nonatomic, retain) UISearchBar *theSearchBar;

//Private appearance properties
@property (nonatomic, retain) NSMutableArray *searchResults;
@property (nonatomic, retain) GIDAAlertView *alertView;

//The research fellow is a credential provider to perform queries in Twitter
-(id)initWithResearchFellow:(PBTUser *)theResearchFellow;

-(void)loadResults:(id)sender;
-(void)updateProfilePictureForCellAtIndex:(NSIndexPath *)indexPath;

@end

@protocol FindUserViewControllerDelegate <NSObject>

@optional
-(void)subjectWasSelected:(PBTUser *)newSubject;

@end