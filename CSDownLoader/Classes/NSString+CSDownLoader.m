//
//  NSString+CSDownLoader.m
//  CSDownloader_Example
//
//  Created by Sahara on 2018/8/28.
//  Copyright © 2018年 CoderSahara. All rights reserved.
//

#import "NSString+CSDownLoader.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (CSDownLoader)

- (NSString *)md5Str {
    
    const char *data = self.UTF8String;
    
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    
    // 作用: 把c语言的字符串 -> md5 c字符串
    CC_MD5(data, (CC_LONG)strlen(data), digest);
    
    // 32
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i ++) {
        [result appendFormat:@"%02x", digest[i]];
    }
    
    return result;
    
}

@end
