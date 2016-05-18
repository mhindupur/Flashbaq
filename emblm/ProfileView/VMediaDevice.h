//
//  VMediaDevice.h
//  LifeStreamJournal
//
//  Created by Kavya Valavala on 10/8/14.
//  Copyright (c) 2014 com.vaayoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/UTCoreTypes.h>

typedef NS_ENUM(NSInteger, VmediaDeviceType) {
    TypeCamera= 0,//UIImagePickerControllerSourceTypeCamera
    TypeLibrary=1,
} ;

@protocol MediaDeviceDelegate <NSObject>

-(void)imagePickerdidfinishLoadedWithData:(NSDictionary *)mediaData;
-(void)dismissMediaDeviceView;
-(void)imagePickerdidCancelled;
-(void)imagepickerloadedwithTrimmedVideo:(NSDictionary *)videoData;

@end
@interface VMediaDevice : UIViewController
{
    id <MediaDeviceDelegate> deviceDelegate;
}

@property (nonatomic) BOOL isCameraMode;
@property (nonatomic, strong) id <MediaDeviceDelegate> deviceDelegate;
@property (nonatomic) NSInteger                mediaDeviceMode;
@end
