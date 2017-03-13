//
//  AliDemo.m
//  爱任信
//
//  Created by 莫瑞伟 on 17/2/22.
//  Copyright © 2017年 moyejin. All rights reserved.
//

#import "AliDemo.h"
#import "AliyunOSSDemo.h"
#import "UIImageView+WebCache.h"

@interface AliDemo ()

@property (weak, nonatomic) IBOutlet UITableView *tableView_main;

@end

@implementation AliDemo
- (NSArray *)getImageWithStr:(NSString *)str
{
    if (str == nil || str.length == 0) {
        return @[];
    }
    if (str.length > 2 && [[str substringFromIndex:str.length-1] isEqualToString:@","]) {
        str = [str substringToIndex:str.length - 1];
    }
    //将字符串分割成数组
    NSMutableArray *arr_image = [NSMutableArray arrayWithArray:[str componentsSeparatedByString:@","]];
    
    return arr_image;
}
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    
    NSArray *arr_image = [self getImageWithStr:@"14007995524440068/I14889597591w=300.00h=300.00,14007995524440068/I14889597602w=125.00h=90.00,14007995524440068/I14889597604w=828.00h=466.00,14007995524440068/I14889597603w=828.00h=466.00,14007995524440068/I14889597605w=828.00h=432.00,14007995524440068/I14889597606w=828.00h=465.00,14007995524440068/I14889597617w=800.00h=800.00,14007995524440068/I14889597590w=828.00h=1472.00,14007995524440068/I14889597618w=828.00h=1104.00"];
    
    CGFloat imageV_x = 0;
    CGFloat imageV_y = 100;
    CGFloat imageV_w = 30;
    CGFloat imageV_h = 30;
    
    for (int i = 0; i < 9; i++) {
        
        CGFloat x = 40 * i;
        UIImageView *imageView_icon = [[UIImageView alloc]initWithFrame:CGRectMake(x, imageV_y, imageV_w, imageV_h)];
        [self.view addSubview:imageView_icon];
        
        NSString *str_url = arr_image[i];
        
        AliyunOSSDemo *ali = [AliyunOSSDemo sharedInstance];
        
        NSString *str_minURL = [ali getImageURLWithKey:str_url];
        
        [imageView_icon sd_setImageWithURL:[NSURL URLWithString:str_minURL]];
        
        
    }
}



@end
