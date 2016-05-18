//
//  EmblmCell.m
//  emblm
//
//  Created by Kavya Valavala on 1/6/15.
//  Copyright (c) 2015 Vaayoo. All rights reserved.
//

#import "EmblmCell.h"
#import "VSCore.h"
#import "ApplicationSettings.h"

static CGFloat kDefaultEmblmCellHeight = 465.0f;
static CGFloat static_comnttextwidth = 0;
#define k_lbl_comnttextFont  [UIFont fontWithName:@"Lato-Bold" size:15]

@implementation EmblmCell

- (void)awakeFromNib
{
    _userLikedPost=NO;
    // Initialization code
    _lbl_comnttext.adjustsFontSizeToFitWidth = YES;
    _lbl_userName.adjustsFontSizeToFitWidth=YES;
    _lbl_commentscount.adjustsFontSizeToFitWidth=YES;
    _lbl_timeStamp.adjustsFontSizeToFitWidth=YES;
    _lbl_createdBy.adjustsFontSizeToFitWidth=YES;
    
    CALayer * l = [__profileImage layer];
    [l setMasksToBounds:YES];
    //    [l setCornerRadius:50.0];
    [l setCornerRadius:__profileImage.frame.size.width/2];
    
    _lbl_commentscount.textColor=[UIColor grayColor];
    _lbl_commentscount.textColor=[VSCore getColor:@"acacac" withDefault:[UIColor blackColor]];
    _lbl_commentscount.font=[UIFont fontWithName:OTHER_FONT size:14];

    _lbl_likesCount.textColor=[UIColor grayColor];
    _lbl_likesCount.textColor=[VSCore getColor:@"acacac" withDefault:[UIColor blackColor]];
    _lbl_likesCount.font=[UIFont fontWithName:OTHER_FONT size:14];

    _lbl_comnttext.textColor=[UIColor blackColor];
    _lbl_comnttext.font=[UIFont fontWithName:OTHER_FONT size:15];
    //c63492
    _lbl_userName.textColor=[VSCore getColor:@"c63492" withDefault:[UIColor blackColor]];
    _lbl_userName.font=[UIFont fontWithName:Helvetica_Font size:16];
    
    _lbl_createdBy.textColor=[VSCore getColor:@"c63492" withDefault:[UIColor blackColor]];
    _lbl_createdBy.font=[UIFont fontWithName:OTHER_FONT size:14];
    
    _lbl_createdText.textColor=[VSCore getColor:@"acacac" withDefault:[UIColor blackColor]];
    _lbl_createdText.font=[UIFont fontWithName:OTHER_FONT size:14];

    _lbl_timeStamp.font=[UIFont fontWithName:OTHER_FONT size:16];

    _btn_delete.titleLabel.font = [UIFont fontWithName:OTHER_FONT size:13.0];
    
    static_comnttextwidth=_lbl_comnttext.frame.size.width;
    
//    [[NSBundle mainBundle] loadNibNamed:@"FlashbaqVideoPlayer" owner:self options:nil];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (CGFloat)cellHeightForCommentText:(NSString *)comment
{
    return kDefaultEmblmCellHeight + [EmblmCell heightForComment:comment];
}

+ (CGFloat)heightForComment:(NSString *)comment
{
    CGFloat commentlabelWidth = 320.0;
    
    CGRect textRect = [comment boundingRectWithSize:(CGSize){commentlabelWidth, MAXFLOAT}
                                                        options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                     attributes:@{NSFontAttributeName:k_lbl_comnttextFont}
                                                        context:nil];
    
    CGFloat labelHeight = textRect.size.height;
    return labelHeight;
    
}


- (void)configureEmblmCellForData:(NSDictionary *)dict
{

    NSDictionary *userDict=nil;
    NSString  *createdUsername=nil;

    if ([dict objectForKey:@"emblm"] != nil)
    {
        /*My scans Data */
        
        if ([dict objectForKey:@"scannedby"] != nil)
        {
            userDict=[dict objectForKey:@"scannedby"];
            createdUsername=[[[dict objectForKey:@"emblm"] objectForKey:@"user"] objectForKey:@"username"];
        }
        
        else if ([dict objectForKey:@"scanned_by"] != nil)
        {
            userDict=[dict objectForKey:@"scanned_by"];
            createdUsername=[[[dict objectForKey:@"emblm"] objectForKey:@"user"] objectForKey:@"username"];
        }
        else
        {
            userDict=[[dict objectForKey:@"emblm"]objectForKey:@"user"];
            createdUsername=[userDict objectForKey:@"username"];

        }

        [self bindMyScansDatawithDict:dict];
        
    }
    
    else
    {
        /*My Flashbaqs Data*/
        userDict=[dict objectForKey:@"user"];
        createdUsername=[userDict objectForKey:@"username"];
        [self bindMyEmblmsDatawithDict:dict];
    }
    
    if ([[userDict objectForKey:@"user_image"] length ]> 0)
    {
        NSMutableDictionary *cacheImages =   [[ApplicationSettings getInstance] getCacheImages];
        
        NSString *imgname=[userDict objectForKey:@"user_image"];
        
        if([cacheImages objectForKey:imgname] == nil)
        {
            dispatch_queue_t queue =  dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
            dispatch_async(queue, ^{
                @try {
                    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[userDict objectForKey:@"user_image"]]];
                    UIImage *image= [[UIImage alloc] initWithData:imageData];
                    if(image)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            __profileImage.image= image;
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
            __profileImage.image = [cacheImages objectForKey:imgname];
        }

    }
    else
    {
        __profileImage.image=[UIImage imageNamed:@"profile pics.png"];
        
    }
    
    
    if ([userDict objectForKey:@"created"] != nil)
    {
        _lbl_createdBy.text=createdUsername;
        _lbl_userName.text=[userDict objectForKey:@"username"];

    }
    
    else
    {
        _lbl_createdBy.text=createdUsername;
        _lbl_userName.text=[userDict objectForKey:@"username"];

    }
    
    [self setNeedsLayout];
}

-(void)bindMyScansDatawithDict:(NSDictionary *)dict
{
    if ([dict objectForKey:@"scanned_by"] != nil)
    {
        int milliseconds=[[[dict objectForKey:@"scanned_by"] objectForKey:@"scan_date"] intValue];
        
        _lbl_timeStamp.text=[VSCore daysBetweenDate:[NSDate dateWithTimeIntervalSince1970:milliseconds] andDate:[NSDate date]];
    }
    
    else
    {
        int milliseconds=[[dict objectForKey:@"created" ] intValue];
        
        _lbl_timeStamp.text=[VSCore daysBetweenDate:[NSDate dateWithTimeIntervalSince1970:milliseconds] andDate:[NSDate date]];

    }

    _lbl_comnttext.text=[[dict objectForKey:@"emblm"] objectForKey:@"message"];

    NSString * commentstext=[NSString stringWithFormat:@"%@ Comments",[[dict objectForKey:@"emblm"] objectForKey:@"comment_count"]];
    _lbl_commentscount.text=commentstext;
    
    NSString * likestext=[NSString stringWithFormat:@"%@ Likes",[[dict objectForKey:@"emblm"] objectForKey:@"like_count"]];

    _lbl_likesCount.text=likestext;
    
    if ([[[dict objectForKey:@"emblm"] objectForKey:@"media_preview"] length ]> 0)
    {
        /*  NSURL *url = [NSURL URLWithString:[[dict objectForKey:@"emblm"] objectForKey:@"media_preview"]]; //0 Index will be the Default Profile Picture
         
         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
         NSData *imageData = [NSData dataWithContentsOfURL:url];
         UIImage *image = [UIImage imageWithData:imageData];
         dispatch_async(dispatch_get_main_queue(),
         ^{
         cell.thmbnail_img.image= image;
         });
         });
         
         */
        NSMutableDictionary *cacheImages =   [[ApplicationSettings getInstance] getCacheImages];
        
        NSString *imgname=[[dict objectForKey:@"emblm"] objectForKey:@"media_preview"];
        
        if([cacheImages objectForKey:imgname] == nil)
        {
            dispatch_queue_t queue =  dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
            dispatch_async(queue, ^{
                @try {
                    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imgname]];
                    UIImage *image= [[UIImage alloc] initWithData:imageData];
                    if(image)
                    {
                        dispatch_async(dispatch_get_main_queue(),
                                       ^{
                                           
                            _flashbaqPlayer.previewImageview.image = image ;
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
            
            _flashbaqPlayer.previewImageview.image = [cacheImages objectForKey:imgname];
        }
        
    }
    
    else
    {
//        _thmbnail_img.image=[UIImage imageNamed:@"noPreview.png"];
    }

    if ([[[dict objectForKey:@"emblm"] objectForKey:@"user_liked"] isEqualToString:@"1"])
    {
        _img_like.image=[UIImage imageNamed:@"redlove"];
        _userLikedPost=YES;
    }

    if ([[[dict objectForKey:@"emblm"] objectForKey:@"is_following"] isEqualToString:@"1"])
    {
        _img_follow.image=[UIImage imageNamed:@"Profile_add"];
    }
    
    else
    {
        _img_follow.image=[UIImage imageNamed:@"Profile_add2"];
    }
    
}

-(void)bindMyEmblmsDatawithDict:(NSDictionary *)dict
{
    
   int milliseconds=[[dict objectForKey:@"created"] intValue];
    
    NSDateComponentsFormatter *dateComponentsFormatter = [[NSDateComponentsFormatter alloc] init];
    dateComponentsFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorPad;
    dateComponentsFormatter.allowedUnits = (NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond);
    NSLog(@"%@", [dateComponentsFormatter stringFromTimeInterval:milliseconds]);


//    NSInteger days=[VSCore daysBetweenDate:[NSDate dateWithTimeIntervalSince1970:milliseconds] andDate:[NSDate date]];
    _lbl_timeStamp.text=[VSCore daysBetweenDate:[NSDate dateWithTimeIntervalSince1970:milliseconds] andDate:[NSDate date]];

    _lbl_comnttext.text=[dict objectForKey:@"message"];
    
    NSString *commentstext=[NSString stringWithFormat:@"%@ Comments",[dict objectForKey:@"comment_count"]];
    _lbl_commentscount.text=commentstext;
    
    NSString *likestext=[NSString stringWithFormat:@"%@ Likes",[dict objectForKey:@"like_count"]];

    _lbl_likesCount.text=likestext;
    
    if ([[dict objectForKey:@"media_preview"] length ]> 0)
    {
        /* NSURL *url = [NSURL URLWithString:[dict objectForKey:@"media_preview"]]; //0 Index will be the Default Profile Picture
         
         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
         NSData *imageData = [NSData dataWithContentsOfURL:url];
         UIImage *image = [UIImage imageWithData:imageData];
         dispatch_async(dispatch_get_main_queue(),
         ^{
         cell.thmbnail_img.image= image;
         });
         });
         */
        NSMutableDictionary *cacheImages =   [[ApplicationSettings getInstance] getCacheImages];
        
        NSString *imgname=[dict objectForKey:@"media_preview"];
        
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
                            
                            
                            
                            _flashbaqPlayer.previewImageview.image=image;
//                            _thmbnail_img.image = vidImage ;
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
            _flashbaqPlayer.previewImageview.image = [cacheImages objectForKey:imgname];
        }
        
        
    }
    
    else
    {
//        _thmbnail_img.image=[UIImage imageNamed:@"noPreview.png"];
    }
    
    if ([[dict objectForKey:@"user_liked"] isEqualToString:@"1"])
    {
        _img_like.image=[UIImage imageNamed:@"redlove"];
        _userLikedPost=YES;

    }
    
}

@end
