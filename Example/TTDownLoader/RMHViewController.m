//
//  RMHViewController.m
//  TTDownLoader
//
//  Created by renmenghan on 12/18/2017.
//  Copyright (c) 2017 renmenghan. All rights reserved.
//

#import "RMHViewController.h"
#import "TTDownLoader.h"
#import "TTDownLoaderManager.h"

@interface RMHViewController ()
@property (nonatomic,strong) TTDownLoader *downLoader;

@property (nonatomic,weak) NSTimer *timer;
@end

@implementation RMHViewController

- (NSTimer *)timer
{
    if (!_timer) {
        NSTimer *timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(update) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        _timer = timer;
    }
    return _timer;
}
- (void)update
{
     NSLog(@"----%zd", self.downLoader.state);
}

-(TTDownLoader *)downLoader
{
    if (!_downLoader) {
        _downLoader = [[TTDownLoader alloc] init];
    }
    return _downLoader;
}
- (IBAction)download:(id)sender {
    NSURL *url2 = [NSURL URLWithString:@"http://free2.macx.cn:8281/tools/system/MenuBarStats226.dmg"];
    NSURL *url = [NSURL URLWithString:@"http://soft.macx.cn/app/software.dmg"];
    
//    [[TTDownLoaderManager shareInstance] downLoader:url2 downLoadInfo:^(long long totalSize) {
//        NSLog(@"下载信息---%lld",totalSize);
//    } progress:^(float progress) {
//         NSLog(@"下载进度---%f",progress);
//    } success:^(NSString *filePath) {
//         NSLog(@"下载路经---%@",filePath);
//    } failed:^{
//        NSLog(@"下载失败");
//    }];
    [[TTDownLoaderManager shareInstance] downLoader:url downLoadInfo:^(long long totalSize) {
        NSLog(@"下载信息---%lld",totalSize);
    } progress:^(float progress) {
        NSLog(@"下载进度---%f",progress);
    } success:^(NSString *filePath) {
        NSLog(@"下载路经---%@",filePath);
    } failed:^{
        NSLog(@"下载失败");
    }];
//    [self.downLoader downLoader:url downLoanInfo:^(long long totalSize) {
//        NSLog(@"下载信息---%lld",totalSize);
//    } progress:^(float progress) {
//        NSLog(@"下载进度---%f",progress);
//    } success:^(NSString *filePath) {
//        NSLog(@"下载路经---%@",filePath);
//    } failed:^{
//        NSLog(@"下载失败");
//    }];
}
- (IBAction)pause:(id)sender {
    [[TTDownLoaderManager shareInstance] pauseAll];
//    [self.downLoader pauseCurrentTask];
}
- (IBAction)cancel:(id)sender {
//    [self.downLoader cancleCurrentTask];
}
- (IBAction)cancelClean:(id)sender {
//    [self.downLoader cancleAndClean];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
  //  [self timer];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog(@"%@",NSTemporaryDirectory());
    
   
}

@end
