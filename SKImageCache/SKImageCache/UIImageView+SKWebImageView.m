//
//  UIImageView+SKWebImageView.m
//  SKImageCache
//
//  Created by Sakya on 2017/8/9.
//  Copyright © 2017年 Sakya. All rights reserved.
//

#import "UIImageView+SKWebImageView.h"
#import <objc/runtime.h>
#import "SKWebImageManager.h"


@interface UIImageView ()
// 下载图片的 url
@property (nonatomic, copy) NSString *urlStr;
@end

@implementation UIImageView (SKWebImageView)
- (void)sk_setWebImageWithURL:(NSString *)urlString
             placeholderImage:(UIImage *)placeholder
                    completed:(SKExternalCompletionBlock)completedBlock {
    
    // 屏蔽快速滑动重复添加下载
    if ([self.urlStr isEqualToString:urlString]) return;
    // 暂停之前的操作
    if (self.urlStr != nil &&
        ![self.urlStr isEqualToString:urlString]) {
        [[SKWebImageManager sharedManager] cancelDownload:self.urlStr];
        // 如果 ImageView 之前有图像-清空图像
        self.image = nil;
    }
    // 记录新的 url
    self.urlStr = urlString;
    //设置占位图
    if (placeholder) self.image = placeholder;
    
    __weak __typeof(self)wself = self;
    // 下载网络图片
    [[SKWebImageManager sharedManager] downloadImage:self.urlStr completion:^(UIImage *image) {
        __strong __typeof (wself) sself = wself;
        sself.image = image;
        NSURL *url = [NSURL URLWithString:@"urlString"];
        completedBlock(image,url);
    }];
}

// 向分类添加属性
// 运行时的关联对象，动态添加属性
const void *URLStrKey = "URLStrKey";

- (void)setUrlStr:(NSString *)urlString {
    objc_setAssociatedObject(self, URLStrKey, urlString, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)urlStr {
    return objc_getAssociatedObject(self, URLStrKey);
}
@end
