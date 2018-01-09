//
//  TTDownLoaderManager.h
//  TTDownLoader_Example
//
//  Created by 任梦晗 on 2017/12/19.
//  Copyright © 2017年 renmenghan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTDownLoader.h"

@interface TTDownLoaderManager : NSObject


+(instancetype)shareInstance;

- (void)downLoader:(NSURL *)url downLoadInfo:(DownLoadInfoType)downLoadInfo progress:(ProgressBlockType)progressBlock success:(SuccessBlockType)successBlock failed:(FaileBlockType)failedBlock;

- (void)pauseWithURL:(NSURL *)url;
- (void)resumeWithURL:(NSURL *)url;
- (void)cancelWithURL:(NSURL *)url;


- (void)pauseAll;
- (void)resumeAll;

@end
