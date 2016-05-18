//
//  VSCore.h
//  TheLeague
//
//  Created by Kavya Valavala on 5/18/14.
//  Copyright (c) 2014 Vaayoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern NSString * const TITLE_FONT;
extern NSString * const OTHER_FONT;
extern NSString * const Helvetica_Font;
extern NSString * const USER_IMAGES;
extern NSString * const PURPLE_COLOR;
extern NSString * const SEA_GREEN;
extern NSString * const TITLEBAR_COLOR;
extern NSString * const MY_ACCESS_KEY_ID;
extern NSString * const MY_SECRET_KEY;
extern NSString * const MY_PICTURE_BUCKET;
extern NSString * const createEmblm;
extern NSString * const RURL;
extern NSString * const AsyncURL;
extern NSString * const AppDocPath;
extern NSString * const TrendingEmblem;
extern NSString * const Activity;
extern NSString * const ProfileSetup;
extern NSString * const resetPassword;
extern NSString * const createPost;
extern NSString * const MyEmblms;
extern NSString * const MyScans;
extern NSString * const search;
extern NSString * const Followers;
extern NSString * const Following;
extern NSString * const Likes;
extern NSString * const LikePost;
extern NSString * const UnlikePost;
extern NSString * const NewFollower;
extern NSString * const DeletePost;
extern NSString * const Unfollow;
extern NSString * const AddScan;
extern NSString * const userSettings;
extern NSString * const PostComment;
extern NSString * const CommentsList;
extern NSString * const POST;
extern NSString * const PUT;
extern NSString * const AddDevice;
extern NSString * const DeviceType;
extern NSString * const PostDetails;
extern NSString * const Notifications;
extern NSString * const Notification_Count;

@interface VSCore : NSObject
{
    
}

+(UIImage*)drawImage:(UIImage*) fgImage
             inImage:(UIImage*) bgImage
             atPoint:(CGPoint)  point;
+(UIColor *)getColor:(NSString *)strHTMLColor withDefault:(UIColor *)defColor;

+ (void) copyPlistFileFromMainBundle : (NSString *)mainBundlePlistName ToDocumentPath:(NSString *)documentPlistName;
+ (NSString*) getPlistPath:(NSString*) filename;

+(NSString *)getImagesFolder;
+(NSString *)getVideosFolder;
+(NSString *) getUniqueFileName;
+(NSString *)applicationDocumentsDirectory;
+(void) copyDatabaseIfNeededforFileName :(NSString *)fileName;
+(NSString *) getDBPathforFile:(NSString *)fileName;
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
+(BOOL)isCurrentAppDocPath;
+(NSString *)getUndoRedoFolder;
+(NSString*)getUserToken;
+(NSString *)getUserID;
+ (void)deletePListwithName:(NSString *)filename;
+(NSString *)createandGetPlistwithFileName:(NSString *)name;
+(void)showConnectionFailedAlert;
+ (NSString*)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime;
+(void)setTabBaritemsforvc:(UIViewController *)vc;
+ (UIImage*)previewFromFileAtPath:(NSString*)path ratio:(CGFloat)ratio;
+ (void)clearTmpDirectory;
+(void)clearImagesFolder;

@end


@interface NSData (MBBase64)
+ (id)dataWithBase64EncodedString:(NSString *)string;     //  Padding '=' characters are optional. Whitespace is ignored.
- (NSString *)base64Encoding;

@end