//
//  CSDownLoader.h
//  CSDownloader_Example
//
//  Created by Sahara on 2018/8/28.
//  Copyright © 2018年 CoderSahara. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    CSDownLoaderStateUnKnown,
    /** 下载暂停 */
    CSDownLoaderStatePause,
    /** 正在下载 */
    CSDownLoaderStateDowning,
    /** 已经下载 */
    CSDownLoaderStateSuccess,
    /** 下载失败 */
    CSDownLoaderStateFailed
} CSDownLoaderState;

typedef void(^DownLoadInfoType)(long long fileSize);
typedef void(^DownLoadSuccessType)(NSString *cacheFilePath);
typedef void(^DownLoadFailType)(NSError *error);

@interface CSDownLoader : NSObject

// 如果当前已经下载, 继续下载, 如果没有下载, 从头开始下载
- (void)downLoadWithURL: (NSURL *)url;

- (void)downLoadWithURL: (NSURL *)url downLoadInfo: (DownLoadInfoType)downLoadBlock success: (DownLoadSuccessType)successBlock failed: (DownLoadFailType)failBlock;

// 恢复下载
- (void)resume;

// 暂停, 暂停任务, 可以恢复, 缓存没有删除
- (void)pause;


// 取消, 这次任务已经被取消,
- (void)cancel;

// 缓存删除
- (void)cancelAndClearCache;

// kvo , 通知, 代理, block
@property (nonatomic, assign) CSDownLoaderState state;
@property (nonatomic, assign) float progress;


@property (nonatomic, copy) void(^downLoadProgress)(float progress);

// 文件下载信息 (下载的大小)
@property (nonatomic, copy) DownLoadInfoType downLoadInfo;

// 状态的改变 ()
@property (nonatomic, copy) void(^downLoadStateChange)(CSDownLoaderState state);

// 下载成功 (成功路径)
@property (nonatomic, copy) DownLoadSuccessType downLoadSuccess;

// 失败 (错误信息)
@property (nonatomic, copy) DownLoadFailType downLoadError;


@end
