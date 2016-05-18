//
//  StoryCommentCell.h





#import <UIKit/UIKit.h>

static NSString *kCommentsKey   = @"comments";
static NSString *kCommentKey    = @"comment";
static NSString *kTimeKey       = @"created";
static NSString *kLikesCountKey = @"LikesCount";

static NSString *kCellIdentifier = @"storyCellId";

@interface StoryCommentCell : UITableViewCell
+ (void)setTableViewWidth:(CGFloat)tableWidth;
+ (id)storyCommentCellForTableWidth:(CGFloat)width;
+ (CGFloat)cellHeightForComment:(NSString *)comment;
- (void)configureCommentCellForComment:(NSDictionary *)comment;
@end
