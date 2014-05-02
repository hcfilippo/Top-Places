//
//  TopPhotoTableViewController.m
//  Top Places
//
//  Created by hcfilippo on 14-4-16.
//  Copyright (c) 2014年 hcfilippo. All rights reserved.
//

#import "TopPhotoTableViewController.h"
#import "ImageViewController.h"
#import "FlickrFetcher.h"
#import "Photo+Flickr.h"
#import "Place.h"


@interface TopPhotoTableViewController ()

@end

@implementation TopPhotoTableViewController

- (void)setPlace:(Place *)place
{
    _place = place;
    self.title = place.name;
    [self setupFetchedResultsController];
}

- (void)setupFetchedResultsController
{
    NSManagedObjectContext *context = self.place.managedObjectContext;
    
    if (context) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
        request.predicate = [NSPredicate predicateWithFormat:@"whereTook = %@", self.place];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title"
                                                                  ascending:YES
                                                                   selector:@selector(localizedStandardCompare:)]];
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:context
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil];
    } else {
        self.fetchedResultsController = nil;
    }
}


@end
