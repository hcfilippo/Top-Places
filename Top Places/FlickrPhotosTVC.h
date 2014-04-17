//
//  FlickrPhotosTVC.h
//  Shutterbug
//
//  Created by CS193p Instructor.
//  Copyright (c) 2013 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlickrPhotosTVC : UITableViewController

// Model of this MVC (it can be publicly set)
@property (nonatomic, strong) NSArray *places; // of Flickr places NSDictionary
@property (nonatomic, strong) NSMutableDictionary *countries;
@property (nonatomic, strong) NSMutableArray * countrySectionIDs;
@end
