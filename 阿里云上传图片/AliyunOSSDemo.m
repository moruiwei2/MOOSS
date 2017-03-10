//
//  oss_ios_demo.m
//  oss_ios_demo
//
//  Created by zhouzhuo on 9/16/15.
//  Copyright (c) 2015 zhouzhuo. All rights reserved.
//

#import "AliyunOSSDemo.h"
#import <AliyunOSSiOS/OSSService.h>
#import "UIImageView+WebCache.h"
NSString * const AccessKey = @"*********";
NSString * const SecretKey = @"*****************";
NSString * const endPoint = @"https://oss-cn-beijing.aliyuncs.com";
NSString * const multipartUploadKey = @"multipartUploadObject";


OSSClient * client;
static dispatch_queue_t queue4demo;

@implementation AliyunOSSDemo

+ (instancetype)sharedInstance {
    static AliyunOSSDemo *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [AliyunOSSDemo new];
    });
    // 初始化各种设置
    [instance setupEnvironment];
    return instance;
}
- (void)setupEnvironment {
   // 打开调试log
   [OSSLog enableLog];

   // 在本地生成一些文件用来演示
   [self initLocalFile];

   // 初始化sdk
   [self initOSSClient];
}

- (void)runDemo {
    /*************** 以下每个方法调用代表一个功能的演示，取消注释即可运行 ***************/

    // 罗列Bucket中的Object
    // [self listObjectsInBucket];

    // 异步上传文件
    // [self uploadObjectAsync];

    // 同步上传文件
    // [self uploadObjectSync];

    // 异步下载文件
    // [self downloadObjectAsync];

    // 同步下载文件
    // [self downloadObjectSync];

    // 复制文件
    // [self copyObjectAsync];

    // 签名Obejct的URL以授权第三方访问
    // [self signAccessObjectURL];

    // 分块上传的完整流程
    // [self multipartUpload];

    // 只获取Object的Meta信息
    // [self headObject];

    // 罗列已经上传的分块
    // [self listParts];

    // 自行管理UploadId的分块上传
    // [self resumableUpload];
}

// get local file dir which is readwrite able
- (NSString *)getDocumentDirectory {
    NSString * path = NSHomeDirectory();
    NSLog(@"NSHomeDirectory:%@",path);
    NSString * userName = NSUserName();
    NSString * rootPath = NSHomeDirectoryForUser(userName);
    NSLog(@"NSHomeDirectoryForUser:%@",rootPath);
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}

// create some random file for demo cases
- (void)initLocalFile {
    NSFileManager * fm = [NSFileManager defaultManager];
    NSString * mainDir = [self getDocumentDirectory];

    NSArray * fileNameArray = @[@"file1k", @"file10k", @"file100k", @"file1m", @"file10m", @"fileDirA/", @"fileDirB/"];
    NSArray * fileSizeArray = @[@1024, @10240, @102400, @1024000, @10240000, @1024, @1024];

    NSMutableData * basePart = [NSMutableData dataWithCapacity:1024];
    for (int i = 0; i < 1024/4; i++) {
        u_int32_t randomBit = arc4random();
        [basePart appendBytes:(void*)&randomBit length:4];
    }

    for (int i = 0; i < [fileNameArray count]; i++) {
        NSString * name = [fileNameArray objectAtIndex:i];
        long size = [[fileSizeArray objectAtIndex:i] longValue];
        NSString * newFilePath = [mainDir stringByAppendingPathComponent:name];
        if ([fm fileExistsAtPath:newFilePath]) {
            [fm removeItemAtPath:newFilePath error:nil];
        }
        [fm createFileAtPath:newFilePath contents:nil attributes:nil];
        NSFileHandle * f = [NSFileHandle fileHandleForWritingAtPath:newFilePath];
        for (int k = 0; k < size/1024; k++) {
            [f writeData:basePart];
        }
        [f closeFile];
    }
    NSLog(@"main bundle: %@", mainDir);
}

