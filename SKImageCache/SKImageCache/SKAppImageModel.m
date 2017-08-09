//
//  SKAppImageModel.m
//  SKImageCache
//
//  Created by Sakya on 2017/8/9.
//  Copyright © 2017年 Sakya. All rights reserved.
//

#import "SKAppImageModel.h"

@implementation SKAppImageModel
// 实现工厂方法
+ (instancetype)appInfoModelWithDict:(NSDictionary *)dict {
    
    id obj = [[self alloc] init];
    
    [obj setValuesForKeysWithDictionary:dict];
    
    return obj;
}
@end
