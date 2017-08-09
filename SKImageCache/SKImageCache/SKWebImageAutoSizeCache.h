//
//  SKWebImageAutoSizeCache.h
//  DangJian
//
//  Created by Sakya on 2017/8/9.
//  Copyright © 2017年 Sakya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKWebImageUtilities.h"

typedef void(^SKWebImageAutoSizeCacheCompletionBlock)(BOOL result);

@interface SKWebImageAutoSizeCache : NSObject

+ (SKWebImageAutoSizeCache *)sharedImageCache;

-(BOOL)sk_storeImageSize:(UIImage *)image forKey:(NSString *)key;

/**
 *  Store an imageSize into memory and disk cache at the given key.
 *
 *  @param image          The image to store
 *  @param key            The unique imageSize cache key, usually it's image absolute URL
 *  @param completedBlock An block that should be executed after the imageSize has been saved (optional)
 */
-(void)sk_storeImageSize:(UIImage *)image forKey:(NSString *)key completed:(SKWebImageAutoSizeCacheCompletionBlock)completedBlock;

/**
 *  Query the disk cache synchronously after checking the memory cache
 *
 *  @param key  The unique key used to store the wanted imageSize
 *
 *  @return imageSize
 */
-(CGSize)sk_imageSizeFromCacheForKey:(NSString *)key;

/**
 *  Store an reloadState into memory and disk cache at the given key.
 *
 *  @param state reloadState
 *  @param key   The unique reloadState cache key, usually it's image absolute URL
 *
 *  @return result
 */
-(BOOL)sk_storeReloadState:(BOOL)state forKey:(NSString *)key;

/**
 *  Store an reloadState into memory and disk cache at the given key
 *
 *  @param state          reloadState
 *  @param key            The unique reloadState cache key, usually it's image absolute URL
 *  @param completedBlock An block that should be executed after the reloadState has been saved (optional)
 */
-(void)sk_storeReloadState:(BOOL)state forKey:(NSString *)key completed:(SKWebImageAutoSizeCacheCompletionBlock)completedBlock;

/**
 *  Query the disk cache synchronously after checking the memory cache
 *
 *  @param key The unique key used to store the wanted reloadState
 *
 *  @return reloadState
 */
-(BOOL)sk_reloadStateFromCacheForKey:(NSString *)key;
@end

