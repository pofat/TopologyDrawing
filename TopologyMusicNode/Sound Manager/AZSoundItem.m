//
//  AZSoundItem.m
//
//  Created by Aleksey Zunov on 06.08.15.
//  Copyright (c) 2015 aleksey.zunov@gmail.com. All rights reserved.
//

#import "AZSoundItem.h"

@interface AZSoundItem ()

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSURL *URL;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *album;
@property (nonatomic, strong) NSString *artist;
@property (nonatomic, strong) UIImage *artwork;

@property (nonatomic) NSTimeInterval duration;
@property (nonatomic) NSTimeInterval currentTime;

@end

@implementation AZSoundItem

#pragma mark - Init

+ (instancetype)soundItemWithContentsOfFile:(NSString*)path
{
    return [[self alloc] initWithContentsOfFile:path];
}

+ (instancetype)soundItemWithContentsOfURL:(NSURL*)URL
{
    return [[self alloc] initWithContentsOfURL:URL];
}

- (instancetype)initWithContentsOfFile:(NSString*)path
{
    return [self initWithContentsOfURL:path ? [NSURL fileURLWithPath:path] : nil];
}

- (instancetype)initWithContentsOfURL:(NSURL*)URL
{
    if (self = [super init])
    {
        self.URL = URL;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self loadMetadata];
        });
    }
    return self;
}

#pragma mark - Properties

- (NSString*)name
{
    return [self.URL.path lastPathComponent];
}

#pragma mark - Parent Functiosn

- (BOOL)isEqual:(id)object
{
    if (!object)
        return NO;
    if (![object isKindOfClass:[AZSoundItem class]])
        return NO;
    
    AZSoundItem *item = (AZSoundItem*)object;
    return [self.URL isEqual:item.URL];
}

#pragma mark - Private Functions

- (void)loadMetadata
{
    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:self.URL];
    
    self.duration = CMTimeGetSeconds(playerItem.asset.duration);
    self.currentTime = CMTimeGetSeconds(playerItem.currentTime);
    
    NSArray *metadata = [playerItem.asset commonMetadata];
    for (AVMetadataItem *metadataItem in metadata)
    {
        [metadataItem loadValuesAsynchronouslyForKeys:@[AVMetadataKeySpaceCommon] completionHandler:^{
            if ([metadataItem.commonKey isEqualToString:@"title"])
            {
                self.title = (NSString *)metadataItem.value;
            }
            else if ([metadataItem.commonKey isEqualToString:@"albumName"])
            {
                self.album = (NSString *)metadataItem.value;
            }
            else if ([metadataItem.commonKey isEqualToString:@"artist"])
            {
                self.artist = (NSString *)metadataItem.value;
            }
            else if ([metadataItem.commonKey isEqualToString:@"artwork"])
            {
                if ([metadataItem.keySpace isEqualToString:AVMetadataKeySpaceID3])
                {
                    self.artwork = [UIImage imageWithData:[[metadataItem.value copyWithZone:nil] objectForKey:@"data"]];
                }
                else if ([metadataItem.keySpace isEqualToString:AVMetadataKeySpaceiTunes])
                {
                    self.artwork = [UIImage imageWithData:[metadataItem.value copyWithZone:nil]];
                }
            }
        }];
    }
}

#pragma mark - Public Functions

- (void)updateCurrentTime:(NSTimeInterval)currentTime
{
    self.currentTime = currentTime;
}

@end
