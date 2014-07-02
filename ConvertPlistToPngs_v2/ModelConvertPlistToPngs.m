//
//  ModelConvertPlistToPngs.m
//  ConvertPlistToPngs_v2
//
//  Created by JunXie on 14-7-2.
//  Copyright (c) 2014年 xiejun. All rights reserved.
//

#import "ModelConvertPlistToPngs.h"
#import "CCSpriteFrameCache.h"
#import "cocos2d.h"

@interface CCSpriteFrameCache (Converter)
- (NSDictionary *)spriteFrames;
- (NSDictionary *)spriteFramesAliases;
@end

@interface CCRenderTexture (SaveFile)
- (BOOL)saveToFile:(NSString *)name atDirectory:(NSString *)directory format:(tCCImageFormat)format;
@end

@implementation ModelConvertPlistToPngs

+ (id)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ( ! sharedInstance ) {
            sharedInstance = [[[self class] alloc] init];
        }
    });
    return sharedInstance;
}

- (BOOL)handlePlistPath:(NSString *)path {
    if ( ! [path.pathExtension isEqualToString:@"plist"] ) {
        return NO;
    }
    NSString *directory = [path stringByDeletingPathExtension];
    CCSpriteFrameCache *sfCache = [CCSpriteFrameCache sharedSpriteFrameCache];
    [sfCache removeSpriteFrames];
    [sfCache addSpriteFramesWithFile:path];
    NSDictionary *frames = sfCache.spriteFrames;
    for (id key in frames) {
        [self saveSpriteToFile:key inDirectory:directory];
    }
    return YES;
}

- (void)saveSpriteToFile:(NSString *)name inDirectory:(NSString *)directory
{
    CCSprite *spr = [CCSprite spriteWithSpriteFrameName:name];
    CGSize sprSize = spr.contentSize;
    float scale = 1;
    NSInteger nWidth = sprSize.width;
    NSInteger nHeight = sprSize.height;
    nWidth *= scale;
    nHeight *= scale;
    spr.position = ccp(sprSize.width * 0.5f, sprSize.height * .5f);
    spr.scale = scale;
//    [[CCDirector sharedDirector].runningScene addChild:spr];
    
    CCRenderTexture *render = [CCRenderTexture renderTextureWithWidth:spr.contentSize.width height:spr.contentSize.height];
    [render begin];
    [spr visit];
    [render end];
    
    [render saveToFile:name atDirectory:directory format:kCCImageFormatPNG];
    
    [spr removeFromParent];
}

@end

@implementation CCSpriteFrameCache (Converter)

- (NSDictionary *)spriteFrames
{
    return _spriteFrames;
}
- (NSDictionary *)spriteFramesAliases
{
    return _spriteFramesAliases;
}

@end

@implementation CCRenderTexture (SaveFile)

- (BOOL)saveToFile:(NSString *)fileName atDirectory:(NSString *)directory format:(tCCImageFormat)format
{
    BOOL success;
    
    NSString *fullPath = [directory stringByAppendingPathComponent:fileName];
    
    NSString *fullPathDirectory = [fullPath stringByDeletingLastPathComponent];
    NSError *error = nil;
    BOOL isDirectoryCreated = [[NSFileManager defaultManager] createDirectoryAtPath:fullPathDirectory withIntermediateDirectories:YES attributes:nil error:&error];
    if (!isDirectoryCreated) {
        NSLog(@"error = %@", error);
        
        return NO;
    } 
    
    CGImageRef imageRef = [self newCGImage];
    
    if( ! imageRef ) {
        CCLOG(@"cocos2d: Error: Cannot create CGImage ref from texture");
        return NO;
    }
    
#if __CC_PLATFORM_IOS
    
    UIImage* image	= [[UIImage alloc] initWithCGImage:imageRef scale:CC_CONTENT_SCALE_FACTOR() orientation:UIImageOrientationUp];
    NSData *imageData = nil;
    
    if( format == kCCImageFormatPNG )
        imageData = UIImagePNGRepresentation( image );
    
    else if( format == kCCImageFormatJPEG )
        imageData = UIImageJPEGRepresentation(image, 0.9f);
    
    else
        NSAssert(NO, @"Unsupported format");
    
    [image release];
    
    success = [imageData writeToFile:fullPath atomically:YES];
    
    
#elif __CC_PLATFORM_MAC
    
    CFURLRef url = (CFURLRef)[NSURL fileURLWithPath:fullPath];
    
    CGImageDestinationRef dest;
    
    if( format == kCCImageFormatPNG )
        dest = 	CGImageDestinationCreateWithURL(url, kUTTypePNG, 1, NULL);
    
    else if( format == kCCImageFormatJPEG )
        dest = 	CGImageDestinationCreateWithURL(url, kUTTypeJPEG, 1, NULL);
    
    else
        NSAssert(NO, @"Unsupported format");
    
    CGImageDestinationAddImage(dest, imageRef, nil);
    
    success = CGImageDestinationFinalize(dest);
    
    CFRelease(dest);
#endif
    
    CGImageRelease(imageRef);
    
    if( ! success )
        CCLOG(@"cocos2d: ERROR: Failed to save file:%@ to disk",fullPath);
    
    return success;
}
@end
