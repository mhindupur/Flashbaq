//
//  VMediaDevice.m
//  LifeStreamJournal
//
//  Created by Kavya Valavala on 10/8/14.
//  Copyright (c) 2014 com.vaayoo. All rights reserved.
//

#import "VMediaDevice.h"
#import "VSCore.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVAsset.h>
#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVVideoComposition.h>
#import <AVFoundation/AVAssetExportSession.h>
#import <AVFoundation/AVMediaFormat.h>
#import <CoreMedia/CMTime.h>

@interface VMediaDevice ()<UIImagePickerControllerDelegate>
{
    AVAssetExportSession *exporter;
    NSString *exportPath;
}

@end

@implementation VMediaDevice
@synthesize isCameraMode,deviceDelegate, mediaDeviceMode;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor =[UIColor clearColor];
   
       // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
   
}

-(void)viewDidAppear:(BOOL)animated
{
    
    [self performSelector:@selector(showcamera) withObject:nil afterDelay:0.3];

   
}

-(void)showcamera
{
    if (isCameraMode)
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        
        if (mediaDeviceMode == 0)
        {
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;

        }
        
        else
        {
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        
        [self presentViewController:picker animated:YES completion:NULL];
    }
    
    else /*Video Mode */
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        
        if (mediaDeviceMode == 0)
        {
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            
        }
        
        else
        {
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }

        picker.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeMovie];
        picker.videoQuality = UIImagePickerControllerQualityTypeMedium; // sunil added on 18th may 2013
        picker.videoMaximumDuration = 30;
        
        [self presentViewController:picker animated:YES completion:NULL];
        
    }

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)downloadTrimmedVideo:(NSURL *)url anddismissPicker:(UIImagePickerController *)vc
{
    NSMutableDictionary *mediaObjDict=[[NSMutableDictionary alloc]init];

    NSMutableString *filePath = [[NSMutableString alloc] initWithFormat:@"%@", [VSCore getImagesFolder]];
    NSMutableString *filename = [NSMutableString stringWithFormat:@"%@.mp4",[VSCore getUniqueFileName]];
    NSString *file = [filePath stringByAppendingPathComponent:filename];

    NSData *trimmedvideoData = [NSData dataWithContentsOfURL:url];
    
    if (![trimmedvideoData writeToFile:file atomically:YES]) {
        //DLog (@"There was a problem writing the image %@", file);
    }
    else
    {
        [mediaObjDict setObject:[file lastPathComponent] forKey:@"filename"];
        [mediaObjDict setObject:file forKey:@"filepath"];
        
    }


    if ([deviceDelegate respondsToSelector:@selector(imagepickerloadedwithTrimmedVideo:)])
    {
        [deviceDelegate imagepickerloadedwithTrimmedVideo:mediaObjDict];
    }
    
    if ([deviceDelegate respondsToSelector:@selector(dismissMediaDeviceView)])
    {
//        [self dismissViewControllerAnimated:YES completion:nil];
        [deviceDelegate dismissMediaDeviceView];

    }
    
}

- (void) CropVideoSquareforurl:(NSURL *)videourl{
    
    //load our movie Asset
    AVAsset *asset = [AVAsset assetWithURL:videourl];
    
    
    //create an avassetrack with our asset
    AVAssetTrack *clipVideoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    
    //create a video composition and preset some settings
    AVMutableVideoComposition* videoComposition = [AVMutableVideoComposition videoComposition];
    videoComposition.frameDuration = CMTimeMake(1, 30);
    //here we are setting its render size to its height x height (Square)
    videoComposition.renderSize = CGSizeMake(clipVideoTrack.naturalSize.height, clipVideoTrack.naturalSize.height);
    
    //create a video instruction
    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(60, 30));
    
    AVMutableVideoCompositionLayerInstruction* transformer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:clipVideoTrack];
    
    //Here we shift the viewing square up to the TOP of the video so we only see the top
