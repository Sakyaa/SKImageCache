//
//  SKWebImageAutoSizeCache.m
//  DangJian
//
//  Created by Sakya on 2017/8/9.
//  Copyright © 2017年 Sakya. All rights reserved.
//

#import "SKWebImageAutoSizeCache.h"
#import <CommonCrypto/CommonDigest.h>

#ifdef DEBUG
#define DebugLog(...) NSLog(__VA_ARGS__)
#else
#define DebugLog(...)
#endif

@interface NSString (CacheFileName)

@property(nonatomic,copy ,readonly)NSString * sizeKeyName;
@property(nonatomic,copy ,readonly)NSString * reloadKeyName;
@property(nonatomic,copy ,readonly)NSString * md5String;

@end

@implementation NSString (CacheKeyName)

-(NSString *)sizeKeyName{
    
    NSString *keyName = [NSString stringWithFormat:@"sizeKeyName:%@",self];
    return keyName.md5String;
    
}
-(NSString *)reloadKeyName{
    
    NSString *keyName = [NSString stringWithFormat:@"reloadKeyName:%@",self];
    return keyName.md5String;
}
-(NSString *)md5String
{
    const char *value = [self UTF8String];
    
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    
    return outputString;
}
@end


@interface SKWebImageAutoSizeCache ()
@property(nonatomic,strong)NSCache * memCache;

@property(nonnull,strong)NSFileManager *fileManager;
@end

@implementation SKWebImageAutoSizeCache


+(SKWebImageAutoSizeCache *)sharedImageCache {
    
    static SKWebImageAutoSizeCache *instance = nil;
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken,^{
        
        instance = [[SKWebImageAutoSizeCache alloc] init];
        
    });
    return instance;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        
        self.memCache = [[NSCache alloc] init];
        self.fileManager = [NSFileManager defaultManager];
    }
    return self;
}
-(BOOL)sk_storeImageSize:(UIImage *)image forKey:(NSString *)key{
    
    if(!image || !key) return NO;
    
    CGSize imgSize = image.size;
    NSDictionary *sizeDict = @{@"width":@(imgSize.width),@"height":@(imgSize.height)};
    NSData *data = [self sk_dataFromDict:sizeDict];
    NSString *keyName = key.sizeKeyName;
    [self.memCache setObject:data forKey:keyName];
    return [self.fileManager createFileAtPath:[self sk_sizeCachePathForKey:keyName] contents:data attributes:nil];
    
}
-(void)sk_storeReloadState:(BOOL)state forKey:(NSString *)key completed:(SKWebImageAutoSizeCacheCompletionBlock)completedBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        BOOL result = [self sk_storeReloadState:state forKey:key];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(completedBlock)
            {
                completedBlock(result);
            }
        });
    });
}
-(BOOL)sk_storeReloadState:(BOOL)state forKey:(NSString *)key{
    
    if(!key) return NO;
    NSString *stateString = @"0";
    if(state) stateString = @"1";
    NSDictionary *stateDict = @{@"reloadSate":stateString};
    NSData *data = [self sk_dataFromDict:stateDict];
    NSString *keyName = key.reloadKeyName;
    [self.memCache setObject:data forKey:keyName];
    return [self.fileManager createFileAtPath:[self sk_reloadCachePathForKey:keyName] contents:data attributes:nil];
}
-(void)sk_storeImageSize:(UIImage *)image forKey:(NSString *)key completed:(SKWebImageAutoSizeCacheCompletionBlock)completedBlock{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        BOOL result = [self sk_storeImageSize:image forKey:key];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(completedBlock) {
                completedBlock(result);
            }
        });
    });
    
}
- (CGSize)sk_imageSizeFromCacheForKey:(NSString *)key{
    
    NSString *keyName = key.sizeKeyName;
    NSData *data = [self sk_dataFromMemCacheForKey:keyName];
    if(!data)
    {
        data = [self sk_dataFromDiskCacheForKey:keyName isSizeCache:YES];
    }
    NSDictionary *sizeDict = [self sk_dictFromData:data];
    CGFloat width = [sizeDict[@"width"] floatValue];
    CGFloat height = [sizeDict[@"height"] floatValue];
    CGSize size = CGSizeMake(width, height);
    return size;
}
-(BOOL)sk_reloadStateFromCacheForKey:(NSString *)key{
    
    NSString *keyName = key.reloadKeyName;
    NSData *data = [self sk_dataFromMemCacheForKey:keyName];
    if(!data) {
        data = [self sk_dataFromDiskCacheForKey:keyName isSizeCache:NO];
    }
    NSDictionary *reloadDict = [self sk_dictFromData:data];
    NSInteger state = [reloadDict[@"reloadSate"] integerValue];
    if(state ==1) return YES;
    return NO;
}









