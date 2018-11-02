//
//  CSDownLoader.h
//  CSDownloader_Example
//
//  Created by Sahara on 2018/8/28.
//  Copyright © 2018年 CoderSahara. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kDownLoadURLOrStateChangeNotification @"downLoadURLOrStateChangeNotification"

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
typedef void(^ProgressBlockType)(float progress);
typedef void(^DownLoadSuccessType)(NSString *cacheFilePath);
typedef void(^DownLoadFailType)(NSError *error);
typedef void(^StateChangeType)(CSDownLoaderState state);

// 一个下载器, 对应一个下载任务
// CSDownLoader -> url
@interface CSDownLoader : NSObject
    
// 如果当前已经下载, 继续下载, 如果没有下载, 从头开始下载
- (void)downLoadWithURL: (NSURL *)url;

- (void)downLoader:(NSURL *)url downLoadInfo:(DownLoadInfoType)downLoadInfo progress:(ProgressBlockType)progressBlock success:(DownLoadSuccessType)successBlock failed:(DownLoadFailType)failedBlock;

// 恢复下载
- (void)resume;

// 暂停, 暂停任务, 可以恢复, 缓存没有删除
- (void)pause;


// 取消任务
- (void)cancel;

// 取消任务,并且缓存删除
- (void)cancelAndClearCache;

// kvo , 通知, 代理, block
@property (nonatomic, assign) CSDownLoaderState state;
    
// 进度
@property (nonatomic, assign) float progress;

// 下载进度
@property (nonatomic, copy) ProgressBlockType downLoadProgress;

// 文件下载信息 (下载的大小)
@property (nonatomic, copy) DownLoadInfoType downLoadInfo;

// 状态的改变 ()
@property (nonatomic, copy) void(^downLoadStateChange)(CSDownLoaderState state);

// 下载成功 (成功路径)
@property (nonatomic, copy) DownLoadSuccessType downLoadSuccess;

// 失败 (错误信息)
@property (nonatomic, copy) DownLoadFailType downLoadError;


@end
