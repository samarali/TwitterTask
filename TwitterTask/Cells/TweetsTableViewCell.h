//
//  TweetsTableViewCell.h
//  TwitterTask
//
//  Created by Samar-Mac book on 9/1/16.
//

#import <UIKit/UIKit.h>
#import "TweetObj.h"

@interface TweetsTableViewCell : UITableViewCell{
    TweetObj * tObj;
    
}

@property (nonatomic,retain) IBOutlet UILabel * valueValLbl;
@property (nonatomic,retain) IBOutlet UILabel * creatorNameValLbl;
@property (nonatomic,retain) IBOutlet UILabel * createdAtValLbl;
@property (nonatomic,retain) IBOutlet UIView  * SeparatorView;


-(void)initWithTweetObj:(TweetObj*)obj withRowId:(int)rowId;
@end
