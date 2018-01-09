//
//  TTFileTool.h
//  TTDownLoader_Example
//
//  Created by 任梦晗 on 2017/12/18.
//  Copyright © 2017年 renmenghan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTFileTool : NSObject

+ (BOOL)fileExists:(NSString *)filePath;

+ (long long)fileSize:(NSString *)filePath;

+ (void)moveFile:(NSString *)fromPath toPath:(NSString *)toPath;

+ (void)removeFile:(NSString *)filePath;

@end
