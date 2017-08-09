//
//  UIImageView+SKWebImageView.h
//  SKImageCache
//
//  Created by Sakya on 2017/8/9.
//  Copyright © 2017年 Sakya. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SKExternalCompletionBlock)(UIImage * image, NSURL * imageURL);

@interface UIImageView (SKWebImageView)
/// 设置 Web 图像 URL，自动加载图像
- (void)sk_setWebImageWithURL:(NSString *)urlString
             placeholderImage:(UIImage *)placeholder
                    completed:(SKExternalCompletionBlock)completedBlock;
@end