//    CGAffineTransform t1 = CGAffineTransformMakeTranslation(clipVideoTrack.naturalSize.height, 0 );
    
    //Use this code if you want the viewing square to be in the middle of the video
    CGAffineTransform t1 = CGAffineTransformMakeTranslation(clipVideoTrack.naturalSize.height, -(clipVideoTrack.naturalSize.width - clipVideoTrack.naturalSize.height) /2 );
    
    //Make sure the square is portrait
    CGAffineTransform t2 = CGAffineTransformRotate(t1, M_PI_2);
    
//    CGAffineTransform t1 = CGAffineTransformIdentity;
//    CGAffineTransform t2 = CGAffineTransformIdentity;
  
    /*kavya made changes */
    
  /*   UIImageOrientation videoOrientation = [self getVideoOrientationFromAsset:asset];

    
    switch (videoOrientation) {
        case UIImageOrientationUp:
          t1 = CGAffineTransformMakeTranslation(clipVideoTrack.naturalSize.height, -(clipVideoTrack.naturalSize.width - clipVideoTrack.naturalSize.height) /2 );
          t2 = CGAffineTransformRotate(t1, M_PI_2);
            break;
        case UIImageOrientationDown:
           t1 = CGAffineTransformMakeTranslation(clipVideoTrack.naturalSize.height, -(clipVideoTrack.naturalSize.width - clipVideoTrack.naturalSize.height) /2 );
            t2 = CGAffineTransformRotate(t1, - M_PI_2);
            break;
        case UIImageOrientationRight:
            t1 = CGAffineTransformMakeTranslation(0 - clipVideoTrack.naturalSize.height, 0 - (clipVideoTrack.naturalSize.width - clipVideoTrack.naturalSize.height) /2 );
            t2 = CGAffineTransformRotate(t1, 0 );
            break;
        case UIImageOrientationLeft:
             t1 = CGAffineTransformMakeTranslation(clipVideoTrack.naturalSize.height, -(clipVideoTrack.naturalSize.width - clipVideoTrack.naturalSize.height) /2 );
            t2 = CGAffineTransformRotate(t1, M_PI);
            break;
        default:
            NSLog(@"no supported orientation has been found in this video");
            break;
    }
 */
    
    CGAffineTransform finalTransform = t2;
    [transformer setTransform:finalTransform atTime:kCMTimeZero];
    
    //add the transformer layer instructions, then add to video composition
    instruction.layerInstructions = [NSArray arrayWithObject:transformer];
    videoComposition.instructions = [NSArray arrayWithObject: instruction];
    
    //Create an Export Path to store the cropped video
    NSMutableString *filePath = [[NSMutableString alloc] initWithFormat:@"%@", [VSCore getVideosFolder]];
    NSMutableString *filename = [NSMutableString stringWithFormat:@"%@_%@.mp4",[VSCore getUserID],[VSCore getUniqueFileName]];
    exportPath = [filePath stringByAppendingPathComponent:filename];
    NSURL *exportUrl = [NSURL fileURLWithPath:exportPath];
    
    //Remove any prevouis videos at that path
    [[NSFileManager defaultManager]  removeItemAtURL:exportUrl error:nil];
    
    //Export
    exporter = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetMediumQuality] ;
    exporter.videoComposition = videoComposition;
    exporter.outputURL = exportUrl;
    exporter.outputFileType = AVFileTypeMPEG4;
    
    [exporter exportAsynchronouslyWithCompletionHandler:^
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             //Call when finished
             [self exportDidFinish:exporter];
         });
     }];
}


