//
//  ApplicationSettings.m
//  Deal Say
//
//  Created by Manjunath hindupur on 23/01/15.
//  Copyright (c) 2015 com.vaayoo. All rights reserved.
//

#import "ApplicationSettings.h"
#import "ScannerViewController.h"

static ApplicationSettings *vas = nil;
@implementation ApplicationSettings
@synthesize userId,iscurrentuserprofile,appLaunchedFirstTime,_isFirsttimeTapped;

+(id) getInstance
{
    if(vas == nil)
    {
        @synchronized(self)
        {
            if(vas == nil)
                vas = [[super allocWithZone:NULL] init];
        }
    }
    return vas;
}

-(id) init
{
    if ((self = [super init] ))
    {
        //DLog(@"Initializing Application Settings");
//        NSString *error;
//        NSPropertyListFormat format;
        
        
       // NSString * directory;
        
     //   directory = [VSCore applicationDocumentsDirectory];
        
     //   NSString *appFile = [directory stringByAppendingPathComponent:@"userpref.plist"];
      //  NSData *data = [[[NSData alloc] initWithContentsOfFile:appFile] autorelease];
        settings = [[NSMutableDictionary alloc] init];
        cacheImages =[[NSMutableDictionary alloc] init];
        iscurrentuserprofile=YES;
        userId=[[NSString alloc]init];
        //appxmlstorage = [[NSMutableDictionary alloc] init];
//        if(data != nil)
//        {
//            [settings  setDictionary:(NSDictionary *) [NSPropertyListSerialization propertyListFromData:data  mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&format errorDescription:&error]];
//        }
//        else
//        {
//            NSString *XMLPath = [[NSBundle mainBundle] pathForResource:@"settings" ofType:@"plist" inDirectory:nil];
//            NSData *myData = [[[NSData alloc] initWithContentsOfFile:XMLPath] autorelease];
//            [settings  setDictionary:(NSDictionary *) [NSPropertyListSerialization propertyListFromData:myData  mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&format errorDescription:&error]];
//        }
        
    }
    
    return self;
}

-(void)setScannerViewController:(ScannerViewController *)vc
{
    scannerVC=vc;
}

-(ScannerViewController *)getScannerViewController
{
    return scannerVC;
}

-(NSMutableDictionary *) getCacheImages
{
    return  cacheImages;
}
-(NSString *)getDeviceToken
{
    return [settings objectForKey:@"devicetoken"];
}

-(NSString *)getUserToken
{
    return [settings objectForKey:@"token"];
}
-(NSString *)getID
{
    return [settings objectForKey:@"ID"];
}

-(BOOL)isLocationEnabled
{
    return [[settings objectForKey:@"IsLocationEnabled"] boolValue];
}

-(BOOL)isNotificationEnabled
{
    return [[settings objectForKey:@"IsNotificationEnabled"] boolValue];
}

-(NSObject *)getAppRoot
{
    return [appxmlstorage objectForKey:@"ApplicationRoot"];
}

-(void) setValue:(id)value forKey:(NSString *)key
{
    [settings setObject:value forKey:key];
    bUpdate = YES;
}
-(void) setappxmlValue:(id)value forKey:(NSString *)key
{
    [appxmlstorage setObject:value forKey:key];
}
-(id) getValue:(NSString *)key
{
    return [settings objectForKey:key];
}



-(void)destroy
{
   // [settings release];
}


@end
