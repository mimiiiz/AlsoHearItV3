//
//  PushViewController.m
//  Also Hear It
//
//  Created by Thanachaporn on 10/6/2558 BE.
//  Copyright © 2558 Thanachaporn. All rights reserved.
//
#import <Parse/Parse.h>

#import "AnnouncerMessageViewController.h"
#import "AnnouncerSettingTableViewController.h"
#import "TagSelectorTableViewController.h"

#import "ASUser.h"
#import "Channel.h"
#import "Message.h"
#import "Tag.h"



@interface AnnouncerMessageViewController () <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;

@property (weak, nonatomic) IBOutlet UITextView *inputTextView;
@property (strong, nonatomic) IBOutlet UILabel *labelName;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraints;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UILabel *tagLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;

@end

@implementation AnnouncerMessageViewController{
    ASUser *currentUser;
    Channel *announcerChannel;
    NSArray *tags;
    NSMutableArray *tagIndex;
    NSMutableArray *channelnameWithTag;
    NSMutableArray *tagSelected;
    NSMutableArray *tagsSelected;
    NSString *textFromInput;
    NSString *tagfornotification;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupData];
    [self.loadingView stopAnimating];
}
-(void)viewWillDisappear:(BOOL)animated{
    [self.view endEditing:NO];
    
}
-(void)viewWillAppear:(BOOL)animated{
    
}
-(void) setupData {
    currentUser = [ASUser currentUser];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *objectId = [userDefault stringForKey:@"announcerChannelId"];
    PFQuery *queryChannel =[PFQuery queryWithClassName:@"Channel"];
    [queryChannel fromLocalDatastore];
    [queryChannel getObjectInBackgroundWithId:objectId block:^(PFObject *object, NSError *error){
        announcerChannel =(Channel *) object;
        [self setupUI];

    }];
    PFQuery *queryTag =[PFQuery queryWithClassName:@"Tag"];
    [queryTag fromLocalDatastore];
    [queryTag orderByAscending:@"name"];
    [queryTag findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if(!error){
            tags = [NSArray arrayWithArray:objects];
        }
    }];
}

-(void) setupUI {
    self.inputTextView.delegate = self;
    self.labelName.text = announcerChannel.name;
    PFFile *imageFile = announcerChannel.channelPic;
    [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        self.profileImage.image = [UIImage imageWithData:data];
    }];

    self.sendButton.backgroundColor = [UIColor lightGrayColor];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    [UIView animateWithDuration:0.1f animations:^{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];}];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    

}

-(void)dismissKeyboard {
    [self.inputTextView resignFirstResponder];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeButtonTapped:(id)sender {
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)attachButtonTapped:(id)sender {
    
}

-(void)setChannelsStringWithSelectedTags{
    channelnameWithTag = [[NSMutableArray alloc] init];
    for (NSDictionary *tmpTag in tagsSelected){
        NSString *text = [NSString stringWithFormat:@"%@_%@",announcerChannel.name, [tmpTag objectForKey:@"name"]];
        NSCharacterSet *charactersToRemove = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_"] invertedSet];
        text = [[text componentsSeparatedByCharactersInSet:charactersToRemove] componentsJoinedByString:@""];
        NSLog(@"%@",text);
        [channelnameWithTag addObject:text];
    }
}

- (IBAction)tagButtonTapped:(id)sender {
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Announcer" bundle:nil];
    TagSelectorTableViewController *selector = [storyboard instantiateViewControllerWithIdentifier:@"tagSelector"];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:selector];
    selector.tagDelegate = self;
    [selector setTags:tags];
    [selector setTagIndex:tagIndex];

    [self presentViewController:nav animated:YES completion:nil];
}

- (void)addTagMessage:(NSMutableArray *)tag{
    NSString *tagText = @"";
    tagIndex = [NSMutableArray arrayWithArray:tag];

    [self getTagsSelectedFromTagIndex];
    [self getSelectedTagsFromTagIndex];
    for (NSDictionary *currentTag in tagsSelected) {
        if([tagText isEqualToString:@""]){
            tagText = [tagText stringByAppendingString:[currentTag objectForKey:@"name"]];
        }else{
            tagText = [tagText stringByAppendingString:@", "];
            tagText = [tagText stringByAppendingString:[currentTag objectForKey:@"name"]];
        }
    }
    self.tagLabel.text = tagText;
    [self changeSendButtonState];
}

- (void)getTagsSelectedFromTagIndex{
    tagsSelected = [[NSMutableArray alloc] init];
    for (NSIndexPath *tmp in tagIndex) {
        Tag *tmpTag = [tags objectAtIndex:tmp.row];
        NSMutableDictionary *tagDictionary = [[NSMutableDictionary alloc] init];
        [tagDictionary setObject:tmpTag.name forKey:@"name"];
        [tagDictionary setObject:tmpTag.priority forKey:@"priority"];
        [tagsSelected addObject:tagDictionary];
    }
}

