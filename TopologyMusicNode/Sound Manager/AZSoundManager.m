//
//  AZSoundManager.m
//
//  Created by Aleksey Zunov on 06.08.15.
//  Copyright (c) 2015 aleksey.zunov@gmail.com. All rights reserved.
//

#import "AZSoundManager.h"

@interface AZSoundManager () <AVAudioPlayerDelegate>

@property (nonatomic, strong) AVAudioPlayer *player;

@property (nonatomic) AZSoundStatus status;
@property (nonatomic, strong) AZSoundItem *currentItem;

@property (nonatomic, strong) NSTimer *infoTimer;
@property (nonatomic, copy) progressBlock progressBlock;
@property (nonatomic, copy) finishBlock finishBlock;

@end

@implementation AZSoundManager

#pragma mark - Init

+ (instancetype)sharedManager
{
    static AZSoundManager *sharedManager = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{ sharedManager = [[AZSoundManager alloc] init];});
    return sharedManager;
}

- (id)init
{
    if (self = [super init])
    {
        self.volume = 1.0f;
        self.pan = 0.0f;
        self.status = AZSoundStatusNotStarted;
        
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    }
    return self;
}

#pragma mark - Properties

- (void)setVolume:(float)volume
{
    if (_volume != volume)
    {
        _volume = volume;
        self.player.volume = volume;
    }
}

- (void)setPan:(float)pan
{
    if (_pan != pan)
    {
        _pan = pan;
        self.player.pan = pan;
    }
}

#pragma mark - Private Functions

- (void)startTimer
{
    if (!self.infoTimer)
    {
        NSTimeInterval interval = (self.player.rate > 0) ? (1.0f / self.player.rate) : 1.0f;
        self.infoTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self
                                               selector:@selector(timerFired:)
                                               userInfo:nil repeats:YES];
    }
}

- (void)stopTimer
{
    [self.infoTimer invalidate];
    self.infoTimer = nil;
}

- (void)timerFired:(NSTimer*)timer
{
    [self.currentItem updateCurrentTime:self.player.currentTime];
    [self updatePlayingNowInfo];
    
    if (self.progressBlock)
    {
        self.progressBlock(self.currentItem);
    }
}

#pragma mark - Public Functions

- (void)preloadSoundItem:(AZSoundItem*)item
{
    [self preloadSoundItem:item completionBlock:nil];
}

- (void)preloadSoundItem:(AZSoundItem*)item completionBlock:(completionBlock)completionBlock
{
    self.status = AZSoundStatusPreparing;
    self.currentItem = item;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *data = nil;
        if (![item.URL.absoluteString hasPrefix:@"file://"])
        {
            data = [NSData dataWithContentsOfURL:item.URL];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            NSError *error = nil;
            if ([item.URL.absoluteString hasPrefix:@"file://"])
                self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:item.URL error:&error];
            else
                self.player = [[AVAudioPlayer alloc] initWithData:data error:&error];
            if (error)
            {
                self.currentItem = nil;
                
                if (completionBlock)
                    completionBlock(NO, error);
            }
            else
            {
                self.player.delegate = self;
                [self updatePlayingNowInfo];
                
                if (completionBlock)
                    completionBlock(YES, nil);
            }
        });
    });
}

#pragma mark Actions

- (void)playSoundItem:(AZSoundItem*)item
{
    [self preloadSoundItem:item completionBlock:^(BOOL success, NSError *error) {
        if (success) [self play];
    }];
}

- (void)play
{
    if (!self.player) return;
    
    [self.player play];
    self.status = AZSoundStatusPlaying;
    
    [self startTimer];
}

- (void)pause
{
    if (!self.player) return;
    
    [self.player pause];
    self.status = AZSoundStatusPaused;
    
    [self stopTimer];
}

- (void)stop
{
    if (!self.player) return;
    
    [self.player stop];
    self.player = nil;
    self.currentItem = nil;
    self.status = AZSoundStatusNotStarted;
    
    [self stopTimer];
}

- (void)restart
{
    [self playAtSecond:0];
}

- (void)playAtSecond:(NSInteger)second
{
    [self rewindToSecond:second];
    [self play];
}

- (void)rewindToSecond:(NSInteger)second
{
    if (!self.player) return;
    self.player.currentTime = second;
}

#pragma mark Item Info

- (void)getItemInfoWithProgressBlock:(progressBlock)progressBlock
                         finishBlock:(finishBlock)finishBlock
{
    self.progressBlock = progressBlock;
    self.finishBlock = finishBlock;
}

#pragma mark Remote Control

- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{
    if (event.type == UIEventTypeRemoteControl)
    {
        switch (event.subtype)
        {
            case UIEventSubtypeRemoteControlPlay:
                [self play];
                break;
                
            case UIEventSubtypeRemoteControlPause:
                [self pause];
                break;
                
            case UIEventSubtypeRemoteControlTogglePlayPause:
            {
                if (self.player.isPlaying)
                    [self pause];
                else
                    [self play];
            }
                break;
                
            default:
                break;
        }
    }
}

#pragma mark Playing Now

- (void)updatePlayingNowInfo
{
    NSDictionary *playingNowInfo = @{MPMediaItemPropertyTitle: self.currentItem.name,
                                     MPMediaItemPropertyPlaybackDuration: @(self.currentItem.duration),
                                     MPNowPlayingInfoPropertyPlaybackRate: @(self.player.rate),
                                     MPNowPlayingInfoPropertyElapsedPlaybackTime: @(self.player.currentTime)
                                     };
    [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = playingNowInfo;
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    self.status = AZSoundStatusFinished;
    
    [self stopTimer];

    if (self.finishBlock && flag)
    {
        self.finishBlock(self.currentItem);
    }
}

@end
