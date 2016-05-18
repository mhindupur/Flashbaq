//
//  StoryCommentCell.m
//  


#import "StoryCommentCell.h"
#import "VSCore.h"
#import "ApplicationSettings.h"

@interface StoryCommentCell ()
@property (weak, nonatomic) IBOutlet UIImageView *commentAuthorIcon;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentsLikesCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;

@property (nonatomic) NSDictionary *comment;
@end

static CGFloat kPaddingDist = 8.0f;
static CGFloat kDefaultCommentCellHeight = 40.0f;
static CGFloat kTableViewWidth = -1;
static CGFloat kStandardButtonSize = 40.0f;
static CGFloat kStandardLabelHeight = 20.0f;

#define kCommentCellFont  [UIFont fontWithName:@"Lato-Regular" size:14]

@implementation StoryCommentCell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)layoutSubviews
{
    NSLog(@"Calling layoutSubviews");
    
    NSString *comment = self.comment[kCommentKey];
    CGFloat cellHeight = [StoryCommentCell heightForComment:comment];
    CGRect frame = self.commentLabel.frame;
    frame.size.height = cellHeight;
    self.commentLabel.frame = frame;
    
    frame = self.commentDateLabel.frame;
    frame.origin.x = self.usernameLabel.frame.origin.x + self.usernameLabel.frame.size.width + kPaddingDist;
    frame.origin.y = self.commentAuthorIcon.frame.origin.y;
    self.commentDateLabel.frame = frame;
    
    frame = self.commentsLikesCountLabel.frame;
    frame.origin.x = self.likeButton.frame.origin.x - kPaddingDist - self.commentsLikesCountLabel.frame.size.width;
    frame.origin.y = self.commentDateLabel.frame.origin.y;
    self.commentsLikesCountLabel.frame = frame;
    
    frame = self.likeButton.frame;
    frame.origin.y = self.contentView.frame.origin.y + self.contentView.frame.size.height - frame.size.height - kPaddingDist;
    self.likeButton.frame = frame;
    [super layoutSubviews];
}

#pragma mark -
#pragma mark Interface

+ (void)setTableViewWidth:(CGFloat)tableWidth
{
    kTableViewWidth = tableWidth;
}

