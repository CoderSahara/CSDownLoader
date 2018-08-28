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

+ (instancetype)shareInstance;

- (CSDownLoader *)downLoadWithURL: (NSURL *)url;

- (void)downLoadWithURL: (NSURL *)url withSuccess: (DownLoadSuccessType)successBlock failed: (DownLoadFailType)failedBlock;

- (void)pauseWithURL: (NSURL *)url;

- (void)cancelWithURL: (NSURL *)url;

- (void)pauseAll;

@end
