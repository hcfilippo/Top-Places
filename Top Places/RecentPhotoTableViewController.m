//
//  RecentPhotoTableViewController.m
//  Top Places
//
//  Created by hcfilippo on 14-4-17.
//  Copyright (c) 2014年 hcfilippo. All rights reserved.
//

#import "RecentPhotoTableViewController.h"
#import "ImageViewController.h"
#import "FlickrFetcher.h"
#import "AppDelegate.h"

@interface RecentPhotoTableViewController ()

@end

@implementation RecentPhotoTableViewController


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupFetchedResultsController];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (self.fetchedResultsController.fetchedObjects)
    {
        self.title = [NSString stringWithFormat:@"Photos (%d)",[self.fetchedResultsController.fetchedObjects count]];
    } else {
        self.title = [NSString stringWithFormat:@"Photos (0)"];
    }
}

- (void)setupFetchedResultsController
{
    
    AppDelegate *myDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = myDelegate.document.managedObjectContext;
    
    if (context) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
        request.predicate = [NSPredicate predicateWithFormat:@"viewDate!=nil"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"viewDate"
                                                                  ascending:NO]];
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:context
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil];
    } else {
        self.fetchedResultsController = nil;
    }
}


@end
