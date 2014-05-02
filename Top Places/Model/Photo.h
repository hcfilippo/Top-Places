//
//  Photo.h
//  Top Places
//
//  Created by hcfilippo on 14-5-2.
//  Copyright (c) 2014年 hcfilippo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photographer, Place;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSString * photoID;
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) NSData * thumbnailImage;
@property (nonatomic, retain) NSString * thumbnailURL;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSDate * viewDate;
@property (nonatomic, retain) Place *whereTook;
@property (nonatomic, retain) Photographer *whoTook;

@end
