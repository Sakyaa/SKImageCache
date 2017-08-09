//
//  SKWebImageOperation.m
//  SKImageCache
//
//  Created by Sakya on 2017/8/9.
//  Copyright © 2017年 Sakya. All rights reserved.
//

#import "SKWebImageOperation.h"
#import "NSString+SKBundlePath.h"

@interface SKWebImageOperation ()
/// 下载图片的 URL
@property (nonatomic, copy) NSString *urlStr;

/// 下载完成的回调
@property (nonatomic, copy) void (^completion) (UIImage *image);

@end
@implementation SKWebImageOperation
+ (instancetype)webImageOperationWithURLString:(NSString *)urlString completion:(void (^)(UIImage *image))completion {
    SKWebImageOperation *imageOperation = [[self alloc] init];
    
    imageOperation.urlStr= urlString;
    imageOperation.completion = completion;
    
    return imageOperation;
}
// 操作加入队列后会自动执行该方法
- (void)main {
    @autoreleasepool {
        
        if (self.isCancelled) return;
        
        NSURL *url = [NSURL URLWithString:self.urlStr];
        NSData *data = [NSData dataWithContentsOfURL:url];
        
        if (self.isCancelled) return;
        
        if (data != nil) {
            [data writeToFile:self.urlStr.appendCachePath atomically:YES];
        }
        
        if (self.isCancelled) return;
        
        if (self.completion && data != nil) {
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                
                self.completion([UIImage imageWithData:data]);
            }];
        }
    }
}
@end
