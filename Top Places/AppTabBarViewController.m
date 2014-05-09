//
//  AppTabBarViewController.m
//  Top Places
//
//  Created by hcfilippo on 14-5-8.
//  Copyright (c) 2014年 hcfilippo. All rights reserved.
//

#import "AppTabBarViewController.h"

@interface AppTabBarViewController ()

@end

@implementation AppTabBarViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    if ([item.title isEqualToString:@"Top Place"])
    {
        [item setImage:[UIImage imageNamed:@"place_solid"]];
    }
    else {
        for (UITabBarItem* barItems in [tabBar items])
        {
            if ([barItems.title isEqualToString:@"Top Place"])
            {
                [barItems setImage:[UIImage imageNamed:@"place_hollow"]];
                break;
            }
        }
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
