//
//  Photo+Flickr.m
//  Top Places
//
//  Created by hcfilippo on 14-5-1.
//  Copyright (c) 2014年 hcfilippo. All rights reserved.
//

#import "Photo+Flickr.h"
#import "FlickrFetcher.h"
#import "Place+Create.h"
#import "Photographer+Create.h"
#import "AppDelegate.h"
#import "PhotoDatabaseAvailability.h"

@implementation Photo (Flickr)

+ (Photo *)photoWithFlickrInfo:(NSDictionary *)photoDictionary
        inManagedObjectContext:(NSManagedObjectContext *)context
{
    Photo *photo = nil;
    
    NSString *photoID = photoDictionary[FLICKR_PHOTO_ID];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"photoID = %@", photoID];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || ([matches count] > 1)) {
        // handle error
    } else if ([matches count]) {
        photo = [matches firstObject];
    } else {
        
        NSString *placeID = [photoDictionary valueForKeyPath:FLICKR_PLACE_ID];
        NSString *owner = [photoDictionary valueForKeyPath:FLICKR_PHOTO_OWNER];
        NSURL *url = [FlickrFetcher URLforInformationAboutPlace:placeID];
        dispatch_queue_t fetchQ = dispatch_queue_create("placeName fetcher", NULL);
        dispatch_async(fetchQ, ^{
            NSData *jsonResults = [NSData dataWithContentsOfURL:url];
            //dataWithContentsOfURL: sometimes returns nil, refetching it
            while (!jsonResults)
            {
                jsonResults = [NSData dataWithContentsOfURL:url];
            }
            NSDictionary *propertyListResults = [NSJSONSerialization JSONObjectWithData:jsonResults
                                                                                options:0
                                                                                  error:nil];
            
            NSString *region = [FlickrFetcher extractRegionNameFromPlaceInformation:propertyListResults];
            if (!region) {
                region =@"Unknown";
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                AppDelegate *myDelegate = [[UIApplication sharedApplication] delegate];
                NSManagedObjectContext *context = myDelegate.document.managedObjectContext;
                Photo *photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
                
                photo.photoID = photoID;
                photo.title = [photoDictionary valueForKeyPath:FLICKR_PHOTO_TITLE];
                photo.subtitle = [photoDictionary valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
                photo.thumbnailURL = [[FlickrFetcher URLforPhoto:photoDictionary format:FlickrPhotoFormatSquare] absoluteString];
                photo.imageURL = [[FlickrFetcher URLforPhoto:photoDictionary format:FlickrPhotoFormatLarge] absoluteString];
                photo.thumbnailImage = nil;
                photo.viewDate = nil;
                
                photo.whoTook = [Photographer photographerWithName:owner
                                                        withPlace:region
                                            inManagedObjectContext:context];
                photo.whereTook = [Place photoAddPlaceWithName:region
                              inManagedObjectContext:context];
                
            });
            
        });
      //  [[NSNotificationCenter defaultCenter] postNotificationName:PhotoDatabaseAvailabilityNotification object:self];
    }
    return photo;
}


+ (void)loadPhotosFromFlickrArray:(NSArray *)photos // of Flickr NSDictionary
         intoManagedObjectContext:(NSManagedObjectContext *)context
{
    NSLog(@"photos : %d\n" , [photos count]);
    
    for (NSDictionary *photo in photos) {
        [self photoWithFlickrInfo:photo inManagedObjectContext:context];
    }
}


+ (Photo *)photoWithID:(NSString *)photoID
inManagedObjectContext:(NSManagedObjectContext *)context
{
    Photo *photo = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"photoID = %@", photoID];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] > 1 || error)) {
        // handle error
    } else if ([matches count] == 0) {
        photo = nil;
    } else {
        photo = [matches lastObject];
    }

    return photo;
}


@end
