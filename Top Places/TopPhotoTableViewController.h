//
//  TopPhotoTableViewController.h
//  Top Places
//
//  Created by hcfilippo on 14-4-16.
//  Copyright (c) 2014年 hcfilippo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TopPhotoTableViewController : UITableViewController
@property (nonatomic, strong) NSArray *photos; // of Flickr photos NSDictionary
@property (nonatomic, strong) id placeID;
@property (nonatomic, strong) NSMutableArray * photoSectionIDs;
@end
