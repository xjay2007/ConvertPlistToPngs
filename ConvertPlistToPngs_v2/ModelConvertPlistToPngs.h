//
//  ModelConvertPlistToPngs.h
//  ConvertPlistToPngs_v2
//
//  Created by JunXie on 14-7-2.
//  Copyright (c) 2014年 xiejun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ModelConvertPlistToPngs : NSObject

+ (id)sharedInstance;

- (BOOL)handlePlistPath:(NSString *)path;
@end
