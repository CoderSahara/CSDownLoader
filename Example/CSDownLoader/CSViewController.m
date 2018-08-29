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
    
    [[CSDownLoadManager shareInstance] downLoadWithURL:self.url withSuccess:^(NSString *cacheFilePath) {
        NSLog(@"下载成功--%@", cacheFilePath);
    } failed:^(NSError *error) {
        NSLog(@"下载失败");
    }];
    
    //    [self.downLoader downLoadWithURL:url];
    
    //    [self.downLoader downLoadWithURL:url downLoadInfo:^(long long fileSize) {
    //        NSLog(@"%lld", fileSize);
    //    } success:^(NSString *cacheFilePath) {
    //        NSLog(@"%@", cacheFilePath);
    //    } failed:^{
    //        NSLog(@"下载失败");
    //    }];
    
    
    //    [self.downLoader setDownLoadInfo:^(long long totalSize) {
    //        NSLog(@"%lld", totalSize);
    //    }];
    //
    //    [self.downLoader setDownLoadProgress:^(float progress) {
    //        NSLog(@"%f", progress);
    //    }];
    
}
- (IBAction)resume:(id)sender {
    //    [self.downLoader resume];
    //    [[CSDownLoadManager shareInstance] :self.url];
}
- (IBAction)pause:(id)sender {
    [[CSDownLoadManager shareInstance] pauseWithURL:self.url];
}
- (IBAction)cancel:(id)sender {
    [self.downLoader cancel];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self timer];
}

- (void)update {
    
    
    //    NSLog(@"%zd", self.downLoader.state);
    //    NSLog(@"%f", self.downLoader.progress);
    
}

@end
