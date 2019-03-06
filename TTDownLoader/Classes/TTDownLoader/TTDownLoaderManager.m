//
//  TTDownLoaderManager.m
//  TTDownLoader_Example
//
//  Created by 任梦晗 on 2017/12/19.
//  Copyright © 2017年 renmenghan. All rights reserved.
//

#import "TTDownLoaderManager.h"
#import "NSString+TT.h"

@implementation TTDownLoaderConfig

@end

@interface TTDownLoaderManager()<NSCopying,NSMutableCopying>
@property (nonatomic,strong) NSMutableDictionary *downLoadInfo;
@property (nonatomic,strong) TTDownLoaderConfig *currentConfig;
@end
@implementation TTDownLoaderManager

-(NSMutableDictionary *)downLoadInfo
{
    if(!_downLoadInfo){
        _downLoadInfo = [NSMutableDictionary dictionary];
    }
    return _downLoadInfo;
}

static TTDownLoaderManager *_shareInstance;

+ (void)startWithConfigure:(TTDownLoaderConfig *)configure
{
    NSAssert(1, @"下载需要一些额外配置需在config额外配置");
    [TTDownLoaderManager shareInstance].currentConfig = configure;
}

+ (instancetype)shareInstance
{
    if (!_shareInstance) {
        _shareInstance = [[self alloc] init];
    }
    return _shareInstance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    if (!_shareInstance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _shareInstance = [super allocWithZone:zone];
        });
    }
    return _shareInstance;
}

- (id)copyWithZone:(NSZone *)zone
{
    return _shareInstance;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return _shareInstance;
}

- (void)downLoader:(NSURL *)url downLoadInfo:(DownLoadInfoType)downLoadInfo progress:(ProgressBlockType)progressBlock success:(SuccessBlockType)successBlock failed:(FaileBlockType)failedBlock
{
    NSString *urlMD5 = [url.absoluteString md5];
    
    // 根据md5找到相应下载器
    TTDownLoader *downLoader = self.downLoadInfo[urlMD5];
    if (downLoader == nil) {
        downLoader = [[TTDownLoader alloc] init];
        if (self.currentConfig.netWorkGlobalParams) {
            downLoader.netWorkGlobalParams = self.currentConfig.netWorkGlobalParams;
        }
        self.downLoadInfo[urlMD5] = downLoader;
    }
    
    __weak typeof(self) weakSelf = self;
    [downLoader downLoader:url downLoanInfo:downLoadInfo progress:progressBlock success:^(NSString *filePath) {
        [weakSelf.downLoadInfo removeObjectForKey:urlMD5];
        successBlock(filePath);
    } failed:failedBlock];
    
}

- (void)pauseWithURL:(NSURL *)url
{
    NSString *urlMD5 = [url.absoluteString md5];
    TTDownLoader *downLoader = self.downLoadInfo[urlMD5];
    [downLoader pauseCurrentTask];
}

- (void)resumeWithURL:(NSURL *)url
{
    NSString *urlMD5 = [url.absoluteString md5];
    TTDownLoader *downLoader = self.downLoadInfo[urlMD5];
    [downLoader resumeCurrentTask];
}
-(void)cancelWithURL:(NSURL *)url
{
    NSString *urlMD5 = [url.absoluteString md5];
    TTDownLoader *downLoader = self.downLoadInfo[urlMD5];
    [downLoader cancleCurrentTask];
}

-(void)pauseAll
{
    [self.downLoadInfo.allValues makeObjectsPerformSelector:@selector(pauseCurrentTask)];
//    [self.downLoadInfo.allValues performSelector:@selector(pauseCurrentTask) withObject:nil];
}

- (void)resumeAll
{
    [self.downLoadInfo.allValues makeObjectsPerformSelector:@selector(resumeCurrentTask)];
}

@end
