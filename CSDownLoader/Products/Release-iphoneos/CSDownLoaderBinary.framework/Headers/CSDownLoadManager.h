//
//  CSDownLoadManager.h
//  CSDownloader_Example
//
//  Created by Sahara on 2018/8/28.
//  Copyright © 2018年 CoderSahara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSDownLoader.h"

@interface CSDownLoadManager : NSObject

// 单例
+ (instancetype)shareInstance;


/**
 根据URL下载资源

 @param url 下载资源的URL
 @return CSDownloader对象
 */
- (CSDownLoader *)downLoadWithURL: (NSURL *)url;
    

/**
 获取URL对应的downLoader

 @param url 下载资源的URL
 @return CSDownloader对象
 */
- (CSDownLoader *)getDownLoaderWithURL: (NSURL *)url;



/**
 根据URL下载资源,并且带有回调

 @param url 下载资源的URL
 @param downLoadInfo 下载信息回调
 @param progressBlock 下载进度回调
 @param successBlock 下载成功回调
 @param failedBlock 下载失败回调
 */
- (void)downLoader:(NSURL *)url downLoadInfo:(DownLoadInfoType)downLoadInfo progress:(ProgressBlockType)progressBlock success:(DownLoadSuccessType)successBlock failed:(DownLoadFailType)failedBlock;
    
/**
 暂停资源下载

 @param url 下载资源的URL
 */
- (void)pauseWithURL: (NSURL *)url;


/**
 回复资源下载

 @param url 下载资源的URL
 */
- (void)resumeDownLoadWithURL:(NSURL *)url;
    
/**
 取消资源下载

 @param url 下载资源的URL
 */
- (void)cancelWithURL: (NSURL *)url;


/**
 取消和清理资源下载

 @param url 下载资源的URL
 */
- (void)cancelAndClearCacheWithURL:(NSURL *)url;

/**
 暂停所有下载
 */
- (void)pauseAll;


/**
 恢复所有下载
 */
- (void)resumeAll;


/**
 取消所有下载
 */
- (void)cancelAll;


/**
 取消所有下载并且清空所有正在下载的缓存
 */
- (void)cancelAllDownloadsAndCleanAllCaches;

@end
