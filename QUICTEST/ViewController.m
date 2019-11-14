//
//  ViewController.m
//  QUICTEST
//
//  Created by ZhouRong on 2019/10/22.
//  Copyright © 2019 Qiniu. All rights reserved.
//

#import "ViewController.h"
#import "Cronet/Cronet.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [Cronet setHttp2Enabled:YES];
        [Cronet setQuicEnabled:YES];
        [Cronet setHttpCacheType:CRNHttpCacheTypeMemory];
        [Cronet addQuicHint:@"fake-up.qiniup.com" port:443 altPort:443];
        [Cronet setMetricsEnabled:YES];
        [Cronet setBrotliEnabled:YES];
        [Cronet enableTestCertVerifierForTesting];
        [Cronet start];
        [Cronet registerHttpProtocolHandler];
        [Cronet setHostResolverRulesForTesting:@"MAP fake-up.qiniup.com 100.100.56.99:443"];
    });
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    [configuration setHTTPShouldSetCookies:YES];
    [configuration setHTTPCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
    [configuration setHTTPCookieStorage:[NSHTTPCookieStorage sharedHTTPCookieStorage]];
    [Cronet installIntoSessionConfiguration:configuration];
    NSURLSession *_session = [NSURLSession sessionWithConfiguration:configuration];
    NSURL *url = [NSURL URLWithString:@"https://fake-up.qiniup.com/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png"];
    NSURLSessionDataTask *downloadTask = [_session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"** 1: %lu", data.length);
        
        NSURL *url = [NSURL URLWithString:@"https://fake-up-2.qiniup.com/images/branding/googlelogo/2x/googlelogo_color_92x30dp.png"];
        NSURLSessionDataTask *downloadTask2 = [_session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSLog(@"** 2: %lu", data.length);
        }];
        [Cronet setHostResolverRulesForTesting:@"MAP fake-up-2.qiniup.com 100.100.56.99:443"];
        [downloadTask2 resume];
    }];
    [downloadTask resume];
}

@end
