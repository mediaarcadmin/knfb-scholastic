//
//  DummyAVAudioPlayer.h
//  Scholastic
//
//  Created by Neil Gall on 18/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DummyAVAudioPlayer : NSObject {}

@property (nonatomic, retain) NSData *data;
@property (nonatomic, assign) id delegate;
@property (nonatomic, assign) BOOL playing;

+ (DummyAVAudioPlayer *)lastNewInstance;

- (id)initWithData:(NSData *)data error:(NSError **)error;
- (void)play;
- (void)pause;

@end
