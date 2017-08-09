//
//  SKWebImageManager.h
//  SKImageCache
//
//  Created by Sakya on 2017/8/9.
//  Copyright © 2017年 Sakya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>



@interface SKWebImageManager : NSObject
///  全局单例访问入口
+ (instancetype)sharedManager;

///  下载网络图像
- (void)downloadImage:(NSString *)urlString completion:(void (^) (UIImage *image))completion;

///  取消 urlString 对应的下载操作
- (void)cancelDownload:(NSString *)urlString;
@end
