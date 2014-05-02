//
//  Photographer+Create.h
//  Top Places
//
//  Created by hcfilippo on 14-5-2.
//  Copyright (c) 2014年 hcfilippo. All rights reserved.
//

#import "Photographer.h"

@interface Photographer (Create)
+ (Photographer *)photographerWithName:(NSString *)name
                             withPlace:(NSString *)place
                inManagedObjectContext:(NSManagedObjectContext *)context;

@end
