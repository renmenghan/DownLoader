//
//  TTFileTool.m
//  TTDownLoader_Example
//
//  Created by 任梦晗 on 2017/12/18.
//  Copyright © 2017年 renmenghan. All rights reserved.
//

#import "TTFileTool.h"

@implementation TTFileTool

+(BOOL)fileExists:(NSString *)filePath
{
    if (filePath.length == 0) {
        return NO;
    }
    return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}

+ (long long)fileSize:(NSString *)filePath
{
    if (filePath.length == 0) {
        return 0;
    }
    NSDictionary *fileInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
    
    return [fileInfo[NSFileSize] longLongValue];
}

+ (void)moveFile:(NSString *)fromPath toPath:(NSString *)toPath
{
    if (![self fileSize:fromPath]) {
        return;
    }
    
    [[NSFileManager defaultManager]moveItemAtPath:fromPath toPath:toPath error:nil];
}

+ (void)removeFile:(NSString *)filePath
{
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
}
@end
