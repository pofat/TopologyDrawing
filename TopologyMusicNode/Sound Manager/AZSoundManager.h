//
//  AZSoundManager.h
//
//  Version 1.2.1
//
//  Created by Aleksey Zunov on 06.08.15.
//  Copyright (c) 2015 aleksey.zunov@gmail.com. All rights reserved.
//
//  Get the latest version from here:
//
//  https://github.com/willingheart/AZSoundManager
//
//  This software is provided 'as-is', without any express or implied
//  warranty. In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//

#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "AZSoundItem.h"

typedef void (^progressBlock)(AZSoundItem *item);
typedef void (^finishBlock)(AZSoundItem *item);
typedef void (^completionBlock)(BOOL success, NSError *error);

typedef NS_ENUM(NSInteger, AZSoundStatus)
{
    AZSoundStatusNotStarted = 0,
    AZSoundStatusPreparing,
    AZSoundStatusPlaying,
    AZSoundStatusPaused,
    AZSoundStatusFinished
};

@interface AZSoundManager : NSObject

+ (instancetype)sharedManager;

@property (nonatomic, readonly) AZSoundStatus status;
@property (nonatomic, readonly) AZSoundItem *currentItem;
@property (nonatomic, assign) float volume;
@property (nonatomic, assign) float pan;

- (void)preloadSoundItem:(AZSoundItem*)item;
- (void)preloadSoundItem:(AZSoundItem*)item completionBlock:(completionBlock)completionBlock;
- (void)playSoundItem:(AZSoundItem*)item;

- (void)play;
- (void)pause;
- (void)stop;
- (void)restart;
- (void)playAtSecond:(NSInteger)second;
- (void)rewindToSecond:(NSInteger)second;

- (void)getItemInfoWithProgressBlock:(progressBlock)progressBlock
                         finishBlock:(finishBlock)finishBlock;

- (void)remoteControlReceivedWithEvent:(UIEvent *)event;

@end
