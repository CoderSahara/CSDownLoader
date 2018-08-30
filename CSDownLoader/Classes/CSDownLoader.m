//
//  CSDownLoader.m
//  CSDownloader_Example
//
//  Created by Sahara on 2018/8/28.
//  Copyright © 2018年 CoderSahara. All rights reserved.
//

#import "CSDownLoader.h"
#import "NSString+CSDownLoader.h"
#import "CSDownLoaderFileTool.h"

#define kCache NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject
#define kTmp NSTemporaryDirectory()

@interface CSDownLoader ()<NSURLSessionDataDelegate>
{
    // 临时文件的大小
    long long _tmpFileSize;
    // 文件的总大小
    long long _totalFileSize;
}
/** 文件的缓存路径 */
@property (nonatomic, copy) NSString *cacheFilePath;
/** 文件的临时缓存路径 */
@property (nonatomic, copy) NSString *tmpFilePath;
/** 下载会话 */
@property (nonatomic, strong) NSURLSession *session;
/** 文件输出流 */
@property (nonatomic, strong) NSOutputStream *outputStream;
/** 下载任务 */
@property (nonatomic, weak) NSURLSessionDataTask *task;

@property (nonatomic, weak) NSURL *url;
    
@end


@implementation CSDownLoader


#pragma mark - interface

+ (NSString *)downLoadedFileWithURL: (NSURL *)url {
    
    NSString *cacheFilePath = [kCache stringByAppendingPathComponent:url.lastPathComponent];
    
    if([CSDownLoaderFileTool isFileExists:cacheFilePath]) {
        return cacheFilePath;
    }
    return nil;
    
}
    
+ (long long)tmpCacheSizeWithURL: (NSURL *)url {
    
    NSString *tmpFileMD5 = [url.absoluteString md5Str];
    NSString *tmpPath = [kTmp stringByAppendingPathComponent:tmpFileMD5];
    return  [CSDownLoaderFileTool fileSizeWithPath:tmpPath];
}
    
+ (void)clearCacheWithURL: (NSURL *)url {
    NSString *cachePath = [kCache stringByAppendingPathComponent:url.lastPathComponent];
    [CSDownLoaderFileTool removeFileAtPath:cachePath];
}
    
- (void)downLoader:(NSURL *)url downLoadInfo:(DownLoadInfoType)downLoadInfo progress:(ProgressBlockType)progressBlock success:(DownLoadSuccessType)successBlock failed:(DownLoadFailType)failedBlock {
    
    // 1. 给所有的block赋值
    self.downLoadInfo = downLoadInfo;
    self.downLoadProgress = progressBlock;
    self.downLoadSuccess = successBlock;
    self.downLoadError = failedBlock;
    
    // 2. 开始下载
    [self downLoadWithURL:url];
    
}