#pragma mark - SKWebImageAutoSizeCache (private)

- (NSData *)sk_dataFromMemCacheForKey:(NSString *)key{
    
    return [self.memCache objectForKey:key];
}
- (NSData *)sk_dataFromDiskCacheForKey:(NSString *)key isSizeCache:(BOOL)isSizeCache{
    
    NSString *path = [self sk_sizeCachePathForKey:key];
    
    if(!isSizeCache) path =[self sk_reloadCachePathForKey:key];
    
    if ([self.fileManager fileExistsAtPath:path isDirectory:nil] == YES) {
        
        return [self.fileManager contentsAtPath:path];
    }
    return nil;
}
- (NSData *)sk_dataFromDict:(NSDictionary *)dict
{
    if(dict==nil) return nil;
    NSError *error;
    NSData *data =[NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        DebugLog(@"ERROR, faild to get json data");
        return nil;
    }
    return data;
}
- (NSDictionary *)sk_dictFromData:(NSData *)data
{
    if(data==nil) return nil;
    return [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
}
- (NSString *)sk_sizeCachePathForKey:(NSString *)key
{
    return [self sk_cachePathForKey:key inPath:[self sk_sizeCacheDirectory]];
}

- (NSString *)sk_reloadCachePathForKey:(NSString *)key
{
    return [self sk_cachePathForKey:key inPath:[self sk_reloadCacheDirectory]];
    
}
- (NSString *)sk_cachePathForKey:(NSString *)key inPath:(NSString *)path {
    
    [self sk_checkDirectory:path];
    return [path stringByAppendingPathComponent:key];
}
-(NSString *)sk_sizeCacheDirectory
{
    return [[self sk_baseCacheDirectory] stringByAppendingPathComponent:@"SizeCache"];
}

-(NSString *)sk_reloadCacheDirectory
{
    return [[self sk_baseCacheDirectory] stringByAppendingPathComponent:@"ReloadCache"];
}
-(NSString *)sk_baseCacheDirectory
{
    NSString *pathOfLibrary = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [pathOfLibrary stringByAppendingPathComponent:@"SKWebImageAutoSizeCache"];
    return path;
    
}
-(void)sk_checkDirectory:(NSString *)path {
    
    BOOL isDir;
    if (![self.fileManager fileExistsAtPath:path isDirectory:&isDir]) {
        [self sk_createBaseDirectoryAtPath:path];
    } else {
        
        if (!isDir) {
            NSError *error = nil;
            [self.fileManager removeItemAtPath:path error:&error];
            [self sk_createBaseDirectoryAtPath:path];
        }
    }
}
- (void)sk_createBaseDirectoryAtPath:(NSString *)path {
    __autoreleasing NSError *error = nil;
    [self.fileManager createDirectoryAtPath:path withIntermediateDirectories:YES
                                 attributes:nil error:&error];
    if (error) {
        DebugLog(@"create cache directory failed, error = %@", error);
    } else {
        
        //DebugLog(@"path = %@",path);
        [self sk_addDoNotBackupAttribute:path];
    }
}
- (void)sk_addDoNotBackupAttribute:(NSString *)path {
    NSURL *url = [NSURL fileURLWithPath:path];
    NSError *error = nil;
    [url setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
    if (error) {
        DebugLog(@"error to set do not backup attribute, error = %@", error);
    }
}

@end
