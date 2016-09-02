//
//  FollowersViewController.m
//  TwitterTask
//
//  Created by Samar-Mac book on 8/31/16.
//

#import "FollowerTableViewCell.h"
#import "LocalizedMessages.h"
#import "CommonFuntions.h"

@implementation FollowerTableViewCell

@synthesize profileImg;
@synthesize nameTitleLbl;
@synthesize userNameTitleLbl;
@synthesize bioTitleLbl;
@synthesize nameValLbl;
@synthesize userNameValLbl;
@synthesize bioValLbl;
@synthesize SeparatorView;


- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)initWithAccountObj:(AccountObj*)obj withRowId:(int)rowId {
    
    aObj=obj;
    
    nameTitleLbl.text=UserNameText;
    userNameTitleLbl.text=UserUsernameText;
    bioTitleLbl.text=UserBioText;
    
    nameValLbl.text=aObj.fullName;
    userNameValLbl.text=aObj.screenName;
    bioValLbl.text=aObj.description;
    
    profileImg.image=[UIImage imageNamed:@"ProfileImg.png"];
    
    
    nameValLbl.numberOfLines = 1000;
    userNameValLbl.numberOfLines = 1000;
    bioValLbl.numberOfLines = 1000;
    
    
    
    CGRect frame;
    
    frame = nameValLbl.frame;
    CGRect newFrame = nameValLbl.frame;
    CGSize newSize = [nameValLbl sizeThatFits:CGSizeMake(nameValLbl.frame.size.width, MAXFLOAT)];
    newFrame.size = CGSizeMake(fmaxf(newSize.width, nameValLbl.frame.size.width), newSize.height);
    frame.size.height = newFrame.size.height;
    nameValLbl.frame = frame;
    
    frame = nameTitleLbl.frame;
    frame.size.height = nameValLbl.frame.size.height;
    frame.origin.y = nameValLbl.frame.origin.y;
    nameTitleLbl.frame = frame;
    
    frame = userNameValLbl.frame;
    newFrame = userNameValLbl.frame;
    newSize = [userNameValLbl sizeThatFits:CGSizeMake(userNameValLbl.frame.size.width, MAXFLOAT)];
    newFrame.size = CGSizeMake(fmaxf(newSize.width, userNameValLbl.frame.size.width), newSize.height);
    frame.origin.y = nameValLbl.frame.origin.y + nameValLbl.frame.size.height + 5;
    frame.size.height = newFrame.size.height;
    userNameValLbl.frame = frame;
    
    frame = userNameTitleLbl.frame;
    frame.size.height = userNameValLbl.frame.size.height;
    frame.origin.y = userNameValLbl.frame.origin.y;
    userNameTitleLbl.frame = frame;
    
    frame = bioValLbl.frame;
    newFrame = bioValLbl.frame;
    newSize = [bioValLbl sizeThatFits:CGSizeMake(bioValLbl.frame.size.width, MAXFLOAT)];
    newFrame.size = CGSizeMake(fmaxf(newSize.width, bioValLbl.frame.size.width), newSize.height);
    frame.origin.y = userNameValLbl.frame.origin.y + userNameValLbl.frame.size.height + 5;
    frame.size.height = newFrame.size.height;
    bioValLbl.frame = frame;
    
    frame = bioTitleLbl.frame;
    frame.size.height = bioValLbl.frame.size.height;
    frame.origin.y = bioValLbl.frame.origin.y;
    bioTitleLbl.frame = frame;
    
    
    
    
    frame = SeparatorView.frame;
    if ((bioTitleLbl.frame.size.height + bioTitleLbl.frame.origin.y) < 58) {
        frame.origin.y = 57;
    }
    else
    {
        if ([aObj.description length] > 0)
            frame.origin.y = bioValLbl.frame.origin.y + bioValLbl.frame.size.height + 5;
        else
            frame.origin.y = userNameValLbl.frame.origin.y + userNameValLbl.frame.size.height + 5;
    }
    SeparatorView.frame = frame;
    
    NSInteger totalheight = SeparatorView.frame.origin.y + SeparatorView.frame.size.height;
    
    frame = profileImg.frame;
    frame.origin.y = (totalheight - profileImg.frame.size.height) / 2;
    profileImg.frame = frame;

    [self loadProfileImg];

    if (rowId % 2 == 0)
        [self setBackgroundColor:[CommonFuntions getTableCellBGColor_EvenRow]];
    else
        [self setBackgroundColor:[CommonFuntions getTableCellBGColor_OddRow]];
    
    
    
}

-(void)loadProfileImg{
    UIView *blockview = [[UIView alloc] initWithFrame:self.profileImg.frame];
    [blockview setBackgroundColor:[UIColor clearColor]];
    [self.contentView insertSubview:blockview aboveSubview:profileImg];
    
    UIActivityIndicatorView *activityindecator = [[UIActivityIndicatorView alloc] init];
    NSInteger loaderXPox = (blockview.frame.size.width - 20) / 2;
    NSInteger loaderYPox = (blockview.frame.size.height - 20) / 2;
    activityindecator.frame = CGRectMake(loaderXPox, loaderYPox, 20, 20);
    
    [activityindecator startAnimating];
    [activityindecator setColor:[UIColor darkGrayColor]];
    [blockview addSubview:activityindecator];

    NSURL *imageURL;
    imageURL =[NSURL URLWithString:aObj.profileImageUrlHttps];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queue, ^{
        activityindecator.hidden = FALSE;
        NSData *data = [NSData dataWithContentsOfURL:imageURL];
        if (data) {
            UIImage *image = [UIImage imageWithData:data];
            dispatch_async(dispatch_get_main_queue(), ^{
                profileImg.image = image;
            });
            activityindecator.hidden = YES;
        }
        else
            activityindecator.hidden = YES;
    });
}

@end
