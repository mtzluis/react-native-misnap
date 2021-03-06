//
//  RNMisnap.m
//  demoBuro
//
//  Created by LuisAlfredo on 12/02/21.
//  Copyright © 2021 Facebook. All rights reserved.
//


#import "RNMisnap.h"
#import "MiSnapSDKViewController.h"
#import "LivenessViewController.h"
#import "../../../ios/onlinebankingmobile/AppDelegate.h"
///Users/luisalfredo/respaldo-ios/ios/onlinebankingmobile/AppDelegate.h
#import <MiSnapSDK/MiSnapSDK.h>
#import "MiSnapSDKViewControllerUX2.h"
#import "MiSnapSDKViewController.h"

@interface RNMisnap () <MiSnapViewControllerDelegate>

// MiSnap
@property (nonatomic, strong) MiSnapSDKViewController *miSnapController;
@property (nonatomic, strong) NSString *selectedJobType;
@property (strong, nonatomic) MiSnapLivenessCaptureParameters *captureParams;


@end

@implementation RNMisnap


- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(greet: (NSDictionary *)config
    resolver:(RCTPromiseResolveBlock)resolve
    rejecter:(RCTPromiseRejectBlock)reject)
{
    
    NSString *greetText = @"HELLO FROM IOS NATIVE CODE 2";
    NSLog(@"%@",greetText);
//    NSLog(@"%@",[AppDelegate sharedObject].commonString);
    
    cResolver = resolve;
    cRejecter = reject;

    NSLog( @"%@", config );
    if ([config[@"captureType"] isEqualToString:@"idFront"]) {
        self.selectedJobType = kMiSnapDocumentTypeCheckFront;
      } else if ([config[@"captureType"] isEqualToString:@"idBack"]) {
        self.selectedJobType = kMiSnapDocumentTypeCheckBack;
      }
  
    // Do any additional setup after loading the view from its nib.
  self.miSnapController = (MiSnapSDKViewController *)[[UIStoryboard storyboardWithName:@"MiSnapUX2" bundle:nil] instantiateViewControllerWithIdentifier:@"MiSnapSDKViewControllerUX2"];

  self.miSnapController.delegate = self;
    [self.miSnapController setupMiSnapWithParams:[self getMiSnapParameters:config]];
      self.miSnapController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
  if (self.miSnapController != nil) {
          dispatch_async(dispatch_get_main_queue(), ^{
              UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
              if (rootViewController != nil) {
                  [rootViewController presentViewController:self.miSnapController animated:YES completion:nil ];
              }
          });
      } else {
          //reject(@"400", @"Could not create a misnap controller.", [NSError errorWithDomain:@"com.omni.minsnap" code:0 userInfo:@{ @"text": @"MiSnapSDKViewController controller not created." }]);
      }
//    resolve(greetText);
//  resolve(greetText);
    // reject([NSError errorWithDomain:@"com.companyname.app" code:0 userInfo:@{ @"text": @"something happend" }]);
}


#pragma mark - <MiSnapViewControllerDelegate>


-(void)miSnapCancelledWithResults:(NSDictionary *)results
{
    NSMutableDictionary* mibiDataAndImages= [[NSMutableDictionary alloc]init];
    [mibiDataAndImages setObject:@"Cancelled" forKey:@"MiSnapPluginResultCode"];
    
    NSMutableDictionary *resultDic = [[NSMutableDictionary alloc] init];
    NSString *greetText = @"cancel";
    resultDic[@"status"] = greetText;
    cResolver(resultDic);
}

// Called when an image has been captured in either automatic or manual mode
- (void)miSnapFinishedReturningEncodedImage:(NSString *)encodedImage originalImage:(UIImage *)originalImage andResults:(NSDictionary *)results
{
    UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    if (rootViewController != nil) {
        [rootViewController dismissViewControllerAnimated:YES completion: ^{
            NSMutableDictionary *resultDic = [[NSMutableDictionary alloc] init];
            resultDic[@"base64encodedImage"] = encodedImage;
            resultDic[@"metadata"] = results;
            cResolver(resultDic);
        }];
    }
}


- (NSDictionary *)getMiSnapParameters:(NSDictionary *)options
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:[MiSnapSDKViewController defaultParametersForACH]];

    // Must set specific server type and server version
    [parameters setObject:@"test" forKey:kMiSnapServerType];
    [parameters setObject:@"0.0" forKey:kMiSnapServerVersion];

    // LanguageOverride forces only English "en". Uncomment this to enforce just English localization.
    [parameters setObject:@"es" forKey:@"LanguageOverride"];
    [parameters setObject:@"90000" forKey:kMiSnapTimeout];
    [parameters setObject:@"2" forKey:kMiSnapMaxCaptures]; // Shows how to set 3 rather than default 5

    if ([self.selectedJobType isEqualToString:kMiSnapDocumentTypeCheckFront]) { //@"ID_CARD_FRONT"
        parameters = [NSMutableDictionary dictionaryWithDictionary:[MiSnapSDKViewController defaultParametersForCheckFront]];
        [parameters setObject:@"ID Card Front" forKey:kMiSnapShortDescription];
        [parameters setObject:@"0" forKey:kMiSnapTorchMode];
    } else if ([self.selectedJobType isEqualToString:kMiSnapDocumentTypeCheckBack]) { //@"ID_CARD_FRONT"
        parameters = [NSMutableDictionary dictionaryWithDictionary:[MiSnapSDKViewController defaultParametersForCheckBack]];
        [parameters setObject:@"ID Card Back" forKey:kMiSnapShortDescription];
        [parameters setObject:@"0" forKey:kMiSnapTorchMode];
    }

    if (options[@"autocapture"] == NO) {
        [parameters setObject:@"1" forKey:kMiSnapCaptureMode];
    }

    return [parameters copy];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
