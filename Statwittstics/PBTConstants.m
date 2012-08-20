//
//  PBTConstants.m
//  Statwittstics
//
//  Created by Yoshiki - Vázquez Baeza on 15/04/12.
//  Copyright (c) 2012 Polar Bears Nanotechnology Research ©. All rights reserved.
//

#import "PBTConstants.h"

TAUString TAUUsersShow=@"https://api.twitter.com/1/users/show.json";
TAUString TAUUserTimeline=@"https://api.twitter.com/1/statuses/user_timeline.json";
TAUString TAUImageData=@"https://api.twitter.com/1/users/profile_image/";
TAUString TAUUsersLookup=@"http://api.twitter.com/1/users/lookup.json";
TAUString TAUUsersSearch=@"http://api.twitter.com/1/users/search.json";

TAImageSize TAImageSizeMini=@"mini";
TAImageSize TAImageSizeNormal=@"normal";
TAImageSize TAImageSizeBigger=@"bigger";
TAImageSize TAImageSizeOriginal=@"original";

TAKey TAKeyUsername=@"screen_name";
TAKey TAKeyRealName=@"name";
TAKey TAKeyDescription=@"description";
TAKey TAKeyLocation=@"location";
TAKey TAKeyProfilePictureURL=@"profile_image_url";
TAKey TAKeyBioURL=@"url";
TAKey TAKeyFollowing=@"friends_count";
TAKey TAKeyFollowers=@"followers_count";
TAKey TAKeyTweets=@"statuses_count";
TAKey TAKeyProtected=@"protected";
TAKey TAKeyQuery=@"q";
TAKey TAKeyVerified=@"verified";
TAKey TAKeyIsFriend=@"following";

TAKey TAKeyEntities=@"entities";
TAKey TAKeyInToReplyScreenName=@"in_reply_to_screen_name";
TAKey TAKeyIsRetweet=@"retweeted";
TAKey TAKeyMedia=@"media";
TAKey TAKeyMediaURL=@"media_url";
TAKey TAKeyMentions=@"user_mentions";
TAKey TAKeyPostDate=@"created_at";
TAKey TAKeyScreenName=@"screen_name";
TAKey TAKeySource=@"source";
TAKey TAKeyText=@"text";
TAKey TAKeyTweetID=@"id_str";

@implementation PBTConstants
@end
