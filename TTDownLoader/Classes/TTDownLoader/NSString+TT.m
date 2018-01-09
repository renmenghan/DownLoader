//
//  NSString+TT.m
//  TTDownLoader_Example
//
//  Created by 任梦晗 on 2017/12/19.
//  Copyright © 2017年 renmenghan. All rights reserved.
//

#import "NSString+TT.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString(TT)

- (NSString *)md5
{
    const char *data = self.UTF8String;
    
    unsigned char md[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(data, (CC_LONG)strlen(data), md);
    
    //32
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH *2];
    
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [result appendFormat:@"%02x",md[i]];
    }
    return result;
}

@end
