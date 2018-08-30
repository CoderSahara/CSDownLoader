//
//  CSDownLoadManager.m
//  CSDownloader_Example
//
//  Created by Sahara on 2018/8/28.
//  Copyright © 2018年 CoderSahara. All rights reserved.
//

#import "CSDownLoadManager.h"
#import "NSString+CSDownLoader.h"

@interface CSDownLoadManager()<NSCopying, NSMutableCopying>

@property (nonatomic, strong) NSMutableDictionary <NSString *, CSDownLoader *>*downLoadInfo;

@end

@implementation CSDownLoadManager

// 绝对的单例: 无论通过什么样的方式, 创建, 都是一个对象
// 非绝对的单例
static CSDownLoadManager *_shareInstance;
+ (instancetype)shareInstance {
    
    if (!_shareInstance) {
        _shareInstance = [[CSDownLoadManager alloc] init];
    }
    return _shareInstance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    
    if (!_shareInstance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _shareInstance = [super allocWithZone:zone];
        });
    }
    return _shareInstance;
}

- (id)copyWithZone:(NSZone *)zone {
    return _shareInstance;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return _shareInstance;
}

// key: md5(url)  value: CSDownLoader
- (NSMutableDictionary *)downLoadInfo {
    if (!_downLoadInfo) {
        _downLoadInfo = [NSMutableDictionary dictionary];
    }
    return _downLoadInfo;
}

- (void)downLoader:(NSURL *)url downLoadInfo:(DownLoadInfoType)downLoadInfo progress:(ProgressBlockType)progressBlock success:(DownLoadSuccessType)successBlock failed:(DownLoadFailType)failedBlock {
    
    // 1. url
    NSString *md5 = [url.absoluteString md5Str];
    
    // 2. 根据 urlMD5, 查找响应的下载器
    CSDownLoader *downLoader = self.downLoadInfo[md5];
    
    // 下载器不存在
    if (downLoader == nil) {
        downLoader = [[CSDownLoader alloc] init];
        self.downLoadInfo[md5] = downLoader;
    }
    
//    [self.downLoadInfo setValue:downLoader forKey:md5];
    
    __weak typeof(self) weakSelf = self;
    [downLoader downLoader:url downLoadInfo:downLoadInfo progress:progressBlock success:^(NSString *cacheFilePath) {
        
        [weakSelf.downLoadInfo removeObjectForKey:md5];
        if(successBlock) {
            successBlock(cacheFilePath);
        }
        
    } failed:^(NSError *error) {
        
        [weakSelf.downLoadInfo removeObjectForKey:md5];
        if (failedBlock) {
            failedBlock(error);
        }
        
    }];
    
    return ;
}

- (CSDownLoader *)downLoadWithURL: (NSURL *)url
{
    
    // 文件名称  aaa/a.x  bb/a.x
    
    NSString *md5 = [url.absoluteString md5Str];
    
    CSDownLoader *downLoader = self.downLoadInfo[md5];
    if (downLoader == nil) {
        downLoader = [[CSDownLoader alloc] init];
        self.downLoadInfo[md5] = downLoader;
    }

//    [self.downLoadInfo setValue:downLoader forKey:md5];
    
    __weak typeof(self) weakSelf = self;
    [downLoader downLoader:url downLoadInfo:nil progress:nil success:^(NSString *cacheFilePath) {
        
        [weakSelf.downLoadInfo removeObjectForKey:md5];

    } failed:^(NSError *error) {
        
        [weakSelf.downLoadInfo removeObjectForKey:md5];

    }];
    
    return downLoader;
}

- (CSDownLoader *)getDownLoaderWithURL: (NSURL *)url {
    NSString *md5 = [url.absoluteString md5Str];
    CSDownLoader *downLoader = self.downLoadInfo[md5];
    return downLoader;
}

- (void)pauseWithURL: (NSURL *)url {
    
    NSString *md5 = [url.absoluteString md5Str];
    CSDownLoader *downLoader = self.downLoadInfo[md5];
    [downLoader pause];
    
}
    
- (void)resumeDownLoadWithURL:(NSURL *)url {
    
    NSString *md5 = [url.absoluteString md5Str];
    CSDownLoader *downLoader = self.downLoadInfo[md5];
    [downLoader resume];
}

- (void)cancelWithURL: (NSURL *)url {
    
    NSString *md5 = [url.absoluteString md5Str];
    CSDownLoader *downLoader = self.downLoadInfo[md5];
    [downLoader cancel];
}

- (void)cancelAndClearWithURL:(NSURL *)url {
    
    NSString *md5 = [url.absoluteString md5Str];
    CSDownLoader *downLoader = self.downLoadInfo[md5];
    [downLoader cancelAndClearCache];
}

- (void)pauseAll {
    
    if (self.downLoadInfo.allValues && self.downLoadInfo.allValues.count) {
        [[self.downLoadInfo allValues] makeObjectsPerformSelector:@selector(pause)];
//        [self.downLoadInfo.allValues performSelector:@selector(pause) withObject:nil];
    }
    
}

- (void)resumeAll {
    
    if (self.downLoadInfo.allValues && self.downLoadInfo.allValues.count) {
        [[self.downLoadInfo allValues] makeObjectsPerformSelector:@selector(resume)];
//        [self.downLoadInfo.allValues performSelector:@selector(resume) withObject:nil];
    }
    
}

- (void)cancelAll {
    
    if (self.downLoadInfo.allValues && self.downLoadInfo.allValues.count) {
        [[self.downLoadInfo allValues] makeObjectsPerformSelector:@selector(cancel)];
        //        [self.downLoadInfo.allValues performSelector:@selector(cancel) withObject:nil];
    }
}

- (void)cancelAllDownloadsAndCleanAllCaches {
    
    if (self.downLoadInfo.allValues && self.downLoadInfo.allValues.count) {
        [[self.downLoadInfo allValues] makeObjectsPerformSelector:@selector(cancelAndClearCache)];
//        [self.downLoadInfo.allValues performSelector:@selector(cancelAndClearCache) withObject:nil];
    }
}
    
@end
