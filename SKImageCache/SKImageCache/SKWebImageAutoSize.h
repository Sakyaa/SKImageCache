//
//  SKWebImageAutoSize.h
//  DangJian
//
//  Created by Sakya on 2017/8/9.
//  Copyright © 2017年 Sakya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKWebImageAutoSizeCache.h"



@interface SKWebImageAutoSize : NSObject

+ (CGFloat)sk_imageHeightForURL:(NSURL *)url
                    layoutWidth:(CGFloat)layoutWidth
                 estimateHeight:(CGFloat)estimateHeight;

/**
 *  Get image size from cache,query the disk cache synchronously after checking the memory cache
 *
 *  @param url imageURL
 *
 *  @return imageSize
 */
+ (CGSize )sk_imageSizeFromCacheForURL:(NSURL *)url;

/**
 *  Store an imageSize into memory and disk cache
 *
 *  @param image          image
 *  @param url            imageURL
 *  @param completedBlock An block that should be executed after the imageSize has been saved (optional)
 */
+(void)sk_storeImageSize:(UIImage *)image forURL:(NSURL *)url completed:(SKWebImageAutoSizeCacheCompletionBlock)completedBlock;

/**
 *  Get reload state from cache,query the disk cache synchronously after checking the memory cache
 *
 *  @param url imageURL
 *
 *  @return reloadState
 */
+(BOOL)sk_reloadStateFromCacheForURL:(NSURL *)url;

/**
 *  Store an reloadState into memory and disk cache
 *
 *  @param state          reloadState
 *  @param url            imageURL
 *  @param completedBlock An block that should be executed after the reloadState has been saved (optional)
 */
+(void)sk_storeReloadState:(BOOL)state forURL:(NSURL *)url completed:(SKWebImageAutoSizeCacheCompletionBlock)completedBlock;

//+ (void)sk_clearMemoryCache;
@end
