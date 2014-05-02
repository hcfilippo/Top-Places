//
//  Photo+Flickr.h
//  Top Places
//
//  Created by hcfilippo on 14-5-1.
//  Copyright (c) 2014年 hcfilippo. All rights reserved.
//

#import "Photo.h"

@interface Photo (Flickr)
+ (Photo *)photoWithFlickrInfo:(NSDictionary *)photoDictionary
        inManagedObjectContext:(NSManagedObjectContext *)context;

+ (void)loadPhotosFromFlickrArray:(NSArray *)photos // of Flickr NSDictionary
         intoManagedObjectContext:(NSManagedObjectContext *)context;


+ (Photo *)photoWithID:(NSString *)photoID
        inManagedObjectContext:(NSManagedObjectContext *)context;

@end
