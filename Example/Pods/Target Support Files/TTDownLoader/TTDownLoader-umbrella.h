#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "NSString+TT.h"
#import "TTDownLoader.h"
#import "TTDownLoaderManager.h"
#import "TTFileTool.h"

FOUNDATION_EXPORT double TTDownLoaderVersionNumber;
FOUNDATION_EXPORT const unsigned char TTDownLoaderVersionString[];

