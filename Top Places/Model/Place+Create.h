//
//  Place+Create.h
//  Top Places
//
//  Created by hcfilippo on 14-5-1.
//  Copyright (c) 2014年 hcfilippo. All rights reserved.
//

#import "Place.h"
#import "Photographer.h"

@interface Place (Create)
+ (Place *)photographerAddPlaceWithName:(NSString *)name
inManagedObjectContext:(NSManagedObjectContext *)context;

+ (Place *)photoAddPlaceWithName:(NSString *)name
          inManagedObjectContext:(NSManagedObjectContext *)context;
@end