- (void)downLoadWithURL: (NSURL *)url {
    
    // 内部实现
    // 1. 真正的从头开始下载
    // 2. 如果任务存在了, 继续下载
    
    self.url = url;
    
    // 验证: 如果当前任务不存在 -> 开启任务
    if ([url isEqual:self.task.originalRequest.URL]) {
        // 任务存在 -> 状态
        // 状态 -> 正在下载 返回
        if (self.state == CSDownLoaderStateDowning)
        {
            return;
        }
        // 状态 -> 暂停 = 恢复
        if (self.state == CSDownLoaderStatePause)
        {
            [self resume];
            return;
        }
        
        // 取消, 重新下载 == 失败
    }
    
    // 两种: 1. 任务不存在  2. 任务存在, 但是任务的url地址不同
    
    [self cancel];
    
    // 1. 获取文件名称, 指明路径, 开启一个新的下载任务
    
    //    下载文件的存储
    //    下载中 -> tmp + (url + MD5)
    //    下载完成 -> cache + url.lastCompent
    self.cacheFilePath = [kCache stringByAppendingPathComponent:url.lastPathComponent];
    self.tmpFilePath = [kTmp stringByAppendingPathComponent:[url.absoluteString md5Str]];
    
    // 2. 首先, 判断, 本地有没有已经下载好, 已经下载完毕, 就直接返回
    // 文件的位置, 文件的大小
    if ([CSDownLoaderFileTool isFileExists:self.cacheFilePath]) {
        NSLog(@"文件已经下载完毕, 直接返回相应的数据--文件的具体路径, 文件的大小");
        
        if (self.downLoadInfo) {
            self.downLoadInfo([CSDownLoaderFileTool fileSizeWithPath:self.cacheFilePath]);
        }
        
        if (self.downLoadProgress) {
            self.downLoadProgress(1.f);
        }
        
        self.state = CSDownLoaderStateSuccess;
        
        return;
    }
    
    // 3. 判断临时文件是否存在, 不存在则从0开始下载,
    //    存在则拿到文件的大小,从上次结束的位置开始下载
    if (![CSDownLoaderFileTool isFileExists:self.tmpFilePath]) {
        
        // 从0字节开始请求资源
        [self downLoadWithURL:url offset:0];
        return;
    }
    
    // 读取本地的缓存大小
    _tmpFileSize = [CSDownLoaderFileTool fileSizeWithPath:self.tmpFilePath];
    [self downLoadWithURL:url offset:_tmpFileSize];
}

// 暂停了几次, 恢复几次, 才可以恢复
- (void)resume {
    if (self.task && self.state == CSDownLoaderStatePause) {
        [self.task resume];
        self.state = CSDownLoaderStateDowning;
    }
}

// 暂停, 暂停任务, 可以恢复, 缓存没有删除
// 恢复了几次, 暂停几次, 才可以暂停
- (void)pause {
    if (self.state == CSDownLoaderStateDowning)
    {
        [self.task suspend];
        self.state = CSDownLoaderStatePause;
    }
    
}

// 取消当前任务
- (void)cancel {
    self.state = CSDownLoaderStatePause;
    [self.session invalidateAndCancel];
    self.session = nil;
}

// 取消下载, 并统一清理缓存
- (void)cancelAndClearCache {
    [self cancel];
    
    // 删除缓存
    [CSDownLoaderFileTool removeFileAtPath:self.tmpFilePath];
    
}



#pragma mark - private method
- (void)downLoadWithURL:(NSURL *)url offset: (long long)offset {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:0];
    // 通过控制range, 控制请求资源字节区间
    [request setValue:[NSString stringWithFormat:@"bytes=%lld-", offset] forHTTPHeaderField:@"Range"];
    // session 分配的task, 默认状况, 挂起状态
    self.task = [self.session dataTaskWithRequest:request];
    [self resume];
}


#pragma mark - NSURLSessionDataDelegate