- (void)initOSSClient {

     id<OSSCredentialProvider> credential2 = [[OSSFederationCredentialProvider alloc] initWithFederationTokenGetter:^OSSFederationToken * {
         
         NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
         
         NSDictionary *dic_token = [def valueForKey:@"alitoken"];
         
         if (dic_token) {
             NSString*string = [[dic_token objectForKey:@"expiration"] substringToIndex:19];
             NSString *qian = [string substringToIndex:10];//截取掉下标2之前的字符串
             NSString *hou = [string substringFromIndex:11];//截取掉下标7之后的字符串
             NSString *str_time = [qian stringByAppendingString:hou];
             
             NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
             [dateFormatter setDateFormat:@"yyyy-MM-ddhh:mm:ss"];
             NSDate *date = [[NSDate alloc] init];
             date = [dateFormatter dateFromString:str_time];
             NSTimeInterval timeInterval = [date timeIntervalSince1970];//因为是格林时间,所以要加8小时28800秒
             
             NSString *currentTimeStamp = [self GetCurrentTimeStamp];
             
             if ([currentTimeStamp longLongValue] > (timeInterval + 28500)) {//减少5分钟300秒缓冲
                 //已经过期了,执行下去获取新的token
             }
             else{//还没过期,获取旧的token
                 OSSFederationToken * token = [OSSFederationToken new];
                 token.tAccessKey = [dic_token objectForKey:@"accessKeyId"];
                 token.tSecretKey = [dic_token objectForKey:@"accessKeySecret"];
                 token.tToken = [dic_token objectForKey:@"securityToken"];
                 token.expirationTimeInGMTFormat = [dic_token objectForKey:@"expiration"];
                 return token;
             }
         }
         
         
         NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@starplan/api/app/getOssToken",@"http://60.205.120.187:6023/"]];
         // 2.创建一个网络请求，分别设置请求方法、请求参数
         NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:url];
         request.HTTPMethod = @"POST";
         NSString *args = [NSString stringWithFormat:@"uid=%@&token=%@",@"25235594078568455",@"FIEoZdgD"];
         request.HTTPBody = [args dataUsingEncoding:NSUTF8StringEncoding];
         OSSTaskCompletionSource * tcs = [OSSTaskCompletionSource taskCompletionSource];
         NSURLSession * session = [NSURLSession sharedSession];
         // 发送请求
         NSURLSessionTask *sessionTask = [session dataTaskWithRequest:request
                                                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                        if (error) {
                                                            [tcs setError:error];
                                                            return;
                                                        }
                                                        [tcs setResult:data];
                                                    }];
         [sessionTask resume];
         // 需要阻塞等待请求返回
         [tcs.task waitUntilFinished];
         // 解析结果
         if (tcs.task.error) {
             NSLog(@"get token error: %@", tcs.task.error);
             return nil;
         } else {
             // 返回数据是json格式，需要解析得到token的各个字段
             NSDictionary * object = [NSJSONSerialization JSONObjectWithData:tcs.task.result
                                                                     options:kNilOptions
                                                                       error:nil];
             
             
             NSDictionary *dic = object[@"data"];
             OSSFederationToken * token = [OSSFederationToken new];
             token.tAccessKey = [dic objectForKey:@"accessKeyId"];
             token.tSecretKey = [dic objectForKey:@"accessKeySecret"];
             token.tToken = [dic objectForKey:@"securityToken"];
             token.expirationTimeInGMTFormat = [dic objectForKey:@"expiration"];
           
             NSLog(@"get token: %@", dic);
             [def setObject:dic forKey:@"alitoken"];
             
             return token;
         }
         
     }];
    
    OSSClientConfiguration * conf = [OSSClientConfiguration new];
    conf.maxRetryCount = 2;
    conf.timeoutIntervalForRequest = 30;
    conf.timeoutIntervalForResource = 24 * 60 * 60;

    client = [[OSSClient alloc] initWithEndpoint:endPoint credentialProvider:credential2 clientConfiguration:conf];
}
- (NSString *)getImageURLWithKey:(NSString *)key
{
    NSString * constrainURL = nil;
    
    OSSTask * task = [client presignConstrainURLWithBucketName:@"arx-picture"
                                                 withObjectKey:key
                                        withExpirationInterval:3600 * 24
                                                withParameters:@{@"x-oss-process": @"image/resize,w_200"}];
    
    if (!task.error) {
        constrainURL = task.result;
    } else {
        NSLog(@"error: %@", task.error);
    }
    NSLog(@"签名后缩略图片Key:-----%@-----", key);
    NSLog(@"签名后缩略图片URL:%@", constrainURL);
    return constrainURL;
}
/**
 *  获取当前时间戳
 */
- (NSString *)GetCurrentTimeStamp
{
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a = [dat timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%f", a];//转为字符型
    return timeString;
}
@end
