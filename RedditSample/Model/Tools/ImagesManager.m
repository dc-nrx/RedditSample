//
//  ImagesManager.m
//  Nimble
//
//  Created by Dmytro Chapovskyi on 7/29/19.
//  Copyright © 2019 Nimble, Inc. All rights reserved.
//

#import "ImagesManager.h"

@interface ImagesManager()

/**
 * Contains downloaded images. Keys are image URL absolute string.
 */
@property (nonatomic, strong) NSCache <NSString *, UIImage *> *downloadedImagesCache;

/**
 * Persons which currently being processed by "loadAvatarFor:" method.
 */
@property (nonatomic, strong) NSHashTable <PersonInfoProtocol> *personsInProcessing;

/**
 * Completions to execute on corresponding image load finish.
 */
@property (nonatomic, strong) NSMutableDictionary <NSString *, NSMutableArray *> *completionsForImageLoaders;

/**
 * Used to track which images are currently being loaded.
 */
@property (nonatomic, strong) NSMutableSet <NSString *> *activeImageLoaderURLs;

@end

@implementation ImagesManager

+ (instancetype)sharedInstance
{
	static id sharedInstance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [self new];
	});
	
	return sharedInstance;
}

- (instancetype)init
{
	self = [super init];
	if (self) {
		_downloadedImagesCache = [NSCache new];
		_activeImageLoaderURLs = [NSMutableSet new];
		_completionsForImageLoaders = [NSMutableDictionary new];
		_personsInProcessing = (NSHashTable<PersonInfoProtocol> *)[NSHashTable weakObjectsHashTable];
	}
	return self;
}

#pragma mark - Images

- (UIImage *)getCachedImageForURL:(NSURL *)url
{
	return [self.downloadedImagesCache objectForKey:url.absoluteString];
}

- (void)loadImageForURL:(NSURL *)url completion:(DataManagerLoadImageCompletionBlock)completion
{
	NSString *urlString = url.absoluteString;
	if (urlString.length == 0) {
		completion(nil);
		return;
	}
	
	UIImage *cachedImage = [self getCachedImageForURL:url];
	// Image loaded case
	if (cachedImage) {
		completion(cachedImage);
	}
	else {
		[self addCompletion:completion forImageLoaderFromURLString:urlString];
		// Image loading required case
		if (![self isLoadingImageFromURLString:urlString]) {
			[self setLoadingImageFromURLString:urlString to:YES];
			
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
				// Try to get the image from the disk
				UIImage *image = [self getImageFromDisk:url];
				if (!image) {
					// If there's no image, download it and save to the disk
					image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:url]];
					if (image) {
						[self saveToDiskImage:image fromURL:url];
					}
				}
				
				dispatch_async(dispatch_get_main_queue(), ^{
					// Loading finished - save image to the in-memory cache & execute corresponding completions
					if (image) {
						[self.downloadedImagesCache setObject:image forKey:urlString];
					}
					[self setLoadingImageFromURLString:urlString to:NO];
					[self executeCompletionsForImageLoaderFromURLString:urlString withImage:image];
				});
			});
		}
	}
}

#pragma mark - Private

- (BOOL)isLoadingImageFromURLString:(NSString *)urlString
{
	return [self.activeImageLoaderURLs containsObject:urlString];
}

- (void)setLoadingImageFromURLString:(NSString *)urlString to:(BOOL)loading
{
	if (loading) {
		[self.activeImageLoaderURLs addObject:urlString];
	}
	else {
		[self.activeImageLoaderURLs removeObject:urlString];
	}
}

- (void)addCompletion:(DataManagerLoadImageCompletionBlock)completion forImageLoaderFromURLString:(NSString *)urlString
{
	// Init array for given if needed
	if (![self.completionsForImageLoaders objectForKey:urlString]) {
		[self.completionsForImageLoaders setObject:[NSMutableArray new] forKey:urlString];
	}
	
	NSMutableArray *completions = [self.completionsForImageLoaders objectForKey:urlString];
	[completions addObject:completion];
}

- (void)executeCompletionsForImageLoaderFromURLString:(NSString *)urlString withImage:(UIImage *)image
{
	NSMutableArray *completions = [self.completionsForImageLoaders objectForKey:urlString];
	for (DataManagerLoadImageCompletionBlock completion in completions) {
		completion(image);
	}
	
	[self.completionsForImageLoaders removeObjectForKey:urlString];
}

#pragma mark - Disk

- (void)saveToDiskImage:(UIImage *)image fromURL:(NSURL *)url
{
	NSString *path = [self localPathForResourceAtRemoteURL:url];
	NSData *imageData = UIImagePNGRepresentation(image);
	[imageData writeToFile:path atomically:YES];
}

- (UIImage *)getImageFromDisk:(NSURL *)remoteURL
{
	NSString *path = [self localPathForResourceAtRemoteURL:remoteURL];
	UIImage *image = [UIImage imageWithContentsOfFile:path];
	
	return image;
}

- (NSString *)localPathForResourceAtRemoteURL:(NSURL *)url
{
	NSString *cachesDirPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *imageName = [url.path stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
	NSString *resourcePath = [cachesDirPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", imageName]];
	
	return resourcePath;
}

@end
