//
//  VSCore.m
//  TheLeague
//
//  Created by Kavya Valavala on 5/18/14.
//  Copyright (c) 2014 Vaayoo. All rights reserved.
//

#import "VSCore.h"
#import <CoreMedia/CMTime.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

NSString * const TITLE_FONT = @"Lato-Regular";
NSString * const OTHER_FONT = @"Lato-Bold";
NSString * const Helvetica_Font=@"helvetica-neue-medium";
NSString * const USER_IMAGES = @"userImages";
NSString * const POST = @"POST";
NSString * const PUT = @"PUT";
NSString * const PURPLE_COLOR=@"8734b7";
NSString * const SEA_GREEN=@"0bb2ab";
NSString * const TITLEBAR_COLOR=@"9c76cc";
NSString * const MY_ACCESS_KEY_ID=@"AKIAIUYGOJRUUCSMTD6Q";
NSString * const MY_SECRET_KEY        =@"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";
NSString * const MY_PICTURE_BUCKET        =@"emblmuser";
NSString * const DeviceType             =@"iOS";

//NSString * const RURL        =@"http://content.vaayoo.com/AppsPlatForm/JijiScribleService/JijiScribleService.svc/JijiScribleServiceResponse"; //OLd url

NSString * const RURL        =@"http://content.vaayoo.com/AppsPlatForm/JiJiScribble1_1/JijiScribleService.svc/JijiScribleServiceResponse";
NSString * const AsyncURL     =@"http://content.vaayoo.com/NewContentUpload/ContentUploadToVaayoo.svc/UploadContentToVaayoo";
NSString * const AppDocPath=@"appDocPath";

/* */

NSString * const TrendingEmblem=@"https://api.flashbaq.com/v1/emblms/trending?page=2";
NSString * const Activity=@"https://api.flashbaq.com/v1/users/activity?page=%d";
NSString * const ProfileSetup=@"https://api.flashbaq.com/v1/users/%@";
NSString * const createEmblm=@"https://api.flashbaq.com/v1/emblms";
NSString * const resetPassword=@"https://api.flashbaq.com/v1/users/resetpassword";
NSString * const createPost=@"https://api.flashbaq.com/v1/posts";
NSString * const search    =@"https://api.flashbaq.com/v1/users/search";
NSString * const Followers =@"https://api.flashbaq.com/v1/users/followers/%@";
NSString * const Following =@"https://api.flashbaq.com/v1/users/following/%@?page=%d";
NSString * const NewFollower=@"https://api.flashbaq.com/v1/followers";
NSString * const Unfollow=@"https://api.flashbaq.com/v1/followers/unfollow/%@";
NSString * const MyEmblms=@"https://api.flashbaq.com/v1/emblms/user/%@?page=%d";
NSString * const MyScans=@"https://api.flashbaq.com/v1/emblms/scans/%@?page=%d";
NSString * const Likes=@"https://api.flashbaq.com/v1/posts/likes/%@?page=1";
NSString * const LikePost=@"https://api.flashbaq.com/v1/posts/like/%@";
NSString * const UnlikePost=@"https://api.flashbaq.com/v1/posts/unlike/%@";
NSString * const DeletePost=@"https://api.flashbaq.com/v1/posts/delete/%@";
NSString * const AddScan=@"https://api.flashbaq.com/v1/emblms/addscan";
NSString * const userSettings=@"https://api.flashbaq.com/v1/users/settings";
NSString * const PostComment=@"https://api.flashbaq.com/v1/comments";
NSString * const CommentsList=@"https://api.flashbaq.com/v1/comments/list/%@?page=%@";//PostID & currentpage
NSString * const AddDevice=@"https://api.flashbaq.com/v1/users/adddevice";
NSString * const PostDetails=@"https://api.flashbaq.com/v1/emblms/%@";
NSString * const Notifications=@"https://api.flashbaq.com/v1/users/notifications?page=%d";//GET Request
NSString * const Notification_Count=@"https://api.flashbaq.com/v1/users/notificationcount";//GET Request

@implementation VSCore


