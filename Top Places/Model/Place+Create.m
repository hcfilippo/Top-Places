//
//  Place+Create.m
//  Top Places
//
//  Created by hcfilippo on 14-5-1.
//  Copyright (c) 2014年 hcfilippo. All rights reserved.
//

#import "Place+Create.h"
#import "FlickrFetcher.h"
#import "Photographer+Create.h"

@implementation Place (Create)

+ (Place *)photographerAddPlaceWithName:(NSString *)name
  inManagedObjectContext:(NSManagedObjectContext *)context
{
    Place *place = nil;
    if (![name isEqualToString:@""])
    {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Place"];
        request.predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
        
        NSError *error;
        NSArray *matches = [context executeFetchRequest:request error:&error];
        
        if (!matches || ([matches count] > 1)) {
            // handle error
            
        } else if (![matches count]) {
            place = [NSEntityDescription insertNewObjectForEntityForName:@"Place"
                                                         inManagedObjectContext:context];
            place.name = name;
            place.countPhotographers = [NSNumber numberWithInt:1];
        } else {
            place = [matches lastObject];
            place.countPhotographers = [NSNumber numberWithInt:[place.countPhotographers intValue] + 1];
        }

    }
    return place;
}


+ (Place *)photoAddPlaceWithName:(NSString *)name
          inManagedObjectContext:(NSManagedObjectContext *)context
{
    Place *place = nil;
    if (![name isEqualToString:@""])
    {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Place"];
        request.predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
        
        NSError *error;
        NSArray *matches = [context executeFetchRequest:request error:&error];
        
        if (!matches || ([matches count] > 1)) {
            // handle error
            
        } else if (![matches count]) {
            place = [NSEntityDescription insertNewObjectForEntityForName:@"Place"
                                                  inManagedObjectContext:context];
            place.name = name;
            place.countPhotos = [NSNumber numberWithInt:1];
        } else {
            place = [matches lastObject];
            place.countPhotos = [NSNumber numberWithInt:[place.countPhotos intValue] + 1];
        }
        
    }
    return place;
}

@end
