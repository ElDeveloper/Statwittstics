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

@interface FindUserViewController : UITableViewController <UISearchDisplayDelegate, UISearchBarDelegate>{
    UISearchBar *theSearchBar;
    
    @private UIActivityIndicatorView *spinner;
    @private NSMutableArray *searchResults;
}

@property (nonatomic, retain) UISearchBar *theSearchBar;

//Private appearance properties
@property (nonatomic, retain) UIActivityIndicatorView *spinner;
@property (nonatomic, retain) NSMutableArray *searchResults;

-(void)loadResults;
-(void)willFilterContentForSearchText:(NSString*)searchText scope:(NSString*)scope;

@end