+(UIImage*)drawImage:(UIImage*) fgImage
             inImage:(UIImage*) bgImage
             atPoint:(CGPoint)  point
{
    UIGraphicsBeginImageContextWithOptions(bgImage.size, FALSE, 0.0);
    [bgImage drawInRect:CGRectMake( 0, 0, bgImage.size.width, bgImage.size.height)];
    //    [fgImage drawInRect:CGRectMake( point.x, point.y, fgImage.size.width, fgImage.size.height)];
    [fgImage drawInRect:CGRectMake(150,170,90,150)];//35
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}


+ (UIImage*)previewFromFileAtPath:(NSString*)path ratio:(CGFloat)ratio
{
    AVAsset *asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:path]];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    CMTime duration = asset.duration;
    CGFloat durationInSeconds = duration.value / duration.timescale;
    CMTime time = CMTimeMakeWithSeconds(durationInSeconds * ratio, (int)duration.value);
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return thumbnail;
}


+ (void) copyPlistFileFromMainBundle : (NSString *)mainBundlePlistName ToDocumentPath:(NSString *)documentPlistName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSString *dbPath = [self getPlistPath:documentPlistName];
    if(![fileManager fileExistsAtPath:dbPath])
    {
        NSString *defaultDBPath = [[NSBundle mainBundle] pathForResource:mainBundlePlistName ofType:@"plist"];
        BOOL copyResult = [fileManager copyItemAtPath:defaultDBPath toPath:dbPath error:&error];
        if(!copyResult)
            NSAssert1(0, @"Failed to create writable plist file with message '%@'.", [error localizedDescription]);
    }
    
}


+ (void)deletePListwithName:(NSString *)filename {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:filename];
    
    NSError *error;
    if(![[NSFileManager defaultManager] removeItemAtPath:path error:&error])
    {
        //TODO: Handle/Log error
        NSLog(@"failed to delete file");
    }
}

+(NSString *)createandGetPlistwithFileName:(NSString *)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *filename=[NSString stringWithFormat:@"%@.plist",name];
    
    NSString *path = [documentsDirectory stringByAppendingPathComponent:filename]; NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath: path])
    {
        path = [documentsDirectory stringByAppendingPathComponent: filename ];
        NSLog(@"Plist Created With Path : %@",path);
    }
    
    else
    {
        NSLog(@"Error in creating Plist file for Path : %@",path);
    }

    return path;
}
+ (UIColor *)getColor:(NSString *)strHTMLColor withDefault:(UIColor *)defColor
{
	UIColor *clr = defColor;
	if((strHTMLColor != nil) && (![strHTMLColor isEqualToString:@"-1"]))
	{
		unsigned int lColor;
		[[NSScanner scannerWithString:strHTMLColor] scanHexInt:&lColor];
		//= [strHTMLColor intValue];
		clr = [UIColor colorWithRed:((float)((lColor & 0xFF0000) >> 16))/255.0
                              green:((float)((lColor & 0xFF00) >> 8))/255.0
                               blue:((float)(lColor & 0xFF))/255.0
                              alpha:1.0];
	}
	return clr;
}

+ (NSString*) getPlistPath:(NSString*) filename{
    //Search for standard documents using NSSearchPathForDirectoriesInDomains
    //First Param = Searching the documents directory
    //Second Param = Searching the Users directory and not the System
    //Expand any tildes and identify home directories.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    return [documentsDir stringByAppendingPathComponent:filename];
}

+ (void)clearTmpDirectory
{
    NSArray* tmpDirectory = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:NSTemporaryDirectory() error:NULL];
    for (NSString *file in tmpDirectory) {
        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), file] error:NULL];
    }
}

+(void)clearImagesFolder
{
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSArray *fileArray = [fileMgr contentsOfDirectoryAtPath:[VSCore getImagesFolder] error:nil];
    for (NSString *filename in fileArray)  {
        
        [fileMgr removeItemAtPath:[[VSCore getImagesFolder] stringByAppendingPathComponent:filename] error:NULL];
    }

}

