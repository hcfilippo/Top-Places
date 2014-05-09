//
//  TopPhotoTableViewController.h
//  Top Places
//
//  Created by hcfilippo on 14-4-16.
//  Copyright (c) 2014年 hcfilippo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Place.h"
#import "PhotosTableViewController.h"

@interface TopPhotoTableViewController : PhotosTableViewController
@property (nonatomic, strong) Place *place;
@end
