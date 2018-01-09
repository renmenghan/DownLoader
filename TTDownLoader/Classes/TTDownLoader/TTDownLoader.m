//
//  TTDownLoader.m
//  TTDownLoader_Example
//
//  Created by 任梦晗 on 2017/12/18.
//  Copyright © 2017年 renmenghan. All rights reserved.
//

#import "TTDownLoader.h"
#import "TTFileTool.h"

#define kCachePath  NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject
#define kTmpPath NSTemporaryDirectory()

@interface TTDownLoader()<NSURLSessionDataDelegate>
{
    long long _tmpSize;
    long long _totalSize;
}
@property (nonatomic,copy) NSString *downLoadedPath;
@property (nonatomic,copy) NSString *downLodingPath;
/** 下载会话 */
@property (nonatomic, strong) NSURLSession *session;
/** 文件输出流 */
@property (nonatomic,strong) NSOutputStream *outputStream;
/** 当前下载任务 */
@property (nonatomic,weak) NSURLSessionTask *dataTask;
@end

@implementation TTDownLoader

- (NSURLSession *)session
{
    if (!_session) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _session;
}

- (void)downLoader:(NSURL *)url downLoanInfo:(DownLoadInfoType)downLoadInfo progress:(ProgressBlockType)progressBlock success:(SuccessBlockType)successBlock failed:(FaileBlockType)failedBlock
{
    self.downLoadInfo = downLoadInfo;
    self.progressChange = progressBlock;
    self.successBlock = successBlock;
    self.faildBlock = failedBlock;
    
    [self downLoader:url];
    
}

- (void)downLoader:(NSURL *)url
{
    //1 文件的存放
    // 下载中 =》temp + 名称
    // MD5 +URL 防止资源重复
    // 下载完成 =》 cache + 名称
//    0. 当前任务 肯定存在
    if ([url isEqual:self.dataTask.originalRequest.URL]) {
        // 判断当前状态 如果是暂停状态
        // 继续
        [self resumeCurrentTask];
        return;
    }
    
    NSString *fileName = url.lastPathComponent;
    self.downLoadedPath = [kCachePath stringByAppendingPathComponent:fileName];
    self.downLodingPath = [kTmpPath stringByAppendingPathComponent:fileName];
    
    // 1.判断 url地址 对应的资源 是下载完毕（下载完毕的目录里面存在这个文件）
    // 2.告诉外界 下载完毕 并且传递相关信息 （本地路径 文件大小）
    // return
    
    if ([TTFileTool fileExists:self.downLoadedPath]) {
        // 告诉外界 已经下载完成
        self.state = TTDownLoadStatePauseSuccess;
        return;
    }
    
    // 2. 检测临时文件是否存在
    // 2.2 不存在 从0字节开始请求资源
    if (![TTFileTool fileExists:self.downLodingPath]) {
        // 从0字节开始请求资源
        [self downLoadWithURL:url offset:0];
        return;
    }
    
    // 2.1存在 直接以当前的存在的文件大小 作为开始字节 去网络请求资源
    // HTTP : rang:开始字节-
    // 正确的大小 1000 1001
    
    // 本地大小 == 总大小==》移动到下载完成的路径中
    // 本地大小 《  总大小 =》从本地大小开始下载
    // 本地大小 》 总大小 =》 删除本地临时缓存 从0开始下载
    
    // 获取本地大小
    _tmpSize = [TTFileTool fileSize:self.downLodingPath];
    [self downLoadWithURL:url offset:_tmpSize];
    
    
}
- (void)pauseCurrentTask
{
    if (self.dataTask && self.state == TTDownLoadStateDownLoading) {
        
        [self.dataTask suspend];
        self.state = TTDownLoadStatePause;
    }
    
}

- (void)cancleCurrentTask
{
    self.state = TTDownLoadStatePauseFailed;
    [self.session invalidateAndCancel];
    self.session = nil;
}