+(NSString *)getImagesFolder
{
    NSString *documentFolderPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *imagesFolderPath = [documentFolderPath stringByAppendingPathComponent:@"Images"];
    
    //Check if the images folder already exists, if not, create it!!!
    BOOL isDir;
    NSError *error;
    
    if (([fileManager fileExistsAtPath:imagesFolderPath isDirectory:&isDir] && isDir) == FALSE)
    {
        //            [[NSFileManager defaultManager] createDirectoryAtPath:videosFolderPath attributes:nil];
        [[NSFileManager defaultManager] createDirectoryAtPath:imagesFolderPath withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    return imagesFolderPath;
}

+(NSString *)getVideosFolder
{
    NSString *documentFolderPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *videosFolderPath = [documentFolderPath stringByAppendingPathComponent:@"videos"];
    
    //Check if the videos folder already exists, if not, create it!!!
    BOOL isDir;
    NSError *error;
    
    if (([fileManager fileExistsAtPath:videosFolderPath isDirectory:&isDir] && isDir) == FALSE)
    {
        //            [[NSFileManager defaultManager] createDirectoryAtPath:videosFolderPath attributes:nil];
        [[NSFileManager defaultManager] createDirectoryAtPath:videosFolderPath withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    return videosFolderPath;
}


+(NSString *)getUndoRedoFolder
{
    NSString *documentFolderPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *undoredoFolderPath = [documentFolderPath stringByAppendingPathComponent:@"UndoRedo"];
    
    //Check if the images folder already exists, if not, create it!!!
    BOOL isDir;
    NSError *error;
    
    if (([fileManager fileExistsAtPath:undoredoFolderPath isDirectory:&isDir] && isDir) == FALSE)
    {
        //            [[NSFileManager defaultManager] createDirectoryAtPath:videosFolderPath attributes:nil];
        [[NSFileManager defaultManager] createDirectoryAtPath:undoredoFolderPath withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    return undoredoFolderPath;
}


+(NSString *) getUniqueFileName
{
    NSDate *time = [NSDate date];
    NSDateFormatter* df = [NSDateFormatter new];
    [df setDateFormat:@"MMddyyyyhhmmssSSS"];
    NSString *timeString = [df stringFromDate:time];
    NSString *fileName = [NSString stringWithFormat:@"%@", timeString ];
    return  fileName ;
}

+(void) copyDatabaseIfNeededforFileName :(NSString *)fileName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSString *dbPath = [self getDBPathforFile:fileName];
    NSLog(@"dbpath is %@", dbPath);
    BOOL success = [fileManager fileExistsAtPath:dbPath];
    
    if(!success) {
        
        NSString *defaultDBPath = [[[NSBundle mainBundle ] resourcePath] stringByAppendingPathComponent:fileName];
        
        success = [fileManager copyItemAtPath:defaultDBPath toPath:dbPath error:&error];
        
        if (!success)
            NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
    }
}

+(NSString *) getDBPathforFile:(NSString *)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    
    NSString *DBpath= [documentsDir stringByAppendingPathComponent:fileName];
    
    return DBpath;
}


/* get the application document directory */
+(NSString *)applicationDocumentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

/* utility method, if you actually need to resize an image: */

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+(void)showConnectionFailedAlert
{
    UIAlertView *alrtview=[[UIAlertView alloc] initWithTitle:@"Message" message:@" Connection failed!" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
    [alrtview show];
}
+(BOOL)isCurrentAppDocPath
{
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:AppDocPath] length] >0)
    {
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:AppDocPath] isEqualToString:[VSCore applicationDocumentsDirectory]])
        {
//            NSLog(@"Equal");
            
            return YES;
        }
        else
        {
            return NO;
            
        }
    }
    
    else
        return YES;
}

+(NSString*)getUserToken
{
    [VSCore copyPlistFileFromMainBundle:@"userTokenData" ToDocumentPath:@"userTokenData_m"];
    
    NSMutableDictionary *dict=[NSMutableDictionary dictionaryWithContentsOfFile:[VSCore getPlistPath:@"userTokenData_m"]];
    
    return [dict objectForKey:@"user_token"];
    
}

+(NSString *)getUserID
{
    [VSCore copyPlistFileFromMainBundle:@"userTokenData" ToDocumentPath:@"userTokenData_m"];
    
    NSMutableDictionary *dict=[NSMutableDictionary dictionaryWithContentsOfFile:[VSCore getPlistPath:@"userTokenData_m"]];
    
    return [dict objectForKey:@"id"];
}

