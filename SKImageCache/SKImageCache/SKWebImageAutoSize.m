//
//  SKWebImageAutoSize.m
//  DangJian
//
//  Created by Sakya on 2017/8/9.
//  Copyright © 2017年 Sakya. All rights reserved.
//

#import "SKWebImageAutoSize.h"


static CGFloat const estimateDefaultHeight = 100;


@implementation SKWebImageAutoSize

+ (CGFloat)sk_imageHeightForURL:(NSURL *)url
                    layoutWidth:(CGFloat)layoutWidth
                 estimateHeight:(CGFloat)estimateHeight {
    CGFloat showHeight = estimateDefaultHeight;
    if(estimateHeight) showHeight = estimateHeight;
    if(!url || !layoutWidth) return showHeight;
    CGSize size = [self sk_imageSizeFromCacheForURL:url];
    CGFloat imgWidth = size.width;
    CGFloat imgHeight = size.height;
    if(imgWidth>0 && imgHeight >0)
    {
        showHeight = layoutWidth/imgWidth*imgHeight;
    }
    return showHeight;
}


+ (CGSize )sk_imageSizeFromCacheForURL:(NSURL *)url {
    return [[SKWebImageAutoSizeCache sharedImageCache] sk_imageSizeFromCacheForKey:[self sk_cacheKeyForURL:url]];

}


+(void)sk_storeImageSize:(UIImage *)image forURL:(NSURL *)url completed:(SKWebImageAutoSizeCacheCompletionBlock)completedBlock {
    
    [[SKWebImageAutoSizeCache sharedImageCache] sk_storeImageSize:image forKey:[self sk_cacheKeyForURL:url] completed:completedBlock];
}


+(BOOL)sk_reloadStateFromCacheForURL:(NSURL *)url {
    
    return [[SKWebImageAutoSizeCache sharedImageCache] sk_reloadStateFromCacheForKey:[self sk_cacheKeyForURL:url]];
}


+(void)sk_storeReloadState:(BOOL)state forURL:(NSURL *)url completed:(SKWebImageAutoSizeCacheCompletionBlock)completedBlock {
    [[SKWebImageAutoSizeCache sharedImageCache] sk_storeReloadState:state forKey:[self sk_cacheKeyForURL:url] completed:completedBlock];

}

#pragma mark - SKWebImageAutoSize (private)

+(NSString *)sk_cacheKeyForURL:(NSURL *)url{
    
    return [url absoluteString];
}
@end