+ (id)storyCommentCellForTableWidth:(CGFloat)width
{
    StoryCommentCell *cell = [[StoryCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
    
    CGRect cellFrame = cell.frame;
    cellFrame.size.width = width;
    cell.frame = cellFrame;
    
    //Left AuthorIconView
    UIImageView *authOrIconView = [[UIImageView alloc] initWithFrame:CGRectMake(kPaddingDist, kPaddingDist, kStandardButtonSize, kStandardButtonSize)];
    authOrIconView.image = [UIImage imageNamed:@"profilePic_small.jpg"];
    authOrIconView.contentMode = UIViewContentModeScaleAspectFill;
    [cell addSubview:authOrIconView];
    cell.commentAuthorIcon = authOrIconView;

    CALayer * l = [authOrIconView layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:authOrIconView.frame.size.width/2];

    
    //Like Button
//    UIButton *likeButton = [[UIButton alloc] initWithFrame:CGRectMake(cell.bounds.size.width - (kPaddingDist + kStandardButtonSize), kPaddingDist, kStandardButtonSize, 38)];
//    [likeButton setImage:[UIImage imageNamed:@"likeIcon"] forState:UIControlStateNormal];
//    [cell addSubview:likeButton];
//    cell.likeButton = likeButton;
    
    UILabel *userName = [[UILabel alloc] initWithFrame:CGRectMake(authOrIconView.frame.origin.x+authOrIconView.frame.size.width+kPaddingDist, authOrIconView.frame.origin.y , 200,kStandardLabelHeight)];
    userName.font = [UIFont fontWithName:OTHER_FONT size:14.0];
    userName.textColor = [VSCore getColor:@"c63492" withDefault:[UIColor blackColor]];
    userName.textAlignment = NSTextAlignmentLeft;
    userName.text=@"John Abraham";
    cell.usernameLabel = userName;
    [cell addSubview:userName];
    
    UILabel *commentDatelabe = [[UILabel alloc] initWithFrame:CGRectMake(userName.frame.origin.x+userName.frame.size.width+50, authOrIconView.frame.origin.y , 50,kStandardLabelHeight)];
    commentDatelabe.font = [UIFont fontWithName:TITLE_FONT size:10.0];
    commentDatelabe.textColor = [UIColor grayColor];
    commentDatelabe.textAlignment = NSTextAlignmentLeft;
    cell.commentDateLabel = commentDatelabe;
    [cell addSubview:commentDatelabe];

    CGRect labelRect = CGRectMake(userName.frame.origin.x,
                                  30,
                                  300,
                                  kStandardLabelHeight);
    UILabel *commentlabe = [[UILabel alloc] initWithFrame:labelRect];
    commentlabe.font = [UIFont fontWithName:TITLE_FONT size:12.0];
    commentlabe.textColor = [UIColor darkGrayColor];
    commentlabe.textAlignment = NSTextAlignmentLeft;
    commentlabe.numberOfLines = 0;
    commentlabe.lineBreakMode = NSLineBreakByWordWrapping;
    commentlabe.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    cell.commentLabel = commentlabe;
    [cell addSubview:commentlabe];

    //Comment Label
  /*  CGRect labelRect = CGRectMake(authOrIconView.frame.origin.x + authOrIconView.frame.size.width + kPaddingDist,
                                  authOrIconView.frame.origin.y,
                                  likeButton.frame.origin.x - (kPaddingDist * 3 + authOrIconView.frame.size.width),
                                  kStandardLabelHeight);
    UILabel *commentlabe = [[UILabel alloc] initWithFrame:labelRect];
    commentlabe.font = kCommentCellFont;
    commentlabe.textColor = [UIColor darkGrayColor];
    commentlabe.textAlignment = NSTextAlignmentLeft;
    commentlabe.numberOfLines = 0;
    commentlabe.lineBreakMode = NSLineBreakByWordWrapping;
    commentlabe.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    cell.commentLabel = commentlabe;
    [cell addSubview:commentlabe];
   */
    
    //commentDateLabel;
  /*  UILabel *commentDatelabe = [[UILabel alloc] initWithFrame:CGRectMake(commentlabe.frame.origin.x, commentlabe.frame.origin.y + commentlabe.frame.size.height + kPaddingDist, commentlabe.frame.size.width, commentlabe.frame.size.height)];
    commentDatelabe.font = [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:10];
    commentDatelabe.textColor = [UIColor grayColor];
    commentDatelabe.textAlignment = NSTextAlignmentLeft;
    cell.commentDateLabel = commentDatelabe;
    [cell addSubview:commentDatelabe];
   */
    
    return cell;
}

+ (CGFloat)cellHeightForComment:(NSString *)comment
{
    return kDefaultCommentCellHeight + [StoryCommentCell heightForComment:comment];
}

+ (CGFloat)heightForComment:(NSString *)comment
{
    CGFloat height = 0.0;
    CGFloat commentlabelWidth = kTableViewWidth - 2 * (kStandardButtonSize + kPaddingDist);
    CGRect rect = [comment boundingRectWithSize:(CGSize){commentlabelWidth, MAXFLOAT}
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                     attributes:@{NSFontAttributeName:kCommentCellFont}
                                        context:nil];
    
    
    height = rect.size.height;
    return height;
}

- (void)configureCommentCellForComment:(NSDictionary *)comment
{
    self.comment = comment;
    self.commentLabel.text = comment[kCommentKey];
//    self.commentDateLabel.text = comment[kTimeKey];
    
    int milliseconds=[[comment objectForKey:kTimeKey] intValue];
    
//    NSInteger days=[VSCore daysBetweenDate:[NSDate dateWithTimeIntervalSince1970:milliseconds] andDate:[NSDate date]];
    self.commentDateLabel.text=[VSCore daysBetweenDate:[NSDate dateWithTimeIntervalSince1970:milliseconds] andDate:[NSDate date]];

    
    self.commentsLikesCountLabel.text = comment[kLikesCountKey];
    self.usernameLabel.text=[[self.comment objectForKey:@"from"] objectForKey:@"username"];
    
    NSMutableDictionary *cacheImages =   [[ApplicationSettings getInstance] getCacheImages];
    
    NSString *imgname=[[self.comment objectForKey:@"from"] objectForKey:@"user_image"];
    
    if([cacheImages objectForKey:imgname] == nil)
    {
        dispatch_queue_t queue =  dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        dispatch_async(queue, ^{
            @try {
                NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imgname]];
                UIImage *image= [[UIImage alloc] initWithData:imageData];
                if(image)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.commentAuthorIcon.image = image ;
                        [cacheImages setObject:image forKey:imgname];
                    });
                }
            }
            @catch (NSException *exception) {
            }
            @finally {
            }
        });
    }
    else
    {
        self.commentAuthorIcon.image = [cacheImages objectForKey:imgname];
    }
    

    
    [self setNeedsLayout];
}

#pragma mark -
#pragma mark Private


@end
