//
//  TagSelectorTableViewController.m
//  Also Hear It
//
//  Created by Thanachaporn on 1/30/2559 BE.
//  Copyright © 2559 Thanachaporn. All rights reserved.
//

#import "TagSelectorTableViewController.h"
#import "Tag.h"

@interface TagSelectorTableViewController () <UITableViewDelegate>


@end

@implementation TagSelectorTableViewController{
    NSArray *tags;
    NSMutableArray *tagIndex;
}

@synthesize tagDelegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpData];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated{
    
}

- (void)setUpData {

}

-(void)setTags:(NSArray *)tagsData {
    tags = [NSArray arrayWithArray:tagsData];
}

-(void)setTagIndex:(NSMutableArray *)indexData {
    tagIndex = [NSMutableArray arrayWithArray:indexData];
}

- (IBAction)saveButtonTapped:(id)sender {
    [self sendTagIndexBack];
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)sendTagIndexBack {
    if([self.tagDelegate respondsToSelector:@selector(addTagMessage:)]) {
        [self.tagDelegate addTagMessage:tagIndex];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return tags.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tagCell" forIndexPath:indexPath];
    Tag *tmp = [tags objectAtIndex:indexPath.row];
    cell.textLabel.text = tmp.name;
    if ([tagIndex containsObject:indexPath]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([tagIndex containsObject:indexPath]) {
        [tagIndex removeObject:indexPath];
    }
    else {
        [tagIndex addObject:indexPath];

    }
    
    [tableView reloadData];
}

@end
