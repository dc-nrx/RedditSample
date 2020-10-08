//
//  ImagesManager.h
//  Nimble
//
//  Created by Dmytro Chapovskyi on 7/29/19.
//  Copyright © 2019 Nimble, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@import UIKit;
typedef void (^DataManagerLoadImageCompletionBlock) (UIImage * _Nullable image);

@interface ImagesManager : NSObject

#pragma mark - Cache

+ (instancetype)sharedInstance;

/**
 * Retrieve requested image from cache.
 * @return Cached image.
 */
- (UIImage * _Nullable)getCachedImageForURL:(NSURL * _Nullable)url;

/**
 * Retrieve requested image from cache if possible or download it first, put to cache and then execute completion.
 */
- (void)loadImageForURL:(NSURL *)url completion:(DataManagerLoadImageCompletionBlock)completion;

/**
 * @param urlString Absolute path.
 */
- (BOOL)isLoadingImageFromURLString:(NSString *)urlString;

@end

NS_ASSUME_NONNULL_END
