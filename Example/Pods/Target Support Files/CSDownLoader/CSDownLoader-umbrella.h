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

#import "CSDownLoader.h"
#import "CSDownLoaderFileTool.h"
#import "CSDownLoadManager.h"
#import "NSString+CSDownLoader.h"

FOUNDATION_EXPORT double CSDownLoaderVersionNumber;
FOUNDATION_EXPORT const unsigned char CSDownLoaderVersionString[];