/*get the timestamp */

+(NSString *)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *daysdifference = [calendar components:NSCalendarUnitDay
                                               fromDate:fromDate toDate:toDate options:0];
    
    
    [calendar rangeOfUnit:NSCalendarUnitHour startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSCalendarUnitHour startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *hoursdifference = [calendar components:NSCalendarUnitHour
                                                   fromDate:fromDate toDate:toDate options:0];
    
    [calendar rangeOfUnit:NSCalendarUnitMinute startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSCalendarUnitMinute startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *minutesdifference = [calendar components:NSCalendarUnitMinute
                                                    fromDate:fromDate toDate:toDate options:0];
    

    
    NSString *timestampText=nil;
    
    if ([daysdifference day] != 0)
    {
        //NSLog(@"Display Days");
        timestampText=[NSString stringWithFormat:@"%ld day",(long)[daysdifference day]];
    }
    
    else if ([hoursdifference hour] !=1 && [hoursdifference hour] != 0)
    {
       // NSLog(@"Display hours");
        timestampText=[NSString stringWithFormat:@"%ld hr",(long)[hoursdifference hour]];
        
    }
    
    else
    {
        if ([minutesdifference minute] == 0)
        {
            timestampText=@"Just Now";

        }
       else if([minutesdifference minute] >= 60)
      {
          timestampText=@"1 hr";

      }
      else
      {
          timestampText=[NSString stringWithFormat:@"%ld min",(long)[minutesdifference minute]];
      }

    }
    
    return timestampText;
    

}


+(void)setTabBaritemsforvc:(UIViewController *)vc
{
    // Assign tab bar item with titles
    UITabBarController *tabBarController = (UITabBarController *)vc;
    UITabBar *tabBar = tabBarController.tabBar;
//    tabBar.backgroundImage=[UIImage imageNamed:@"toolbarbg"];
    
    tabBarController.selectedIndex=2;
    
    CGRect frame = CGRectMake(0, 0, 400, 148);

    UIView *viewa = [[UIView alloc] initWithFrame:frame];
    UIImage *tabBarBackgroundImage = [UIImage imageNamed:@"toolbarbg"];
    UIColor *color = [[UIColor alloc] initWithPatternImage:tabBarBackgroundImage];
    
    [viewa setBackgroundColor:color];


    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 5)
    {
        [[tabBarController tabBar] insertSubview:viewa atIndex:0];
    }else{
        [[tabBarController tabBar] insertSubview:viewa atIndex:1];
    }
    
    [[UITabBar appearance] setSelectedImageTintColor:[VSCore getColor:SEA_GREEN withDefault:[UIColor blackColor]]];


    [[UITabBarItem appearance] setTitleTextAttributes:@{
                                                        NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:10.0f],
                                                        NSForegroundColorAttributeName : [VSCore getColor:SEA_GREEN withDefault:[UIColor blackColor]],}
                                             forState:UIControlStateSelected];
    
    [[UITabBarItem appearance] setTitleTextAttributes:@{
                                                        NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:10.0f],
                                                        NSForegroundColorAttributeName : [VSCore getColor:SEA_GREEN withDefault:[UIColor blackColor]],}
                                             forState:UIControlStateHighlighted];

    
    UITabBarItem *tabBarItem1 = [tabBar.items objectAtIndex:0];
    UITabBarItem *tabBarItem2 = [tabBar.items objectAtIndex:1];
    UITabBarItem *tabBarItem3 = [tabBar.items objectAtIndex:2];
    UITabBarItem *tabBarItem4 = [tabBar.items objectAtIndex:3];
//    UITabBarItem *tabBarItem5 = [tabBar.items objectAtIndex:4];
    
    [tabBarItem1 setFinishedSelectedImage:[UIImage imageNamed:@"Activity_over"] withFinishedUnselectedImage:[UIImage imageNamed:@"Activity"]];
    
    [tabBarItem2 setFinishedSelectedImage:[UIImage imageNamed:@"My Scans_over"] withFinishedUnselectedImage:[UIImage imageNamed:@"My Scans"]];
    
    [tabBarItem3 setFinishedSelectedImage:[UIImage imageNamed:@"Scan_over"] withFinishedUnselectedImage:[UIImage imageNamed:@"Scan"]];