-(void)cancleAndClean
{
    [self cancleCurrentTask];
    
    [TTFileTool removeFile:self.downLodingPath];
}
-(void) resumeCurrentTask{
    if (self.dataTask && self.state == TTDownLoadStatePause) {
        [self.dataTask resume];
        self.state = TTDownLoadStateDownLoading;
    }
    
}

/**
 根据开始字节, 请求资源
 
 @param url url
 @param offset 开始字节
 */
- (void)downLoadWithURL:(NSURL *)url offset:(long long)offset
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:0];
    [request setValue:[NSString stringWithFormat:@"bytes=%lld",offset] forHTTPHeaderField:@"Range"];
    
    self.dataTask =  [self.session dataTaskWithRequest:request];
    
   [self resumeCurrentTask];
    
    
}

#pragma mark -NSURLSessionDataDelegate
// 第一次接受到相应的时候调用（响应头 并没有具体的资源内容）
// 通过这个方法里面 系统提供的回调代码块 可以控制 是继续请求 还是取消本次请求
-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSHTTPURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    //  Content-Length 请求的大小 ！= 资源大小
    // 本地缓存大小
    // 去资源总大小
    // 1. 从 Content-length 取出来
    // 2 如果有content-range 从content range里面获取
    NSLog(@"%@",response);
    
    _totalSize = [response.allHeaderFields[@"Content-Length"] longLongValue];
    NSString *contentRangeStr = response.allHeaderFields[@"Content-Range"];
    if (contentRangeStr.length!=0) {
        _totalSize = [[contentRangeStr componentsSeparatedByString:@"/"].lastObject longLongValue];
    }
    
    // 比对本地大小 和总大小
    if (_tmpSize == _totalSize) {
        
        NSLog(@"移动文件到下载完成");
        [TTFileTool moveFile:self.downLodingPath toPath:self.downLoadedPath];
        
        completionHandler(NSURLSessionResponseCancel);
        
        self.state = TTDownLoadStatePauseSuccess;
        
        return;
    }
    
    if (_tmpSize > _totalSize) {
        NSLog(@"删除临时缓存");
        [TTFileTool removeFile:self.downLodingPath];
        
        NSLog(@"重新开始下载");
        [self downLoader:response.URL];
        
        completionHandler(NSURLSessionResponseCancel);
        
        return;
        
    }
    self.outputStream = [NSOutputStream outputStreamToFileAtPath:self.downLodingPath append:YES];
    [self.outputStream open];
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
//    NSLog(@"在接受后续数据");
    // 当前已下载的大小
    _tmpSize += data.length;
    self.progress = 1.0 * _tmpSize / _totalSize;
    
    [self.outputStream write:data.bytes maxLength:data.length];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    NSLog(@"请求完成");
    if (error == nil) {
        // 不一定是成功  数据是肯定可以请求完毕
        // 判断 本地缓存 == 文件总大小 （filename : filesize: md5:xxx）
        // 如果等于 =》 验证 是否文件完整（file md5）
        [TTFileTool moveFile:self.downLodingPath toPath:self.downLoadedPath];
        self.state = TTDownLoadStatePauseSuccess;
    }else {
        
        NSLog(@"有问题 %zd-- %@",error.code,error.localizedDescription);
        
        if (-999 == error.code) {
            self.state = TTDownLoadStatePause;
        }else {
            self.state = TTDownLoadStatePauseFailed;
        }
        
    }
    
    [self.outputStream close];
}

- (void)setState:(TTDownLoadState)state
{
    if (state == _state) {
        return;
    }
    _state = state;
    
    if (self.stateChange) {
        self.stateChange(_state);
    }
    
    if (_state == TTDownLoadStatePauseSuccess && self.successBlock) {
        self.successBlock(self.downLoadedPath);
    }
    if (_state == TTDownLoadStatePauseFailed && self.faildBlock) {
        self.faildBlock();
    }
    
    // 代理 block 通知
    // 或者拉模式
}

- (void)setProgress:(float)progress
{
    _progress = progress;
    if (self.progressChange) {
        self.progressChange(_progress);
    }
}

@end