- (void)getSelectedTagsFromTagIndex{
    tagSelected = [NSMutableArray array];
    for (NSIndexPath *tmp in tagIndex) {
        Tag *tmpTag = [tags objectAtIndex:tmp.row];
        [tagSelected addObject:tmpTag];
    }
}

- (IBAction)sendButtonTapped:(id)sender {
    [self setAnimationLoading:YES];
    
    textFromInput = self.inputTextView.text;
    [self setChannelsStringWithSelectedTags];
    [self savingPushNotificationToMessage];
}

-(void) savingPushNotificationToMessage{
    Message *pushMessage = [Message object];
    pushMessage.text = textFromInput;
    pushMessage.channel = announcerChannel;
    NSMutableArray *Channeltexts = [NSMutableArray array];
    NSCharacterSet *charactersToRemove = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_"] invertedSet];
    
    pushMessage.tags = tagsSelected;
    PFRelation *relation = [pushMessage relationForKey:@"tag"];
    for (Tag *tagTmp in tagSelected) {
        [relation addObject:tagTmp];
        NSString *text = [NSString stringWithFormat:@"%@_%@",announcerChannel.name, tagTmp.name];
        text = [[text componentsSeparatedByCharactersInSet:charactersToRemove] componentsJoinedByString:@""];
        [Channeltexts addObject:text];
    }
    PFRelation *receiverRelation = [pushMessage relationForKey:@"receiver"];
    PFQuery *userQuery = [ASUser query];
    [userQuery whereKey:@"channels" containedIn:Channeltexts];
    NSArray *users = [userQuery findObjects];
    for (ASUser *tmp in users) {
        [receiverRelation addObject:tmp];
    }
    
    [pushMessage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            // The object has been saved.
            [self sendPushNotification];
        }
    }];
}

-(void) sendPushNotification{
    PFPush *push = [[PFPush alloc] init];
    [push setChannels:channelnameWithTag];
    NSString *pushText = textFromInput;
    if (textFromInput.length >200) {
        pushText = [textFromInput substringToIndex:200];
    }
    [push setMessage:pushText];
    [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error){
        if (succeeded) {
            NSLog(@"sendpushnotification");
            [self setAnimationLoading:NO];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    [self placeholderShowing:textView];
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    [self placeholderShowing:textView];
    [textView resignFirstResponder];
}

- (void)placeholderShowing:(UITextView *)textView{
    if ([textView.text isEqualToString:@"Write somethings..."]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor]; //optional
    }else if ([textView.text isEqualToString:@""]) {
        textView.text = @"Write somethings...";
        textView.textColor = [UIColor lightGrayColor]; //optional
        [self.sendButton setEnabled:NO];
        self.sendButton.backgroundColor = [UIColor lightGrayColor];
        //self.sendButton.backgroundColor = [UIColor colorWithRed:3.0/255.0 green:204.0/255.0 blue:153.0/255.0 alpha:1];
    }
}

- (void)textViewDidChange:(UITextView *)textView{
    [self changeSendButtonState];
}

-(void)changeSendButtonState {
    if (tagIndex.count >0){
        self.tagLabel.textColor = [UIColor colorWithRed:3.0/255.0 green:204.0/255.0 blue:153.0/255.0 alpha:1];
    }
    if (tagIndex.count >0 && (self.inputTextView.text.length > 0 && self.inputTextView.text > 0  )){
        [self.sendButton setEnabled:YES];
        self.sendButton.backgroundColor = [UIColor colorWithRed:3.0/255.0 green:204.0/255.0 blue:153.0/255.0 alpha:1];
    }else{
        if (tagIndex.count == 0) {
            self.tagLabel.text = @"Please Select at least one tag";
            self.tagLabel.textColor = [UIColor redColor];
        }
        [self.sendButton setEnabled:NO];
        self.sendButton.backgroundColor = [UIColor lightGrayColor];

    }
}

-(void)keyboardDidShow:(NSNotification*)notification {
    CGFloat height = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].size.height;
    self.bottomConstraints.constant = height;
    [self.view layoutIfNeeded];
}

-(void)keyboardDidHide:(NSNotification*)notification{
    self.bottomConstraints.constant = 0.0;
    [self.view layoutIfNeeded];
}

- (void) setAnimationLoading:(BOOL) setting{
    if (setting) {
        [self.loadingView startAnimating];
        self.loadingView.layer.backgroundColor = [[UIColor colorWithWhite:0.0f alpha:0.25f] CGColor];
        self.loadingView.frame = self.view.bounds;
        if (![[UIApplication sharedApplication] isIgnoringInteractionEvents]) {
            [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        }
    } else {
        if ([self.loadingView isAnimating]) {
            [self.loadingView stopAnimating];
        }
        if ([[UIApplication sharedApplication] isIgnoringInteractionEvents]) {
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        }
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