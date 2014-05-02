//
//  PhotosTVC.m
//  Top Places
//
//  Created by hcfilippo on 14-5-2.
//  Copyright (c) 2014年 hcfilippo. All rights reserved.
//

#import "PhotosTVC.h"
#import "ImageViewController.h"
#import "FlickrFetcher.h"
#import "Photo+Flickr.h"
#import "Place.h"

@interface PhotosTVC ()

@end

@implementation PhotosTVC


#pragma mark - Table view data source
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // we must be sure to use the same identifier here as in the storyboard!
    static NSString *CellIdentifier = @"Flickr Photo Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = photo.title;
    cell.detailTextLabel.text = photo.subtitle;
    
    NSURL *thumbnailURL = [NSURL URLWithString:photo.thumbnailURL];
    NSData *imageData = photo.thumbnailImage;
    if (!imageData)
    {
        dispatch_queue_t fetchQ = dispatch_queue_create("download thumbnail", 0);
        dispatch_async(fetchQ, ^{
            NSData *imageData = [[NSData alloc] initWithContentsOfURL:thumbnailURL];
            UIImage *thumbnail =[[UIImage alloc] initWithData:imageData];
            dispatch_async(dispatch_get_main_queue(), ^{
                [photo.managedObjectContext performBlock:^{
                    photo.thumbnailImage = imageData;
                }];
                cell.imageView.image = thumbnail;
                [cell setNeedsLayout];
            });
        });
    } else {
        UIImage *thumbnail =[[UIImage alloc] initWithData:imageData];
        cell.imageView.image = thumbnail;
        [cell setNeedsLayout];
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
        [self prepareImageViewController:detail fromIndexPath:indexPath];
    }
}

- (void)prepareImageViewController:(ImageViewController *)ivc fromIndexPath:(NSIndexPath *)indexPath
{
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    ivc.imageURL = [NSURL URLWithString:photo.imageURL];
    ivc.title = photo.title;
    ivc.navigationItem.leftBarButtonItem.title = ((Place *)photo.whereTook).name;
    [photo.managedObjectContext performBlock:^{
        [self addPhotoToRecentViewed:photo];
    }];
}


- (void)addPhotoToRecentViewed:(Photo *)photo
{
    NSManagedObjectContext *context = photo.managedObjectContext;
    [Photo photoWithID:photo.photoID inManagedObjectContext:context].viewDate = [NSDate date];
    [context updatedObjects];
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
                                       fromIndexPath:indexPath];
                    
                }
                
            }
        }
    }
}



@end
