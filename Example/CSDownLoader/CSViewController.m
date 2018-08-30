//
//  CSViewController.m
//  CSDownLoader
//
//  Created by CoderSahara on 08/28/2018.
//  Copyright (c) 2018 CoderSahara. All rights reserved.
//

#import "CSViewController.h"
#import "CSDownLoadManager.h"
@interface CSViewController ()

@property (nonatomic, strong) CSDownLoader *downLoader;

@property (nonatomic, weak) NSTimer *timer;

@property (nonatomic , strong) NSURL *url;

@end

#define URL1 [NSURL URLWithString:@"http://free2.macx.cn:8281/tools/photo/SnapNDragPro418.dmg"]
#define URL2 [NSURL URLWithString:@"http://free2.macx.cn:8281/tools/photo/Sip44.dmg"]
#define URL3 [NSURL URLWithString:@"http://47.93.29.84/xiuenai.mp4"]

@implementation CSViewController

- (NSURL *)url {
    if (!_url) {
        _url = [NSURL URLWithString:@"http://audio.xmcdn.com/group23/M06/5C/70/wKgJL1g0DVahoMhrAMJMkvfN17c025.m4a"];
    }
    return _url;
}

- (NSTimer *)timer {
    if (!_timer) {
        NSTimer *timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(update) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        _timer = timer;
    }
    return _timer;
}


- (CSDownLoader *)downLoader {
    if (!_downLoader) {
        _downLoader = [[CSDownLoader alloc] init];
    }
    return _downLoader;
}

- (IBAction)downLoad:(id)sender {
    
    [[CSDownLoadManager shareInstance] downLoader:URL3 downLoadInfo:^(long long fileSize) {
        NSLog(@"2--下载信息--%lld", fileSize);
    } progress:^(float progress) {
        NSLog(@"2--下载进度--%f", progress);
    } success:^(NSString *cacheFilePath) {
        NSLog(@"2--下载成功--路径:%@", cacheFilePath);
    } failed:^(NSError *error) {
        NSLog(@"2--下载失败了 : \n错误码: %ld\n错误描述: %@", error.code, error.localizedDescription);
    }];
    
    [[CSDownLoadManager shareInstance] downLoader:URL1 downLoadInfo:^(long long fileSize) {
        NSLog(@"下载信息--%lld", fileSize);
    } progress:^(float progress) {
        NSLog(@"下载进度--%f", progress);

    } success:^(NSString *cacheFilePath) {
        NSLog(@"下载成功--路径:%@", cacheFilePath);

    } failed:^(NSError *error) {
        NSLog(@"下载失败了 : \n错误码: %ld\n错误描述: %@", error.code, error.localizedDescription);

    }];
    
    
//    [self.downLoader downLoadWithURL:url];
//    [self.downLoader downLoader:url downLoadInfo:^(long long fileSize) {
//        NSLog(@"下载信息--%lld", fileSize);
//
//    } progress:^(float progress) {
//        NSLog(@"下载进度--%f", progress);
//
//    } success:^(NSString *cacheFilePath) {
//        NSLog(@"下载成功--路径:%@", cacheFilePath);
//
//    } failed:^(NSError *error) {
//        NSLog(@"下载失败了 : \n错误码: %ld\n错误描述: %@", error.code, error.localizedDescription);
//
//    }];
//
//    [self.downLoader setDownLoadStateChange:^(CSDownLoaderState state) {
//        NSLog(@"---%zd", state);
//    }];
}
- (IBAction)resume:(id)sender {
//    [self.downLoader resume];
    NSLog(@"--%s--", __func__);
    [[CSDownLoadManager shareInstance] resumeAll];
//    [[CSDownLoadManager shareInstance] resumeDownLoadWithURL:URL3];
}

- (IBAction)pause:(id)sender {
//    [self.downLoader pause];
    NSLog(@"--%s--", __func__);
    [[CSDownLoadManager shareInstance] pauseAll];
//    [[CSDownLoadManager shareInstance] pauseWithURL:URL3]
}

- (IBAction)cancel:(id)sender {
//    [self.downLoader cancel];
//    [self.downLoader cancelAndClearCache];
    NSLog(@"--%s--", __func__);
//    [[CSDownLoadManager shareInstance] cancelWithURL:URL1];
//    [[CSDownLoadManager shareInstance] cancelAll];
    [[CSDownLoadManager shareInstance] cancelAllDownloadsAndCleanAllCaches];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self timer];
}

- (void)update {
    
    
//        NSLog(@"%zd", self.downLoader.state);
//        NSLog(@"%f", self.downLoader.progress);
    
}

@end
