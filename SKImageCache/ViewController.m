//
//  ViewController.m
//  SKImageCache
//
//  Created by Sakya on 2017/8/9.
//  Copyright © 2017年 Sakya. All rights reserved.
//

#import "ViewController.h"
#import "SKAppImageModel.h"
#import <ImageIO/ImageIO.h>
#import "UIImageView+SKWebImageView.h"
#import "ImageViewController.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
/// 表格数据源
@property (nonatomic, strong) NSArray *dataSourceArray;

/// 图片下载队列
@property (nonatomic, strong) NSOperationQueue *downloadQueue;

/// 下载缓冲池
@property (nonatomic, strong) NSMutableDictionary *downloadQueueCache;

/// 图片缓冲池
@property (nonatomic, strong) NSMutableDictionary *imageCache;

/// 图片下载地址黑名单
@property (nonatomic, retain) NSMutableArray *urlBlackList;

@property (nonatomic, strong) UITableView *tableView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    for (NSInteger i = 0; i < 6; i ++) {
//        [self downloadImageWithIndexPath:i];
//    }
//    UIImageView *imageVIew = [[UIImageView alloc] initWithFrame:CGRectMake(10, 30, 300, 200)];
//    [self.view addSubview:imageVIew];
//    _imageVIew = imageVIew;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - 64) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    // -- 设置背景颜色为透明
    [self.view addSubview:_tableView];
}

// 表格视图数据源方法

#pragma mark -- tableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSourceArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellId = @"CELLID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    SKAppImageModel *dataModel = self.dataSourceArray[indexPath.row];
    UIImageView *leftImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    [cell.contentView addSubview:leftImage];
    [leftImage sk_setWebImageWithURL:dataModel.icon placeholderImage:nil completed:^(UIImage *image, NSURL *imageURL) {
        
    }];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SKAppImageModel *dataModel = self.dataSourceArray[indexPath.row];
    ImageViewController *view = [[ImageViewController alloc] init];
    view.url = dataModel.icon;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:view];
    
    [self presentViewController:nav animated:YES completion:nil];
    
}


// 懒加载
- (NSArray *)dataSourceArray {
    if (_dataSourceArray == nil) {
        NSArray *array = @[@{@"name":@"",
                             @"download":@"",
                             @"icon":@"http://120.92.78.172:9080/party/rest/user/download?fileName=944"},
                           @{@"name":@"",
                             @"download":@"",
                             @"icon":@"http://120.92.78.172:9080/party/rest/user/download?fileName=992"},
                           @{@"name":@"",
                             @"download":@"",
                             @"icon":@"http://120.92.78.172:9080/party/rest/user/download?fileName=889"},
                           @{@"name":@"",
                             @"download":@"",
                             @"icon":@"http://120.92.78.172:9080/party/rest/user/download?fileName=890"},
                           @{@"name":@"",
                             @"download":@"",
                             @"icon":@"http://120.92.78.172:9080/party/rest/user/download?fileName=897"},
                           @{@"name":@"",
                             @"download":@"",
                             @"icon":@"http://120.92.78.172:9080/party/rest/user/download?fileName=898"},
                           @{@"name":@"",
                             @"download":@"",
                             @"icon":@"http://120.92.78.172:9080/party/rest/user/download?fileName=900"}];
        
        NSMutableArray *arrayM = [NSMutableArray arrayWithCapacity:array.count];
        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [arrayM addObject:[SKAppImageModel appInfoModelWithDict:obj]];
        }];
        _dataSourceArray = [arrayM copy];
    }
    return _dataSourceArray;
}

- (NSOperationQueue *)downloadQueue {
    if (_downloadQueue == nil) {
        _downloadQueue = [[NSOperationQueue alloc] init];
    }
    return _downloadQueue;
}

- (NSMutableDictionary *)downloadQueueCache {
    if (_downloadQueueCache == nil) {
        _downloadQueueCache = [[NSMutableDictionary alloc] init];
    }
    return _downloadQueueCache;
}

- (NSMutableDictionary *)imageCache {
    if (_imageCache == nil) {
        _imageCache = [[NSMutableDictionary alloc] init];
    }
    return _imageCache;
}

- (NSMutableArray *)urlBlackList {
    if (_urlBlackList == nil) {
        _urlBlackList = [[NSMutableArray alloc] init];
    }
    return _urlBlackList;
}

