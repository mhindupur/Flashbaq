//
//  ApplicationSettings.h
//  Deal Say
//
//  Created by Manjunath hindupur on 23/01/15.
//  Copyright (c) 2015 com.vaayoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSCore.h"
#import "ScannerViewController.h"

@interface ApplicationSettings : NSObject{
NSMutableDictionary *settings;
NSMutableDictionary *appxmlstorage;
    NSMutableDictionary *cacheImages;
    ScannerViewController    *scannerVC;
    BOOL bUpdate;
}

@property (nonatomic, strong) NSString *userId;
@property (nonatomic)         BOOL      iscurrentuserprofile;
@property (nonatomic)         BOOL      appLaunchedFirstTime;
@property (nonatomic)         BOOL      _isFirsttimeTapped;
+(id)getInstance;
-(NSMutableDictionary *) getCacheImages;
-(NSString *)getID;

-(void) destroy;
-(void) setValue:(id)value forKey:(NSString *)key;

-(id) getValue:(NSString *)key;


-(BOOL)isLocationEnabled;
-(BOOL)isNotificationEnabled;
-(NSString *)getDeviceToken;
-(NSString *)getUserToken;
-(void)setScannerViewController:(ScannerViewController *)vc;
-(ScannerViewController *)getScannerViewController;

@end
