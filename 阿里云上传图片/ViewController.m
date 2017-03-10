//
//  ViewController.m
//  阿里云上传图片
//
//  Created by 莫瑞伟 on 17/2/10.
//  Copyright © 2017年 莫瑞伟. All rights reserved.
//

#import "ViewController.h"
#import <AliyunOSSiOS/AliyunOSSiOS.h>
#import "SDWebImageManager.h"
#import "AliDemo.h"

@interface ViewController ()

//@property (weak, nonatomic) IBOutlet UIImageView *imageView_icon;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
    AliDemo *vc = [AliDemo new];
    
    [self.navigationController pushViewController:vc animated:YES];
    
}


@end