- (void)downloadImageWithIndexPath:(NSInteger)index {
    
    SKAppImageModel *dataModel = self.dataSourceArray[index];
    
    // 判断下载缓冲池中是否存在当前下载操作
    if (self.downloadQueueCache[dataModel.icon] != nil) {
        return;
    }
    
    // 判断图片地址是否在黑名单中
    if ([self.urlBlackList containsObject:dataModel.icon]) {
        return;
    }
    
    // 创建异步下载图片操作
    NSBlockOperation *downloadOperation = [NSBlockOperation blockOperationWithBlock:^{
        
//        UIImage *imageOld = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:dataModel.icon]]];
//        NSLog(@"压缩前的啊%ld图片的%f%f",(long)index,imageOld.size.width,imageOld.size.height);
        
        CGImageRef cgImage = thumbaimageWithData([NSData dataWithContentsOfURL:[NSURL URLWithString:dataModel.icon]], 640);
//        CGImageRef cgImage = MyCreateThumbnailCGImageFromURL([NSURL URLWithString:dataModel.icon], 320);
        UIImage *image = [UIImage imageWithCGImage:cgImage];
        NSLog(@"压缩后%ld图片的%f%f",(long)index,image.size.width,image.size.height);

        // 下载完成从下载缓冲池中删除当前下载操作
        [self.downloadQueueCache removeObjectForKey:dataModel.icon];
        
        // 添加黑名单记录
        if (image == nil &&
            ![self.urlBlackList containsObject:dataModel.icon]) {
            [self.urlBlackList addObject:dataModel.icon];
        }
        
        // 主线程跟新 UI
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            if (image != nil) {
                
                // 将下载完成的图片保存到图片缓冲池中
                [self.imageCache setObject:image forKey:dataModel.icon];
                
//                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }];
    }];
    
    // 将当前下载添加到下载缓冲池中
    [self.downloadQueueCache setObject:downloadOperation forKey:dataModel.icon];
    
    // 开始异步下载图片
    [self.downloadQueue addOperation:downloadOperation];
}

CGImageRef thumbaimageWithData(NSData *data, NSInteger imageSize) {
    
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((CFDataRef)data, NULL);
    if (imageSource == NULL) {
        CFRelease(imageSource);
        return nil;
    }
    NSDictionary *options = [[NSDictionary alloc] initWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], (NSString *)kCGImageSourceCreateThumbnailFromImageIfAbsent,
                             [NSNumber numberWithInt:imageSize], (NSString *)kCGImageSourceThumbnailMaxPixelSize,
                             nil];
    
    CFDictionaryRef cfOptions = (__bridge CFDictionaryRef)options;
    CGImageRef thumbnail = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, cfOptions);
    CFRelease(imageSource);
    return thumbnail;
}
CGImageRef MyCreateThumbnailCGImageFromURL(NSURL * url, int imageSize) {
    
    CGImageRef thumbnailImage;
    CGImageSourceRef imageSource;
    CFDictionaryRef imageOptions;
    CFStringRef imageKeys[3];
    CFTypeRef imageValues[3];
    CFNumberRef thumbnailSize;
    //先判断数据是否存在
    imageSource = CGImageSourceCreateWithURL((CFURLRef)url, NULL);
    
    if (imageSource == NULL) {
        fprintf(stderr, "Image source is NULL.");
        return  NULL;
    }
    //创建缩略图等比缩放大小，会根据长宽值比较大的作为imageSize进行缩放
    thumbnailSize = CFNumberCreate(NULL, kCFNumberIntType, &imageSize);
    
    imageKeys[0] = kCGImageSourceCreateThumbnailWithTransform;
    imageValues[0] = (CFTypeRef)kCFBooleanTrue;
    
    imageKeys[1] = kCGImageSourceCreateThumbnailFromImageIfAbsent;
    imageValues[1] = (CFTypeRef)kCFBooleanTrue;
    //缩放键值对
    imageKeys[2] = kCGImageSourceThumbnailMaxPixelSize;
    imageValues[2] = (CFTypeRef)thumbnailSize;
    
    imageOptions = CFDictionaryCreate(NULL, (const void **) imageKeys,
                                      (const void **) imageValues, 3,
                                      &kCFTypeDictionaryKeyCallBacks,
                                      &kCFTypeDictionaryValueCallBacks);
    //获取缩略图
    thumbnailImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, imageOptions);
    CFRelease(imageOptions);
    CFRelease(thumbnailSize);
    CFRelease(imageSource);
    if (thumbnailImage == NULL) {
        return NULL;
    }
    return thumbnailImage;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // 清理缓冲池
    [self.downloadQueueCache removeAllObjects];
    [self.imageCache removeAllObjects];
    
    // 取消下载操作，等用户再滚动表格，调用数据源方法，又能够自动下载
    [self.downloadQueue cancelAllOperations];

}


@end
