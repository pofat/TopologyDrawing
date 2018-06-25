//
//  AZSoundItem.h
//
//  Created by Aleksey Zunov on 06.08.15.
//  Copyright (c) 2015 aleksey.zunov@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@interface AZSoundItem : NSObject

+ (instancetype)soundItemWithContentsOfFile:(NSString*)path;
- (instancetype)initWithContentsOfFile:(NSString*)path;
+ (instancetype)soundItemWithContentsOfURL:(NSURL*)URL;
- (instancetype)initWithContentsOfURL:(NSURL*)URL;

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSURL *URL;

// metadata
@property (nonatomic, readonly) NSTimeInterval duration;
@property (nonatomic, readonly) NSTimeInterval currentTime;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *album;
@property (nonatomic, readonly) NSString *artist;
@property (nonatomic, readonly) UIImage *artwork;

- (void)updateCurrentTime:(NSTimeInterval)currentTime;

@end
