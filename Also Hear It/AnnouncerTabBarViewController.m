//
//  AnnouncerTabBarViewController.m
//  Also Hear It
//
//  Created by Thanachaporn on 1/26/2559 BE.
//  Copyright © 2559 Thanachaporn. All rights reserved.
//

#import "AnnouncerTabBarViewController.h"

@interface AnnouncerTabBarViewController () <UITabBarDelegate>

@end

@implementation AnnouncerTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    if(item.tag == 2){
        UIStoryboard* storyborad = [UIStoryboard storyboardWithName:@"Announcer" bundle:nil];
        UIViewController* viewcontroller = [storyborad instantiateViewControllerWithIdentifier:@"Message"];
        [self presentViewController:viewcontroller animated:YES completion:nil];
    }
} 

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
