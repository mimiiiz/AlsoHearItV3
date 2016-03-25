//
//  DeafTagsPreferenceSelectorTableViewController.m
//  Also Hear It
//
//  Created by Thanachaporn on 2/9/2559 BE.
//  Copyright © 2559 Thanachaporn. All rights reserved.
//
#import "DeafTagsPreferenceSelectorTableViewController.h"
#import "Channel.h"
#import <Parse/Parse.h>
#import "Tag.h"

@interface DeafTagsPreferenceSelectorTableViewController () <UITableViewDelegate>

@end

@implementation DeafTagsPreferenceSelectorTableViewController{
    UIRefreshControl *refreshControl;
    NSMutableArray *selectedTagsPref;
    NSArray *tags;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTags];
    [self setupUI];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupUI {
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"Downloading"];
    self.refreshControl = refreshControl;
    [refreshControl addTarget:self action:@selector(setupTags)
             forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
}

- (void)setupTags {
    selectedTagsPref = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"TagsPref"]];
    PFQuery *query = [Tag query];
    [query fromLocalDatastore];
    [query orderByAscending:@"name"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        tags = [NSArray arrayWithArray:objects];
        [self.tableView reloadData];
        [refreshControl endRefreshing];

    }];
}
- (IBAction)saveButtonTapped:(id)sender {
    [[NSUserDefaults standardUserDefaults] setObject:selectedTagsPref forKey:@"TagsPref"];
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self assignChannel];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return tags.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tagCell2" forIndexPath:indexPath];
    Tag *tmp = [tags objectAtIndex:indexPath.row];
    cell.textLabel.text = tmp.name;
    if ([selectedTagsPref containsObject:tmp.name]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *cellText = selectedCell.textLabel.text;
    if ([selectedTagsPref containsObject:cellText]) {
        [selectedTagsPref removeObject:cellText];
    } else {
        [selectedTagsPref addObject:cellText];
    }
    
    [tableView reloadData];
}

- (void)assignChannel{
    NSString *currentChannelID = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentChannel"];
    PFQuery *query = [Channel query];
    [query whereKey:@"objectId" equalTo:currentChannelID];
    Channel *currentChannel = [query findObjects][0];

    if (currentChannel != NULL) {
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        
        NSMutableArray *Channeltexts = [NSMutableArray array];
        NSCharacterSet *charactersToRemove = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_"] invertedSet];
        for (NSString *tag in selectedTagsPref) {
            NSString *text = [NSString stringWithFormat:@"%@_%@",currentChannel.name, tag];
            text = [[text componentsSeparatedByCharactersInSet:charactersToRemove] componentsJoinedByString:@""];
            [Channeltexts addObject:text];
        }
        [Channeltexts addObject:@"admin"];
        [currentInstallation setObject:Channeltexts forKey:@"channels"];
        [currentInstallation saveInBackground];
    }
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
