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
#import "AppDelegate.h"


@interface TopPhotoTableViewController ()

@end

@implementation TopPhotoTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self fetchPhotos];
}

- (IBAction)fetchPhotos
{
    [self.refreshControl beginRefreshing]; // start the spinner
    //    NSURL *url = [FlickrFetcher URLforRecentGeoreferencedPhotos];
    
    NSURL *url = [FlickrFetcher URLforPhotosInPlace:self.placeID maxResults:50];
    
    // create a (non-main) queue to do fetch on
    dispatch_queue_t fetchQ = dispatch_queue_create("photo fetcher", NULL);
    // put a block to do the fetch onto that queue
    dispatch_async(fetchQ, ^{
        // fetch the JSON data from Flickr
        NSData *jsonResults = [NSData dataWithContentsOfURL:url];
        
        // convert it to a Property List (NSArray and NSDictionary)
        NSDictionary *propertyListResults = [NSJSONSerialization JSONObjectWithData:jsonResults
                                                                            options:0
                                                                              error:NULL];
//        NSLog(@"Top photos : %@",propertyListResults);
        
        // get the NSArray of photo NSDictionarys out of the results
        NSArray *photos= [propertyListResults valueForKeyPath:FLICKR_RESULTS_PHOTOS];
        // update the Model (and thus our UI), but do so back on the main queue
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshControl endRefreshing]; // stop the spinner
            self.photos = photos;
        });
    });
}

- (void) setPhotos:(NSArray *)photos
{
    _photos = photos;
    if ([self.photos count])
    {
        self.photoSectionIDs = [[NSMutableArray alloc] init];
        for (NSDictionary *photo in photos)
        {
            [self.photoSectionIDs addObject:photo];
        }
        self.photoSectionIDs = (NSMutableArray *)[photos sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            if ([[obj1 valueForKey:@"dateupload"] intValue] > [[obj2 valueForKey:@"dateupload"] intValue])
            {
                return NSOrderedAscending;
            }
            else if ([[obj1 valueForKey:@"dateupload"] intValue] < [[obj2 valueForKey:@"dateupload"] intValue])
            {
                return  NSOrderedDescending;
            }
            return NSOrderedSame;
        }];
        
    }
    [self.tableView reloadData];

}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.photoSectionIDs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // we must be sure to use the same identifier here as in the storyboard!
    static NSString *CellIdentifier = @"Flickr Photo Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSDictionary *photo = [self.photoSectionIDs objectAtIndex:indexPath.row];
    
    if ([[photo valueForKey:FLICKR_PHOTO_TITLE] isEqualToString:@""])
    {
        NSString *description = [[photo valueForKey:@"description"] valueForKey:@"_content"];
        if ([description isEqualToString:@""])
        {
            cell.textLabel.text = @"Unknown";
        }
        else {
            cell.textLabel.text = [[photo valueForKey:@"description"] valueForKey:@"_content"];
        }
        cell.detailTextLabel.text = @"";
    }
    else {
        cell.textLabel.text = [photo valueForKey:FLICKR_PHOTO_TITLE];
        cell.detailTextLabel.text  = [[photo valueForKey:@"description"] valueForKey:@"_content"];
    }
    
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id detail = self.splitViewController.viewControllers[1];
    if ([detail isKindOfClass:[UINavigationController class]]) {
        detail = [((UINavigationController *)detail).viewControllers firstObject];
    }
    if ([detail isKindOfClass:[ImageViewController class]]) {
        NSDictionary *photo = [self.photoSectionIDs objectAtIndex:indexPath.row];
        [self prepareImageViewController:detail toDisplayPhoto:photo];
        
    }
}

- (void)prepareImageViewController:(ImageViewController *)ivc toDisplayPhoto:(NSDictionary *)photo
{
    ivc.imageURL = [FlickrFetcher URLforPhoto:photo format:FlickrPhotoFormatLarge];
    if ([[photo valueForKey:FLICKR_PHOTO_TITLE] isEqualToString:@""])
    {
        NSString *description = [[photo valueForKey:@"description"] valueForKey:@"_content"];
        if ([description isEqualToString:@""])
        {
            ivc.title= @"Unknown";
        }
        else {
            ivc.title = [[photo valueForKey:@"description"] valueForKey:@"_content"];
        }
    }
    else {
        ivc.title = [photo valueForKey:FLICKR_PHOTO_TITLE];
    }
    
    [self addPhotoToRecentViewed:photo];
}



- (void)addPhotoToRecentViewed:(NSDictionary *)photo
{
    AppDelegate *myDelegate = [[UIApplication sharedApplication] delegate];
    
    int maxSize = [myDelegate.photos count] >= 20 ? 19 : [myDelegate.photos count];
    for (int i = 0; i < [myDelegate.photos count]; i++)
    {
        if ([photo isEqualToDictionary:[myDelegate.photos objectAtIndex:i]])
        {
            maxSize = i;
            break;
        }
    }
    for (int i = maxSize; i > 0; i--)
    {
        [myDelegate.photos setObject:[myDelegate.photos objectAtIndex:i - 1] atIndexedSubscript:i];
    }
    [myDelegate.photos setObject:photo atIndexedSubscript:0];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:myDelegate.photos forKey:@"history"];
    [ud synchronize];
}




#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"photoSegue"]) {
                if ([segue.destinationViewController isKindOfClass:[ImageViewController class]]) {
                    [self prepareImageViewController:segue.destinationViewController
                                      toDisplayPhoto:self.photoSectionIDs[indexPath.row]];
                   
             //       AppDelegate *myDelegate = [[UIApplication sharedApplication] delegate];
             //       NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
             //       [ud setObject:myDelegate.photos forKey:@"history"];
                }
                
            }
        }
    }
}


@end
