//
//  SKAppImageModel.h
//  SKImageCache
//
//  Created by Sakya on 2017/8/9.
//  Copyright © 2017年 Sakya. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SKAppImageModel : NSObject
/// 标题名称
@property (nonatomic, strong) NSString *name;

/// 下载数量
@property (nonatomic, strong) NSString *download;

/// 图片地址
@property (nonatomic, strong) NSString *icon;

/// 声明工厂方法，数据源初始化方法
+ (instancetype)appInfoModelWithDict:(NSDictionary *)dict;
@end
