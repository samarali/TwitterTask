//
//  TweetsTableViewCell.m
//  TwitterTask
//
//  Created by Samar-Mac book on 9/1/16.
//

#import "TweetsTableViewCell.h"
#import "LocalizedMessages.h"
#import "CommonFuntions.h"

@implementation TweetsTableViewCell

@synthesize valueValLbl;
@synthesize creatorNameValLbl;
@synthesize createdAtValLbl;
@synthesize SeparatorView;


- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)initWithTweetObj:(TweetObj *)obj withRowId:(int)rowId {
    
    tObj=obj;
    
    createdAtValLbl.text=tObj.createdAt;
    creatorNameValLbl.text=tObj.creatorObj.screenName;
    valueValLbl.text=tObj.value;
    
    createdAtValLbl.numberOfLines = 1000;
    creatorNameValLbl.numberOfLines = 1000;
    valueValLbl.numberOfLines = 1000;
    
    
    
    CGRect frame;
    
    frame = valueValLbl.frame;
    CGRect newFrame = valueValLbl.frame;
    CGSize newSize = [valueValLbl sizeThatFits:CGSizeMake(valueValLbl.frame.size.width, MAXFLOAT)];
    newFrame.size = CGSizeMake(fmaxf(newSize.width, valueValLbl.frame.size.width), newSize.height);
    frame.size.height = newFrame.size.height;
    valueValLbl.frame = frame;
    
    
    frame = createdAtValLbl.frame;
    newFrame = createdAtValLbl.frame;
    newSize = [createdAtValLbl sizeThatFits:CGSizeMake(createdAtValLbl.frame.size.width, MAXFLOAT)];
    newFrame.size = CGSizeMake(fmaxf(newSize.width, createdAtValLbl.frame.size.width), newSize.height);
    frame.origin.y = valueValLbl.frame.origin.y + valueValLbl.frame.size.height + 5;
    frame.size.height = newFrame.size.height;
    createdAtValLbl.frame = frame;
    
    frame = creatorNameValLbl.frame;
    newFrame = creatorNameValLbl.frame;
    newSize = [creatorNameValLbl sizeThatFits:CGSizeMake(creatorNameValLbl.frame.size.width, MAXFLOAT)];
    newFrame.size = CGSizeMake(fmaxf(newSize.width, creatorNameValLbl.frame.size.width), newSize.height);
    frame.origin.y = valueValLbl.frame.origin.y + valueValLbl.frame.size.height + 5;
    frame.size.height = newFrame.size.height;
    creatorNameValLbl.frame = frame;
    
    
    if (createdAtValLbl.frame.size.height > creatorNameValLbl.frame.size.height) {
        frame = creatorNameValLbl.frame;
        frame.size.height = createdAtValLbl.frame.size.height;
        creatorNameValLbl.frame = frame;
    }else{
        frame = createdAtValLbl.frame;
        frame.size.height = creatorNameValLbl.frame.size.height;
        createdAtValLbl.frame = frame;
    }
    
    frame = SeparatorView.frame;
    frame.origin.y = createdAtValLbl.frame.origin.y + createdAtValLbl.frame.size.height + 5;
    SeparatorView.frame = frame;
    
    if (rowId % 2 == 0)
        [self setBackgroundColor:[CommonFuntions getTableCellBGColor_EvenRow]];
    else
        [self setBackgroundColor:[CommonFuntions getTableCellBGColor_OddRow]];
}

@end
