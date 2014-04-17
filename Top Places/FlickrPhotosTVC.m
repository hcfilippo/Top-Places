//
//  FlickrPhotosTVC.m
//  Shutterbug
//
//  Created by CS193p Instructor.
//  Copyright (c) 2013 Stanford University. All rights reserved.
//

#import "FlickrPhotosTVC.h"
#import "FlickrFetcher.h"
#import "TopPhotoTableViewController.h"
#import "AppDelegate.h"
@implementation FlickrPhotosTVC

// whenever our Model is set, must update our View


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self fetchPlaces];
}

- (IBAction)fetchPlaces
{
    [self.refreshControl beginRefreshing]; // start the spinner
    
    NSURL *url = [FlickrFetcher URLforTopPlaces];
    
    // create a (non-main) queue to do fetch on
    dispatch_queue_t fetchQ = dispatch_queue_create("place fetcher", NULL);
    // put a block to do the fetch onto that queue
    dispatch_async(fetchQ, ^{
        // fetch the JSON data from Flickr
        NSData *jsonResults = [NSData dataWithContentsOfURL:url];
        
        // convert it to a Property List (NSArray and NSDictionary)
        NSDictionary *propertyListResults = [NSJSONSerialization JSONObjectWithData:jsonResults
                                                                            options:0
                                                                              error:NULL];
        NSLog(@"Top places : %@",propertyListResults);
        
        // get the NSArray of photo NSDictionarys out of the results
        NSArray *places= [propertyListResults valueForKeyPath:FLICKR_RESULTS_PLACES];
        // update the Model (and thus our UI), but do so back on the main queue
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshControl endRefreshing]; // stop the spinner
            self.places = places;
        });
    });
}


- (void)setPlaces:(NSArray *)places
{
    _places = places;
    if ([self.places count])
    {
        self.countries = [[NSMutableDictionary alloc] init];
        self.countrySectionIDs = [[NSMutableArray alloc] init];
        for (int i = 0; i < [self.places count]; i++)
        {
            NSDictionary *place = self.places[i];
            NSString *str = [NSString stringWithString:[place valueForKey:FLICKR_PLACE_NAME]];
            NSArray *splitStr = [str componentsSeparatedByString:@", "];
            NSString *country = [splitStr lastObject];
            if (![[self.countries allKeys] containsObject:country])
            {
                NSMutableArray *data = [[NSMutableArray alloc] initWithArray:@[place]];
                [self.countries setObject:data forKey:country];
                [self.countrySectionIDs addObject:country];
            }
            else
            {
                NSMutableArray *data = [self.countries objectForKey:country];
                [data addObject:place];
            }
        }

        for (NSString *country in [self.countries allKeys])
        {
            NSMutableArray *data = [self.countries objectForKey:country];
            NSArray *sortArray = [data sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                NSArray *a = [[obj1 valueForKey:@"_content"] componentsSeparatedByString:@", "];
                NSArray *b = [[obj2 valueForKey:@"_content"] componentsSeparatedByString:@", "];
                NSString *aCountry = [a firstObject];
                NSString *bCountry = [b firstObject];
                return [aCountry compare:bCountry];
            }];
            [self.countries setObject:sortArray forKey:country];
        }
        self.countrySectionIDs = (NSMutableArray *)[self.countrySectionIDs sortedArrayUsingSelector:@selector(compare:)];
        
    }
    
    [self.tableView reloadData];
}



#pragma mark - UITableViewDataSource

// the methods in this protocol are what provides the View its data
// (remember that Views are not allowed to own their data)


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.countrySectionIDs objectAtIndex:section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.countries allKeys] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *country = [self.countrySectionIDs objectAtIndex:section];
    return [[self.countries objectForKey:country] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // we must be sure to use the same identifier here as in the storyboard!
    static NSString *CellIdentifier = @"Flickr Place Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSString *country = [self.countrySectionIDs objectAtIndex:indexPath.section];
    NSDictionary *place = [[self.countries objectForKey:country] objectAtIndex:indexPath.row];
    
    
    NSString *str = [NSString stringWithString:[place valueForKey:FLICKR_PLACE_NAME]];
    NSArray *splitStr = [str componentsSeparatedByString:@", "];
    cell.textLabel.text = [splitStr objectAtIndex:0];
    cell.detailTextLabel.text  = [splitStr objectAtIndex:1];
    
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
        NSString *country = [self.countrySectionIDs objectAtIndex:indexPath.section];
        NSDictionary *place = [[self.countries objectForKey:country] objectAtIndex:indexPath.row];
       [self prepareTopPhotoViewController:detail place:place];
    
    }
}

- (void)prepareTopPhotoViewController:(TopPhotoTableViewController *)ivc place:(NSDictionary *)place
{
    ivc.placeID = [place valueForKeyPath:FLICKR_PLACE_ID];
    NSString *str = [NSString stringWithString:[place valueForKey:FLICKR_PLACE_NAME]];
    NSArray *splitStr = [str componentsSeparatedByString:@", "];
    ivc.title = [splitStr firstObject];
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
                    
                    NSString *country = [self.countrySectionIDs objectAtIndex:indexPath.section];
                    NSDictionary *place = [[self.countries objectForKey:country] objectAtIndex:indexPath.row];
                    [self prepareTopPhotoViewController:segue.destinationViewController place:place];
                    
                }
                
            }
        }
    }
}

@end
