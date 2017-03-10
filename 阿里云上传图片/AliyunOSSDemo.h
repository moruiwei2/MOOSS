//
//  oss_ios_demo.h
//  oss_ios_demo
//
//  Created by zhouzhuo on 9/16/15.
//  Copyright (c) 2015 zhouzhuo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AliyunOSSDemo.h"

typedef void (^OSSNetworkingUploadProgressBlock) (int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend);

@interface AliyunOSSDemo : NSObject

+ (instancetype)sharedInstance;


- (void)setupEnvironment;

- (void)runDemo;

- (void)uploadObjectAsyncWithData:(NSData *)data WithName:(NSString *)name progress:(OSSNetworkingUploadProgressBlock)progress succeedBlock:(void (^)(id responseObject))succeedBlock failure:(void (^)(NSError *error))failure;

- (void)downloadImageWithURL:(NSString *)url progress:(OSSNetworkingUploadProgressBlock)progress completed:(void (^)(UIImage *image, NSError *error))completedBlock;

- (NSString *)getImageURLWithKey:(NSString *)key;

- (void)resumableUpload;
@end
