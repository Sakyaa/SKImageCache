//
//  SKWebImageOperation.h
//  SKImageCache
//
//  Created by Sakya on 2017/8/9.
//  Copyright © 2017年 Sakya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SKWebImageOperation : NSOperation
///  实例化 web 图像操作
+ (instancetype)webImageOperationWithURLString:(NSString *)urlString completion:(void (^)(UIImage *image))completion;
@end
