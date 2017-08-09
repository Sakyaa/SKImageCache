//
//  NSString+SKBundlePath.h
//  SKImageCache
//
//  Created by Sakya on 2017/8/9.
//  Copyright © 2017年 Sakya. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (SKBundlePath)
///  拼接缓存目录
- (NSString *)appendCachePath;
@end
