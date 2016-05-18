//
//  WebService.h
//  21Teach
//
//  Created by Sunil.havnur on 1/3/14.
//  Copyright (c) 2014 Vaayoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol WebServiceDelegate <NSObject>

-(void)responseReceivedwithData:(NSDictionary*)data;
-(void)connectionFailed;

@end

@interface WebService : NSObject <NSURLConnectionDelegate>
{
    NSMutableData *receivedData;
    id <WebServiceDelegate> webDelegate;
}

@property (nonatomic, strong)  NSMutableString            *response;
@property (nonatomic, retain)  UIAlertView                *alertview;
@property (nonatomic, strong)  id <WebServiceDelegate>   webDelegate;


-(void)SendJSONDataToServer:(NSDictionary *)dataDict toURI:(NSString *)URI forRequestType:(NSString*)type;
-(void)sendGETrequestToservertoURI:(NSString *)URI;
-(void)sendDELETErequestToservertoURI:(NSString *)URI;

@end
