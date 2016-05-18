//
//  igViewController.h
//  ScanBarCodes
//
//  Created by Torrey Betts on 10/10/13.
//  Copyright (c) 2013 Infragistics. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScannerViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIImageView     *overlayGraphicView;
@property (nonatomic, strong) NSMutableDictionary      *postDatadict;
@property (nonatomic, strong) IBOutlet UIBarButtonItem  *notifbaritem;
@end