- (void)exportDidFinish:(AVAssetExportSession*)session
{
    NSMutableDictionary *mediaObjDict=[[NSMutableDictionary alloc]init];

    //Play the New Cropped video
    NSURL *outputURL = session.outputURL;
    
    NSData *trimmedvideoData = [NSData dataWithContentsOfURL:outputURL];
    
    if (![trimmedvideoData writeToFile:exportPath atomically:YES]) {
        NSLog (@"There was a problem writing the image %@", exportPath);
    }
    else
    {
        [mediaObjDict setObject:[exportPath lastPathComponent] forKey:@"filename"];
        [mediaObjDict setObject:exportPath forKey:@"filepath"];
        
    }

    
    if ([deviceDelegate respondsToSelector:@selector(imagepickerloadedwithTrimmedVideo:)])
    {
        [deviceDelegate imagepickerloadedwithTrimmedVideo:mediaObjDict];
    }
    
    if ([deviceDelegate respondsToSelector:@selector(dismissMediaDeviceView)])
    {
        //        [self dismissViewControllerAnimated:YES completion:nil];
        [deviceDelegate dismissMediaDeviceView];
        
    }

//    self.mPlayer = [AVPlayer playerWithPlayerItem:newPlayerItem];
//    [mPlayer addObserver:self forKeyPath:@"status" options:0 context:AVPlayerDemoPlaybackViewControllerStatusObservationContext];
    
}

