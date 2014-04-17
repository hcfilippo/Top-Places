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

- (void)viewDidLoad
{
    [super viewDidLoad];    
    [self fetchPhotos];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self fetchPhotos];
}

- (IBAction)fetchPhotos
{
    AppDelegate *myDelegate = [[UIApplication sharedApplication] delegate];
    self.photos = myDelegate.photos;
    [self.refreshControl endRefreshing]; 
}

- (void) setPhotos:(NSArray *)photos
{
    _photos = photos;
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
    return [self.photos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // we must be sure to use the same identifier here as in the storyboard!
    static NSString *CellIdentifier = @"Flickr Photo Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSDictionary *photo = [self.photos objectAtIndex:indexPath.row];
    
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
        NSDictionary *photo = [self.photos objectAtIndex:indexPath.row];
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
                                      toDisplayPhoto:self.photos[indexPath.row]];

                }
            }
        }
    }
}

@end
