//
//  AccountSelectorViewController.h
//  Statwittstics
//
//  Created by Yoshiki - Vázquez Baeza on 26/12/12.
//  Copyright (c) 2012 Polar Bears Nanotechnology Research ©. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StatwittsticsDefines.h"

@class ACAccount;

typedef void __block (^ASCompletionHandler)(ACAccount *selectedAccount, NSError *error);

@interface AccountSelectorViewController : UITableViewController{
	NSArray *accounts;
	ASCompletionHandler completionHandler;
}

-(id)initWithAccounts:(NSArray *)theAccounts andCompletionHandler:(ASCompletionHandler)completion;

@property (nonatomic, retain, readonly) NSArray *accounts;
@property (nonatomic, retain, readonly) ASCompletionHandler completionHandler;

@end