#pragma mark UIImagePickerControllerDelegate Methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{

    NSMutableDictionary *mediaObjDict=[[NSMutableDictionary alloc]init];
    
    if ([[info valueForKey:@"UIImagePickerControllerMediaType"] isEqualToString:@"public.image"])
    {
        
        UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
        
        CGSize newSize = CGSizeMake(320, 427);
        
        UIGraphicsBeginImageContext( newSize );// a CGSize that has the size you want
        [chosenImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
        //image is the original UIImage
        UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        ////remove above this line once the 8192 problem is fixed
        
        //store the image as a jpeg file
        NSData *imD = [NSData dataWithData:UIImageJPEGRepresentation(newImage, 1.0f)];
        
        NSMutableString *filePath = [[NSMutableString alloc] initWithFormat:@"%@", [VSCore getImagesFolder]];
        NSMutableString *filename = [NSMutableString stringWithFormat:@"%@_%@.jpg",[VSCore getUserID],[VSCore getUniqueFileName]];
        NSString *file = [filePath stringByAppendingPathComponent:filename];
    
        
        if (![imD writeToFile:file atomically:YES])
        {
            NSLog(@"There was a problem writing the image %@", file);
        }
        else
        {
            [mediaObjDict setObject:[file lastPathComponent] forKey:@"filename"];
            [mediaObjDict setObject:file forKey:@"filepath"];
        }
        
        
        if ([deviceDelegate respondsToSelector:@selector(imagePickerdidfinishLoadedWithData:)])
        {
            [deviceDelegate imagePickerdidfinishLoadedWithData:mediaObjDict];
        }
        
        
        if ([deviceDelegate respondsToSelector:@selector(dismissMediaDeviceView)])
        {
            [picker dismissViewControllerAnimated:YES completion:NULL];
            [deviceDelegate dismissMediaDeviceView];
            
        }

    }
    
    else if ([[info valueForKey:@"UIImagePickerControllerMediaType"] isEqualToString:@"public.movie"])
    {
        
        NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
        
        [self CropVideoSquareforurl:videoURL];
//        NSData *videoData = [NSData dataWithContentsOfURL:videoURL];
       /* NSMutableString *filePath = [[NSMutableString alloc] initWithFormat:@"%@", [VSCore getVideosFolder]];
        NSMutableString *filename = [NSMutableString stringWithFormat:@"%@_%@.mp4",[VSCore getUniqueFileName],[VSCore getUserID]];
        NSString *file = [filePath stringByAppendingPathComponent:filename];
                picker.videoQuality=UIImagePickerControllerQualityTypeLow;
//
        NSData *trimmedvideoData = [NSData dataWithContentsOfURL:videoURL];
        
                if (![trimmedvideoData writeToFile:file atomically:YES]) {
                    NSLog (@"There was a problem writing the image %@", file);
                }
                else
                {
                    [mediaObjDict setObject:[file lastPathComponent] forKey:@"filename"];
                    [mediaObjDict setObject:file forKey:@"filepath"];
                    
                } */

        /* */
        
      /*   NSNumber *start = [info objectForKey:@"_UIImagePickerControllerVideoEditingStart"];
        NSNumber *end = [info objectForKey:@"_UIImagePickerControllerVideoEditingEnd"];        
        
        int startMilliseconds = ([start doubleValue] * 1000);
        int endMilliseconds = ([end doubleValue] * 1000);
        
        
        AVURLAsset *videoAsset = [AVURLAsset URLAssetWithURL:videoURL options:nil];
        
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:videoAsset presetName:AVAssetExportPresetHighestQuality];
        exportSession.outputURL = [NSURL fileURLWithPath:file];
        exportSession.outputFileType = AVFileTypeQuickTimeMovie;
        CMTimeRange timeRange = CMTimeRangeMake(CMTimeMake(startMilliseconds, 1000), CMTimeMake(endMilliseconds - startMilliseconds, 1000));
        exportSession.timeRange = timeRange;
        
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch (exportSession.status) {
                case AVAssetExportSessionStatusCompleted:
                    // Custom method to import the Exported Video
                    NSLog(@"%@",exportSession.outputURL);
                    
                    [mediaObjDict setObject:[file lastPathComponent] forKey:@"filename"];
                    [mediaObjDict setObject:file forKey:@"filepath"];
                    
                    if ([deviceDelegate respondsToSelector:@selector(imagepickerloadedwithTrimmedVideo:)])
                    {
                        [deviceDelegate imagepickerloadedwithTrimmedVideo:mediaObjDict];
                    }
                    
                    if ([deviceDelegate respondsToSelector:@selector(dismissMediaDeviceView)])
                    {
                        //        [self dismissViewControllerAnimated:YES completion:nil];
                        [deviceDelegate dismissMediaDeviceView];
                        
                    }

//                    [self downloadTrimmedVideo:exportSession.outputURL anddismissPicker:picker];
//                    [self loadAssetFromFile:exportSession.outputURL];
                    break;
                case AVAssetExportSessionStatusFailed:
                    //
                    NSLog(@"Failed:%@",exportSession.error);
                    break;
                case AVAssetExportSessionStatusCancelled:
                    //
                    NSLog(@"Canceled:%@",exportSession.error);
                    break;
                default:
                    break;
            }
        }];
       /* */
        
//        NSData *trimmedvideoData = [NSData dataWithContentsOfURL:exportSession.outputURL];
//
//        if (![trimmedvideoData writeToFile:file atomically:YES]) {
//            //DLog (@"There was a problem writing the image %@", file);
//        }
//        else
//        {
//            [mediaObjDict setObject:[file lastPathComponent] forKey:@"filename"];
//            [mediaObjDict setObject:file forKey:@"filepath"];
//            
//        }
    }
    
  /*  if ([deviceDelegate respondsToSelector:@selector(imagePickerdidfinishLoadedWithData:)])
    {
        [deviceDelegate imagePickerdidfinishLoadedWithData:mediaObjDict];
    }

    
    if ([deviceDelegate respondsToSelector:@selector(dismissMediaDeviceView)])
    {
        [picker dismissViewControllerAnimated:YES completion:NULL];
        [deviceDelegate dismissMediaDeviceView];
        
    }
   */
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
//    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    if ([deviceDelegate respondsToSelector:@selector(imagePickerdidCancelled)])
    {
        [picker dismissViewControllerAnimated:YES completion:NULL];

        [deviceDelegate imagePickerdidCancelled];
    }

}

- (UIImageOrientation)getVideoOrientationFromAsset:(AVAsset *)asset
{
    AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    CGSize size = [videoTrack naturalSize];
    CGAffineTransform txf = [videoTrack preferredTransform];
    
    if (size.width == txf.tx && size.height == txf.ty)
        return UIImageOrientationLeft; //return UIInterfaceOrientationLandscapeLeft;
    else if (txf.tx == 0 && txf.ty == 0)
        return UIImageOrientationRight; //return UIInterfaceOrientationLandscapeRight;
    else if (txf.tx == 0 && txf.ty == size.width)
        return UIImageOrientationDown; //return UIInterfaceOrientationPortraitUpsideDown;
    else
        return UIImageOrientationUp;  //return UIInterfaceOrientationPortrait;
}


@end
