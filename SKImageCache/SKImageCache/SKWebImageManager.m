//
//  SKWebImageManager.m
//  SKImageCache
//
//  Created by Sakya on 2017/8/9.
//  Copyright © 2017年 Sakya. All rights reserved.
//

#import "SKWebImageManager.h"
#import "SKWebImageOperation.h"
#import "NSString+SKBundlePath.h"

@interface SKWebImageManager ()
/// 下载队列
@property (nonatomic, strong) NSOperationQueue *downloadQueue;

/// 下载操作缓冲池
@property (nonatomic, strong) NSMutableDictionary *downloadQueueCache;

/// 图片缓冲池
@property (nonatomic, strong) NSMutableDictionary *imageCache;
@end

@implementation SKWebImageManager

// 实例化下载管理器
+ (instancetype)sharedManager {
    
    static id instance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

// 下载操作

- (void)downloadImage:(NSString *)urlString completion:(void (^)(UIImage *))completion {
    
    // 判断缓存中是否存在图像
    if ([self checkCacheWithURLString:urlString]) {
        if (completion != nil) {
            // 直接回调，传递给调用方图像
            completion(self.imageCache[urlString]);
        }
        return;
    }
    
    // 判断缓冲池中是否存在下载操作
    if (self.downloadQueueCache[urlString] != nil) return;
    
    SKWebImageOperation *downloadOperation = [SKWebImageOperation webImageOperationWithURLString:urlString
                                                                                  completion:^(UIImage *image) {
                                                                                      
                                                                                      // 下载完成从操作缓冲池中移除操作
                                                                                      [self.downloadQueueCache removeObjectForKey:urlString];
                                                                                      
                                                                                      // 下载完成添加到图片缓冲池中
                                                                                      [self.imageCache setObject:image forKey:urlString];
                                                                                      
                                                                                      if (completion != nil) {
                                                                                          completion(image);
                                                                                      }
                                                                                  }];
    
    // 将操作添加到缓冲池
    [self.downloadQueueCache setObject:downloadOperation forKey:urlString];
    
    // 将操作添加到队列
    [self.downloadQueue addOperation:downloadOperation];
}

// 取消 urlString 对应的下载操作
- (void)cancelDownload:(NSString *)urlString {
    
    // 从缓冲池拿到下载操作
    SKWebImageOperation *downloadOperation = self.downloadQueueCache[urlString];
    
    if (downloadOperation != nil) {
        
        // 取消操作
        [downloadOperation cancel];
        
        // 从缓冲池中删除操作
        [self.downloadQueueCache removeObjectForKey:urlString];
    }
}

// 判断缓存中是否存在图像
- (BOOL)checkCacheWithURLString:(NSString *)urlString {
    
    // 判断图片缓冲池中是否存在图像
    if (self.imageCache[urlString] != nil) {
        return YES;
    }
    
    UIImage *image = [UIImage imageWithContentsOfFile:[urlString appendCachePath]];
    
    // 判断沙盒中是否存在图像
    if (image != nil) {
        
        [self.imageCache setObject:image forKey:urlString];
        
        return YES;
    }
    
    return NO;
}

// 懒加载

- (NSOperationQueue *)downloadQueue {
    if (_downloadQueue == nil) {
        _downloadQueue = [[NSOperationQueue alloc] init];
    }
    return _downloadQueue;
}

- (NSMutableDictionary *)downloadQueueCache {
    if (_downloadQueueCache == nil) {
        _downloadQueueCache = [[NSMutableDictionary alloc] init];
    }
    return _downloadQueueCache;
}

- (NSMutableDictionary *)imageCache {
    if (_imageCache == nil) {
        _imageCache = [[NSMutableDictionary alloc] init];
    }
    return _imageCache;
}
@end
