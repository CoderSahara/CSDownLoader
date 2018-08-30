//
//  CSDownLoaderFileTool.h
//  CSDownloader_Example
//
//  Created by Sahara on 2018/8/28.
//  Copyright © 2018年 CoderSahara. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSDownLoaderFileTool : NSObject


/**
 文件是否存在

 @param path 文件路径
 @return 是否存在
 */
+ (BOOL)isFileExists: (NSString *)path;


/**
 文件大小

 @param path 文件路径
 @return 文件大小
 */
+ (long long)fileSizeWithPath: (NSString *)path;


/**
 移动文件,到另外一个文件路径中

 @param fromPath 从哪个文件
 @param toPath 目标文件位置
 */
+ (void)moveFile:(NSString *)fromPath toPath: (NSString *)toPath;


/**
 删除某个文件

 @param path 文件路径
 */
+ (void)removeFileAtPath: (NSString *)path;

@end
