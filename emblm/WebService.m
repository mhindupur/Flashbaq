//
//  WebService.m
//  21Teach
//
//  Created by Sunil.havnur on 1/3/14.
//  Copyright (c) 2014 Vaayoo. All rights reserved.
//

#import "WebService.h"
#import <CommonCrypto/CommonHMAC.h>
#import "NSObject+SBJSON.h"
#import "VSCore.h"

NSString * const Client_ID = @"Dnx5CeRljAvSR4QN540P";
NSString * const Client_Token = @"DP1qoeD44ZPmi1wsuw6Ctq1wQ9xhgnpc";
NSString * const HMAC_Salt_Secret = @"08d1526f8e2478347d68652822111b82";

@implementation WebService
@synthesize alertview,webDelegate;

-(void)SendJSONDataToServer:(NSDictionary *)dataDict toURI:(NSString *)URI forRequestType:(NSString*)type
{
    
    NSString *jsonRequest = [dataDict JSONRepresentation];
    NSLog(@"jsonRequest is %@", jsonRequest);

    //Converting JSON data to NSDATA..
    NSData *postData = [jsonRequest dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    //to fetch content length...
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    
    NSURL *URL = [NSURL URLWithString:URI];
    //create REquest object..
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:1200];
    
    //add HTTP Method Type..
    [request setHTTPMethod:type];
    
    //adding Content type to header..
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    //Adding content length to header..
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    //code taken from EMBLM Document and adding IOS Slart and posting data..

    NSString * parameters = jsonRequest;
    NSString *salt = HMAC_Salt_Secret;
    NSData *saltData = [salt dataUsingEncoding:NSUTF8StringEncoding];
    NSData *paramData = [parameters dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData* hash = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH ];
    CCHmac(kCCHmacAlgSHA256, saltData.bytes, saltData.length, paramData.bytes, paramData.length, hash.mutableBytes);
    NSString *base64Hash = [hash base64Encoding];

    
    //adding HTTP_X_SIGNATURE to header file..
    [request setValue:base64Hash forHTTPHeaderField:@"HTTP_X_SIGNATURE"];
    //End of HTTP_X_SIGNATURE...
    
    //Adding Cache option to header..
    [request setValue:@"no-cache" forHTTPHeaderField:@"Cache-Control"];
    
    //adding Host to header.. taken from document..
    NSString *hostValue=[NSString stringWithFormat:@"%@:@api.emblmapp.com",Client_Token];
    [request setValue:hostValue forHTTPHeaderField:@"Host"];
    
    //Adding Authorization to header file.. taken from document..
    [request setValue:@"Basic RG54NUNlUmxqQXZTUjRRTjU0MFA6RFAxcW9lRDQ0WlBtaTF3c3V3NkN0cTF3UTl4aGducGM=" forHTTPHeaderField:@"Authorization"];
    
    /* */
    BOOL userHasLoggedIn = [[[NSUserDefaults standardUserDefaults] objectForKey:@"isLoginDone"] isEqualToString:@"yes"];
    
    if(userHasLoggedIn)
        
    {
        [request setValue:[VSCore getUserToken] forHTTPHeaderField:@"Token"];

    }
    
    //Addding JSON data to HTTP Body...
    [request setHTTPBody:postData];
    
    
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [theConnection start];
    if (theConnection)
    {
        receivedData=[NSMutableData data] ;
    }
    else
    {
        NSError *error = [NSError alloc];
        NSLog(@"Connection failed! Error - %@ %@",
              [error localizedDescription],
              [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    }

}

-(void)sendGETrequestToservertoURI:(NSString *)URI
{
    NSURL *URL = [NSURL URLWithString:URI];
    //create REquest object..
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:1200];
    
    //add HTTP Method Type..
    [request setHTTPMethod:@"GET"];
    
    //adding Content type to header..
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    //code taken from EMBLM Document and adding IOS Slart and posting data..
    
    NSString *salt = HMAC_Salt_Secret;
    NSData *saltData = [salt dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData* hash = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH ];
    CCHmac(kCCHmacAlgSHA256, saltData.bytes, saltData.length, 0, 0, hash.mutableBytes);
    NSString *base64Hash = [hash base64Encoding];
    
    
    //adding HTTP_X_SIGNATURE to header file..
    [request setValue:base64Hash forHTTPHeaderField:@"HTTP_X_SIGNATURE"];
    //End of HTTP_X_SIGNATURE...
    
    //Adding Cache option to header..
    [request setValue:@"no-cache" forHTTPHeaderField:@"Cache-Control"];
    
    //adding Host to header.. taken from document..
    NSString *hostValue=[NSString stringWithFormat:@"%@:@api.emblmapp.com",Client_Token];
    [request setValue:hostValue forHTTPHeaderField:@"Host"];
    
    //Adding Authorization to header file.. taken from document..
    [request setValue:@"Basic RG54NUNlUmxqQXZTUjRRTjU0MFA6RFAxcW9lRDQ0WlBtaTF3c3V3NkN0cTF3UTl4aGducGM=" forHTTPHeaderField:@"Authorization"];
    
    /* */
    BOOL userHasLoggedIn = [[[NSUserDefaults standardUserDefaults] objectForKey:@"isLoginDone"] isEqualToString:@"yes"];
    
    if(userHasLoggedIn)
        
    {
                [request setValue:[VSCore getUserToken] forHTTPHeaderField:@"Token"];
        
    }
    
    
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [theConnection start];
    if (theConnection)
    {
        receivedData=[NSMutableData data] ;
    }
    else
    {
        NSError *error = [NSError alloc];
        NSLog(@"Connection failed! Error - %@ %@",
              [error localizedDescription],
              [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
        
        if ([webDelegate respondsToSelector:@selector(connectionFailed)])
        {
            [webDelegate connectionFailed];
        }
    }

}

-(void)sendDELETErequestToservertoURI:(NSString *)URI
{
    NSURL *URL = [NSURL URLWithString:URI];
    //create REquest object..
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:1200];
    
    //add HTTP Method Type..
    [request setHTTPMethod:@"DELETE"];
    
    //adding Content type to header..
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    //code taken from EMBLM Document and adding IOS Slart and posting data..
    
    NSString *salt = HMAC_Salt_Secret;
    NSData *saltData = [salt dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData* hash = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH ];
    CCHmac(kCCHmacAlgSHA256, saltData.bytes, saltData.length, 0, 0, hash.mutableBytes);
    NSString *base64Hash = [hash base64Encoding];
    
    
    //adding HTTP_X_SIGNATURE to header file..
    [request setValue:base64Hash forHTTPHeaderField:@"HTTP_X_SIGNATURE"];
    //End of HTTP_X_SIGNATURE...
    
    //Adding Cache option to header..
    [request setValue:@"no-cache" forHTTPHeaderField:@"Cache-Control"];
    
    //adding Host to header.. taken from document..
    NSString *hostValue=[NSString stringWithFormat:@"%@:@api.emblmapp.com",Client_Token];
    [request setValue:hostValue forHTTPHeaderField:@"Host"];
    
    //Adding Authorization to header file.. taken from document..
    [request setValue:@"Basic RG54NUNlUmxqQXZTUjRRTjU0MFA6RFAxcW9lRDQ0WlBtaTF3c3V3NkN0cTF3UTl4aGducGM=" forHTTPHeaderField:@"Authorization"];
    
    /* */
    BOOL userHasLoggedIn = [[[NSUserDefaults standardUserDefaults] objectForKey:@"isLoginDone"] isEqualToString:@"yes"];
    
    if(userHasLoggedIn)
        
    {
        [request setValue:[VSCore getUserToken] forHTTPHeaderField:@"Token"];
        
    }
    
    
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [theConnection start];
    if (theConnection)
    {
        receivedData=[NSMutableData data] ;
    }
    else
    {
        NSError *error = [NSError alloc];
        NSLog(@"Connection failed! Error - %@ %@",
              [error localizedDescription],
              [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
        
        if ([webDelegate respondsToSelector:@selector(connectionFailed)])
        {
            [webDelegate connectionFailed];
        }
    }
    
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    //NSLog(@"didReceiveResponse");
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // append the new data to the receivedData
    //NSLog(@"didReceiveData");
    [receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"connectionDidFinishLoading");
//    NSString *theResponse = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
//  NSLog(@"Response is%@",  theResponse);
    
    NSDictionary *responseDict=[NSJSONSerialization JSONObjectWithData:receivedData options:0 error:nil];
    
    NSLog(@"ResponseDict:%@",responseDict);

     if ([webDelegate respondsToSelector:@selector(responseReceivedwithData:)])
        {
            [webDelegate responseReceivedwithData:responseDict];
        }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
   // NSLog(@"didFailWithError");
    
//    alertview = [[UIAlertView alloc] initWithTitle:@"Error in connection" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//    [alertview show];
    NSLog(@"Connection failed! Error - %@ %@",[error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    
    if ([webDelegate respondsToSelector:@selector(connectionFailed)])
    {
        [webDelegate connectionFailed];
    }
    
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [alertview dismissWithClickedButtonIndex:buttonIndex animated:YES];
}

@end
