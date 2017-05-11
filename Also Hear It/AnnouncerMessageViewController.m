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



@interface AnnouncerMessageViewController () <UITextViewDelegate, UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UIImageView *attachImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageConstraints;
@property (weak, nonatomic) IBOutlet UIView *errorView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;

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
    [self.inputTextView becomeFirstResponder];
    [self changeSendButtonState];
    self.progressBar.hidden = YES;

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
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* camerarollAction = [UIAlertAction actionWithTitle:@"Camera Roll" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [self selectPhoto];}];
    
    UIAlertAction* cameraAction = [UIAlertAction actionWithTitle:@"Take a Picture" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [self takePhoto];}];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction * action) {}];
    [alert addAction:camerarollAction];
    [alert addAction:cameraAction];
    [alert addAction:cancelAction];

    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)takePhoto {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
    
}

- (void)selectPhoto {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
//    NSLog(@"%f, %f",screenWidth, screenHeight);
//    NSLog(@"%f, %f",chosenImage.size.width, chosenImage.size.height);

    
    self.imageConstraints.constant = (chosenImage.size.height/chosenImage.size.width)*(screenWidth-20);

    self.attachImage.image = chosenImage;

    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

-(UIImage*)imageWithImage: (UIImage*) sourceImage scaledToWidth: (float) i_width
{
    float oldWidth = sourceImage.size.width;
    float scaleFactor = i_width / oldWidth;
    
    float newHeight = sourceImage.size.height * scaleFactor;
    float newWidth = oldWidth * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
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
    self.progressBar.hidden = NO;
    self.progressBar.progress = 0.1;
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
    self.progressBar.progress = 0.3;

    for (ASUser *tmp in users) {
        [receiverRelation addObject:tmp];
    }
    
    NSData* data = UIImageJPEGRepresentation(self.attachImage.image, 0.0f);
    
    if (data == nil) {
        NSLog(@"no image");
    }else{
        //[self scaleImageWithData:imageData proportionallyToSize:CGSizeMake(500, 500)];
        PFFile *imageFile = [PFFile fileWithName:@"image.png" data:data];
        pushMessage.image = imageFile;
        self.progressBar.progress = 0.5;

    }
    [pushMessage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            // The object has been saved.
            self.progressBar.progress = 0.7;

            [self sendPushNotification];
        }
    }];
    
    [self setAnimationLoading:NO];
    self.progressBar.progress = 1.0;
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (UIImage *)scaleImage:(UIImage *)originalImage toSize:(CGSize)size
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, colorSpace, kCGImageAlphaPremultipliedLast);
    CGContextClearRect(context, CGRectMake(0, 0, size.width, size.height));
    
    if (originalImage.imageOrientation == UIImageOrientationRight) {
        CGContextRotateCTM(context, -M_PI_2);
        CGContextTranslateCTM(context, -size.height, 0.0f);
        CGContextDrawImage(context, CGRectMake(0, 0, size.height, size.width), originalImage.CGImage);
    } else {
        CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height), originalImage.CGImage);
    }
    
    CGImageRef scaledImage = CGBitmapContextCreateImage(context);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    UIImage *image = [UIImage imageWithCGImage:scaledImage];
    CGImageRelease(scaledImage);
    
    return image;
}

- (CGSize)estimateNewSize:(CGSize)newSize forImage:(UIImage *)image
{
    if (image.size.width > image.size.height) {
        newSize = CGSizeMake((image.size.width/image.size.height) * newSize.height, newSize.height);
    } else {
        newSize = CGSizeMake(newSize.width, (image.size.height/image.size.width) * newSize.width);
    }
    
    return newSize;
}

- (UIImage *)scaleImage:(UIImage *)image proportionallyToSize:(CGSize)newSize
{
    return [self scaleImage:image toSize:[self estimateNewSize:newSize forImage:image]];
}
            
- (UIImage *)scaleImageWithData:(NSData *)imageData proportionallyToSize:(CGSize)newSize
{
    UIImage *image = [UIImage imageWithData:imageData]; // image was unknown
    return [self scaleImage:[UIImage imageWithData:imageData] toSize:[self estimateNewSize:newSize forImage:image]];
}

-(void) sendPushNotification{
//    PFPush *push = [[PFPush alloc] init];
//    [push setChannels:channelnameWithTag];
//    NSLog(@"CT: %@", channelnameWithTag); //array
//    NSLog(@"an Name: %@", announcerChannel.name); //nal name
    NSString *pushText = [NSString stringWithFormat:@"%@ | %@",announcerChannel.name ,textFromInput];
    if (textFromInput.length >200) {
        pushText = [textFromInput substringToIndex:200];
    }
//    [push setMessage:pushText];
//    [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error){
//        if (succeeded) {
//            NSLog(@"sendpushnotification");
//            [self setAnimationLoading:NO];
//            self.progressBar.progress = 1.0;
//            [self dismissViewControllerAnimated:YES completion:nil];
//        }
//    }];
    
    [PFCloud callFunctionInBackground:@"pushMessage" withParameters:@{@"message": pushText, @"channels": channelnameWithTag}];
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
        //[self.loadingView startAnimating];
        //self.loadingView.layer.backgroundColor = [[UIColor colorWithWhite:0.0f alpha:0.25f] CGColor];
        //self.loadingView.frame = self.view.bounds;
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
