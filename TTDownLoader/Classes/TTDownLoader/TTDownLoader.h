//
//  TTDownLoader.h
//  TTDownLoader_Example
//
//  Created by 任梦晗 on 2017/12/18.
//  Copyright © 2017年 renmenghan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger,TTDownLoadState){
    TTDownLoadStatePause,
    TTDownLoadStateDownLoading,
    TTDownLoadStatePauseSuccess,
    TTDownLoadStatePauseFailed,
};

typedef void(^DownLoadInfoType)(long long totalSize);
typedef void(^ProgressBlockType)(float progress);
typedef void(^SuccessBlockType)(NSString *filePath);
typedef void(^FaileBlockType)(void);
typedef void(^StateChangeType)(TTDownLoadState state);

@interface TTDownLoader : NSObject
- (void)downLoader:(NSURL *)url downLoanInfo:(DownLoadInfoType)downLoadInfo progress:(ProgressBlockType)progressBlock success:(SuccessBlockType)successBlock failed:(FaileBlockType)failedBlock;

// one downloader corresponds task
- (void)downLoader:(NSURL *)url;

// pause
// 调用了几次继续 就要点几次暂停 才可以暂停 解决方案：引入状态
- (void)pauseCurrentTask;

// cancle task
- (void)cancleCurrentTask;

// cancle and clean task
- (void)cancleAndClean;

-(void)resumeCurrentTask;

///数据
@property (nonatomic,assign) TTDownLoadState state;
@property (nonatomic,assign,readonly) float progress;

@property (nonatomic,copy) DownLoadInfoType downLoadInfo;
@property (nonatomic,copy) StateChangeType stateChange;
@property (nonatomic,copy) ProgressBlockType progressChange;
@property (nonatomic,copy) SuccessBlockType successBlock;
@property (nonatomic,copy) FaileBlockType faildBlock;

@end
