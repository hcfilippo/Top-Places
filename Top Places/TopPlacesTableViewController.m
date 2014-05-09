//
//  TopPlacesTableViewController.m
//  Shutterbug
//
//  Created by CS193p Instructor.
//  Copyright (c) 2013 Stanford University. All rights reserved.
//

#import "TopPlacesTableViewController.h"
#import "FlickrFetcher.h"
#import "TopPhotoTableViewController.h"
#import "AppDelegate.h"
#import "Place.h"
#import "PhotoDatabaseAvailability.h"
#import "AppDelegate.h"


@implementation TopPlacesTableViewController

// whenever our Model is set, must update our View


- (void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserverForName:PhotoDatabaseAvailabilityNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      NSLog(@"receive notification");
                                                      self.managedObjectContext = note.userInfo[PhotoDatabaseAvailabilityContext];
                                                  }];
    
    

}

- (void)viewWillAppear:(BOOL)animated
{
    AppDelegate *myDelegate = [[UIApplication sharedApplication] delegate];
    if (myDelegate.document)
    {
        self.managedObjectContext = myDelegate.document.managedObjectContext;
    }
}

/*
- (void)viewDidLoad
{
    [super viewDidLoad];
    AppDelegate *myDelegate = [[UIApplication sharedApplication] delegate];
    if (myDelegate.document)
    {
        self.managedObjectContext = myDelegate.document.managedObjectContext;
    }
}
*/
#pragma mark - UITableViewDataSource

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Place"];
    request.predicate = nil;
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"countPhotographers"
                                                              ascending:NO
                                                             ],
                                [NSSortDescriptor
                                 sortDescriptorWithKey:@"name"
                                 ascending:YES
                                 selector:@selector(localizedCaseInsensitiveCompare:)]];
    
    request.fetchLimit =50;
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // we must be sure to use the same identifier here as in the storyboard!
    static NSString *CellIdentifier = @"Flickr Place Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Place *place = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = place.name;
    cell.detailTextLabel.textColor = [UIColor blueColor];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ photographers %@ photos",place.countPhotographers, place.countPhotos];
    return cell;
}

#pragma mark - UITableViewDelegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id detail = self.splitViewController.viewControllers[1];
    if ([detail isKindOfClass:[UINavigationController class]]) {
        detail = [((UINavigationController *)detail).viewControllers firstObject];
    }
    if ([detail isKindOfClass:[TopPhotoTableViewController class]]) {
       [self prepareTopPhotoViewController:detail fromIndexPath:indexPath];
    }
}

- (void)prepareTopPhotoViewController:(TopPhotoTableViewController *)ivc fromIndexPath:(NSIndexPath *)indexPath
{
    Place *place = [self.fetchedResultsController objectAtIndexPath:indexPath];
    ivc.place = place;
    ivc.title = place.name;
}


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

    if ([sender isKindOfClass:[UITableViewCell class]]) {
        // find out which row in which section we're seguing from
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"placeSegue"]) {
                if ([segue.destinationViewController isKindOfClass:[TopPhotoTableViewController class]]) {
                    [self prepareTopPhotoViewController:segue.destinationViewController fromIndexPath:indexPath];
                }
                
            }
        }
    }
}

@end