//    [tabBarItem4 setFinishedSelectedImage:[UIImage imageNamed:@"trending_red.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"trending_plain.png"]];
    [tabBarItem4 setFinishedSelectedImage:[UIImage imageNamed:@"Profile_over"] withFinishedUnselectedImage:[UIImage imageNamed:@"Profile"]];
    
    [[UITabBar appearance] setBackgroundColor:[UIColor blackColor]];
    
}

@end


static const char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";


@implementation NSData (MBBase64)

+ (id)dataWithBase64EncodedString:(NSString *)string;
{
	if (string == nil)
		[NSException raise:@"NSInvalidArgumentException" format:@"nil argument"];
	if ([string length] == 0)
		return [NSData data];
	
	static char *decodingTable = NULL;
	if (decodingTable == NULL)
	{
		decodingTable = malloc(256);
		if (decodingTable == NULL)
			return nil;
		memset(decodingTable, CHAR_MAX, 256);
		NSUInteger i;
		for (i = 0; i < 64; i++)
			decodingTable[(short)encodingTable[i]] = i;
	}
	
	const char *characters = [string cStringUsingEncoding:NSASCIIStringEncoding];
	if (characters == NULL)     //  Not an ASCII string!
		return nil;
	char *bytes = malloc((([string length] + 3) / 4) * 3);
	if (bytes == NULL)
		return nil;
	NSUInteger length = 0;
	
	NSUInteger i = 0;
	while (YES)
	{
		char buffer[4];
		short bufferLength;
		for (bufferLength = 0; bufferLength < 4; i++)
		{
			if (characters[i] == '\0')
				break;
			if (isspace(characters[i]) || characters[i] == '=')
				continue;
			buffer[bufferLength] = decodingTable[(short)characters[i]];
			if (buffer[bufferLength++] == CHAR_MAX)      //  Illegal character!
			{
				free(bytes);
				return nil;
			}
		}
		
		if (bufferLength == 0)
			break;
		if (bufferLength == 1)      //  At least two characters are needed to produce one byte!
		{
			free(bytes);
			return nil;
		}
		
		//  Decode the characters in the buffer to bytes.
		bytes[length++] = (buffer[0] << 2) | (buffer[1] >> 4);
		if (bufferLength > 2)
			bytes[length++] = (buffer[1] << 4) | (buffer[2] >> 2);
		if (bufferLength > 3)
			bytes[length++] = (buffer[2] << 6) | buffer[3];
	}
	
	realloc(bytes, length);
	return [NSData dataWithBytesNoCopy:bytes length:length];
}

- (NSString *)base64Encoding;
{
	if ([self length] == 0)
		return @"";
	
    char *characters = malloc((([self length] + 2) / 3) * 4);
	if (characters == NULL)
		return nil;
	NSUInteger length = 0;
	
	NSUInteger i = 0;
	while (i < [self length])
	{
		char buffer[3] = {0,0,0};
		short bufferLength = 0;
		while (bufferLength < 3 && i < [self length])
			buffer[bufferLength++] = ((char *)[self bytes])[i++];
		
		//  Encode the bytes in the buffer to four characters, including padding "=" characters if necessary.
		characters[length++] = encodingTable[(buffer[0] & 0xFC) >> 2];
		characters[length++] = encodingTable[((buffer[0] & 0x03) << 4) | ((buffer[1] & 0xF0) >> 4)];
		if (bufferLength > 1)
			characters[length++] = encodingTable[((buffer[1] & 0x0F) << 2) | ((buffer[2] & 0xC0) >> 6)];
		else characters[length++] = '=';
		if (bufferLength > 2)
			characters[length++] = encodingTable[buffer[2] & 0x3F];
		else characters[length++] = '=';
	}
	
	return [[NSString alloc] initWithBytesNoCopy:characters length:length encoding:NSASCIIStringEncoding freeWhenDone:YES];
	//	return [[[NSString alloc] initWithBytesNoCopy:characters length:length encoding:NSUTF8StringEncoding freeWhenDone:YES] autorelease];
}

@end