/**
 当发送的请求, 第一次接收到响应的时候调用(响应头, 并没有具体的资源内容)
 通过这个方法里面系统提供的回调代码块, 可以控制, 是继续请求, 还是取消本次请求

 @param session 会话
 @param dataTask 任务
 @param response 响应头信息
 @param completionHandler 系统回调代码块, 通过它可以控制是否继续接收数据
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    
    // 获取资源总大小
    // 1. 从Content-Length 取出来
    // 2. 如果 Content-Range 有, 应该从Content-Range里面获取
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    _totalFileSize = [httpResponse.allHeaderFields[@"Content-Length"] longLongValue];
    NSString *contentRangeStr = httpResponse.allHeaderFields[@"Content-Range"];
    if (contentRangeStr && contentRangeStr.length != 0) {
        _totalFileSize = [[[contentRangeStr componentsSeparatedByString:@"/"] lastObject] longLongValue];
    }
    
    // 传递给外界 : 总大小 & 本地存储的文件路径
    if (self.downLoadInfo) {
        self.downLoadInfo(_totalFileSize);
    }
    
    
    // 判断, 本地的缓存大小 与 文件的总大小
    // 缓存大小 == 文件的总大小 下载完成 -> 移动到下载完成的文件夹
    if (_tmpFileSize == _totalFileSize) {
        NSLog(@"文件已经下载完成, 移动数据");
        // 1. 移动临时缓存的文件 -> 下载完成的路径
        [CSDownLoaderFileTool moveFile:self.tmpFilePath toPath:self.cacheFilePath];
        // 2. 修改状态
        self.state = CSDownLoaderStateSuccess;
        // 3. 取消请求
        completionHandler(NSURLSessionResponseCancel);
        return;
    }
    
    if (_tmpFileSize > _totalFileSize) {
        
        NSLog(@"缓存有问题, 删除缓存, 重新下载");
        // 1. 删除临时缓存
        [CSDownLoaderFileTool removeFileAtPath:self.tmpFilePath];
        
        // 2. 取消请求
        completionHandler(NSURLSessionResponseCancel);
        
        // 3. 从 0 开始下载
        [self downLoadWithURL:response.URL];
//        [self downLoadWithURL:response.URL offset:0];
        return;
        
    }
    
    NSLog(@"继续接收数据");
    self.state = CSDownLoaderStateDowning;
    // 继续接收数据
    // 确定开始下载数据
    self.outputStream = [NSOutputStream outputStreamToFileAtPath:self.tmpFilePath append:YES];
    [self.outputStream open];
    
    completionHandler(NSURLSessionResponseAllow);
}


/**
 用户确定, 继续接收数据的时候调用

 @param session 会话
 @param dataTask 任务
 @param data 接收到的一段数据
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    // 进度 = 当前下载的大小 / 总大小
    _tmpFileSize += data.length;
    self.progress = 1.0 * _tmpFileSize / _totalFileSize;
    // 往输出流中写入数据 (节省内存)
    [self.outputStream write:data.bytes maxLength:data.length];
//    NSLog(@"数据接收中...");
}


/**
 请求完成时调用
 请求完成时调用( != 请求成功/失败)

 @param session 会话
 @param task 任务
 @param error 错误
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    [self.outputStream close];
    self.outputStream = nil;
    
    if (error == nil) {
        // 不一定是成功
        // 数据是肯定可以请求完毕
        // 判断, 本地缓存 == 文件总大小 {filename : filesize: md5:xxx}
        // 如果等于 => 验证, 是否文件完整(file md5)
        
        // 移动数据  temp - > cache
        [CSDownLoaderFileTool moveFile:self.tmpFilePath toPath:self.cacheFilePath];
        // 改变状态
        self.state = CSDownLoaderStateSuccess;
        
    }else {
        //        error.code
        //        error.localizedDescription;
        NSLog(@"有错误---%zd--%@", error.code, error.localizedDescription);
        
        // 取消, 断网
        // 999 != 999
        if (-999 == error.code) {
            self.state = CSDownLoaderStatePause;
        }else {
            self.state = CSDownLoaderStateFailed;
            if (self.downLoadError) {
                self.downLoadError(error);
            }
        }
        
    }
    
    
}

#pragma mark - lazy load

- (NSURLSession *)session {
    if (!_session) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _session;
}


- (void)setState:(CSDownLoaderState)state {
    if (_state == state) {
        return;
    }
    _state = state;
    
    if (self.downLoadStateChange) {
        self.downLoadStateChange(state);
    }
    
    if (_state == CSDownLoaderStateSuccess && self.downLoadSuccess) {
        self.downLoadSuccess(self.cacheFilePath);
    }
    
    if (self.url && self.url.lastPathComponent) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kDownLoadURLOrStateChangeNotification object:nil userInfo:@{
                                                                                                                               @"downLoadURL": self.url,
                                                                                                                               @"downLoadState": @(self.state)
                                                                                                                               }];
    }
    
}


- (void)setProgress:(float)progress
{
    _progress = progress;
    if (self.downLoadProgress) {
        self.downLoadProgress(progress);
    }
}


@end

