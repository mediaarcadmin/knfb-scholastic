//
//  SCHDictionaryAccessManager.m
//  Scholastic
//
//  Created by Gordon Christie on 25/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <pthread.h>

#import "SCHDictionaryAccessManager.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreData/CoreData.h>
#import "SCHDictionaryDownloadManager.h"
#import "SCHDictionaryWordForm.h"
#import "SCHBookManager.h"
#import "SCHDictionaryEntry.h"

@interface SCHDictionaryAccessManager ()

@property (nonatomic, copy) NSString *youngDictionaryCSS;
@property (nonatomic, copy) NSString *oldDictionaryCSS;
@property (nonatomic, copy) NSString *youngAdditions;
@property (nonatomic, copy) NSString *oldAdditions;
@property (nonatomic, retain) AVAudioPlayer *player;

// SCHDictionaryEntry object for a word
- (SCHDictionaryEntry *) entryForWord: (NSString *) dictionaryWord category: (NSString *) category;
- (SCHDictionaryWordForm *) wordFormForBaseWord: (NSString *) baseWord category: (NSString *) category;

@end

@implementation SCHDictionaryAccessManager

@synthesize dictionaryAccessQueue;
@synthesize youngDictionaryCSS;
@synthesize oldDictionaryCSS;
@synthesize youngAdditions;
@synthesize oldAdditions;
@synthesize player;
@synthesize persistentStoreCoordinator;
@synthesize mainThreadManagedObjectContext;

#pragma mark -
#pragma mark Default Manager Object

static SCHDictionaryAccessManager *sharedManager = nil;

+ (SCHDictionaryAccessManager *) sharedAccessManager
{
	if (sharedManager == nil) {
		sharedManager = [[SCHDictionaryAccessManager alloc] init];
		
        sharedManager.dictionaryAccessQueue = dispatch_queue_create("com.scholastic.DictionaryAccessQueue", NULL);
	} 
	
	return sharedManager;
}

- (id) init
{
    if ((self = [super init])) {
        [self updateOnReady];
    }
    
    return self;
}

- (void) dealloc
{
    if (dictionaryAccessQueue) {
        dispatch_release(dictionaryAccessQueue);
        dictionaryAccessQueue = nil;
        [youngDictionaryCSS release], youngDictionaryCSS = nil;
        [oldDictionaryCSS release], oldDictionaryCSS = nil;
        [youngAdditions release], youngAdditions = nil;
        [oldAdditions release], oldAdditions = nil;
        [player release], player = nil;
    }
    [mainThreadManagedObjectContext release], mainThreadManagedObjectContext = nil;
    
    [super dealloc];
}

- (void) updateOnReady
{
    self.youngDictionaryCSS = [NSString stringWithContentsOfFile:[[[SCHDictionaryDownloadManager sharedDownloadManager] dictionaryDirectory] stringByAppendingPathComponent:@"YoungDictionary.css"]
                                                        encoding:NSUTF8StringEncoding 
                                                           error:nil];
    
    self.oldDictionaryCSS = [NSString stringWithContentsOfFile:[[[SCHDictionaryDownloadManager sharedDownloadManager] dictionaryDirectory] stringByAppendingPathComponent:@"OldDictionary.css"]
                                                      encoding:NSUTF8StringEncoding 
                                                         error:nil];

    self.youngAdditions = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"YoungDictionary-additions" ofType:@"css"]
                                                    encoding:NSUTF8StringEncoding 
                                                       error:nil];
    
    self.oldAdditions = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"OldDictionary-additions" ofType:@"css"]
                                                  encoding:NSUTF8StringEncoding 
                                                     error:nil];
    
    
    // prime the audio player - eliminates delay on playing of word
    NSString *mp3Path = [NSString stringWithFormat:@"%@/Pronunciation/pron_a.mp3", 
                         [[SCHDictionaryDownloadManager sharedDownloadManager] dictionaryDirectory]];
    
    NSURL *url = [NSURL fileURLWithPath:mp3Path];
    
    NSError *error;
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    [self.player prepareToPlay];
    self.player = nil;
}

#pragma mark - Dictionary Definition Methods

- (SCHDictionaryEntry *) entryForWord: (NSString *) dictionaryWord category: (NSString *) category
{
    NSAssert([NSThread isMainThread], @"entryForWord must be called on main thread");
    
    if ([[SCHDictionaryDownloadManager sharedDownloadManager] dictionaryProcessingState] != SCHDictionaryProcessingStateReady) {
        NSLog(@"Dictionary is not ready yet!");
        return nil;
    }
    
    // if the category isn't YD or OD, return
    if (!category ||
        ([category compare:kSCHDictionaryYoungReader] != NSOrderedSame && 
         [category compare:kSCHDictionaryOlderReader] != NSOrderedSame)) 
    {
        NSLog(@"Warning: unrecognised category %@ in HTMLForWord.", category);
        return nil;
    }
    
    // remove whitespace and punctuation characters
    NSString *trimmedWord = [dictionaryWord stringByTrimmingCharactersInSet:
                             [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    trimmedWord = [trimmedWord stringByTrimmingCharactersInSet:
                   [NSCharacterSet punctuationCharacterSet]];
    trimmedWord = [trimmedWord lowercaseString];
    
    
    // fetch the word form from core data
    SCHDictionaryWordForm *wordForm = [self wordFormForBaseWord:trimmedWord category:category];
    
    if (!wordForm) {
        return nil;
    }
    
    // fetch the dictionary entry
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:kSCHDictionaryEntry inManagedObjectContext:self.mainThreadManagedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"baseWordID == %@ AND category == %@", wordForm.baseWordID, category];
    
//    NSLog(@"attempting to get dictionary entry for %@, category %@", wordForm.baseWordID, category);
    
    [fetchRequest setPredicate:pred];
    
    NSError *error = nil;
    
	NSArray *results = [self.mainThreadManagedObjectContext executeFetchRequest:fetchRequest error:&error];
	
	[fetchRequest release];
	
	if (results == nil) {
		NSLog(@"error when retrieving definition for word %@: %@", dictionaryWord, [error localizedDescription]);
		return nil;
	}
	
	if ([results count] != 1) {
		NSLog(@"error when retrieving definition for word %@: %d results retrieved.", dictionaryWord, [results count]);
		return nil;
	}
    
    SCHDictionaryEntry *entry = [results objectAtIndex:0];
    
    return entry;
}

- (SCHDictionaryWordForm *) wordFormForBaseWord: (NSString *) baseWord category: (NSString *) category
{
    NSAssert([NSThread isMainThread], @"wordFormForBaseWord must be called on main thread");
    
    if ([[SCHDictionaryDownloadManager sharedDownloadManager] dictionaryProcessingState] != SCHDictionaryProcessingStateReady) {
        NSLog(@"Dictionary is not ready yet!");
        return nil;
    }
    
    // if the category isn't YD or OD, return
    if (!category ||
        ([category compare:kSCHDictionaryYoungReader] != NSOrderedSame && 
         [category compare:kSCHDictionaryOlderReader] != NSOrderedSame)) 
    {
        NSLog(@"Warning: unrecognised category %@ in HTMLForWord.", category);
        return nil;
    }
    
    // fetch the word form from core data
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:kSCHDictionaryWordForm inManagedObjectContext:self.mainThreadManagedObjectContext];
    [fetchRequest setEntity:entity];
    entity = nil;
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"word == %@", baseWord];
    
    [fetchRequest setPredicate:pred];
    pred = nil;
    
	NSError *error = nil;				
	NSArray *results = [self.mainThreadManagedObjectContext executeFetchRequest:fetchRequest error:&error];
	
    [fetchRequest release], fetchRequest = nil;
	
	if (!results) {
		NSLog(@"error when retrieving word %@: %@", baseWord, [error localizedDescription]);
		return nil;
	}
    
    for (SCHDictionaryWordForm *form in results) {
        NSLog(@"Word: %@, Root: %@ Category: %@", form.word, form.rootWord, form.category);
    }
    
	if ([results count] != 1) {
		NSLog(@"error when retrieving word %@: %d results retrieved.", baseWord, [results count]);
		return nil;
	}
    
    
    SCHDictionaryWordForm *wordForm = [results objectAtIndex:0];
    return wordForm;
}

- (NSString *) HTMLForWord: (NSString *) dictionaryWord category: (NSString *) category
{
    NSAssert([NSThread isMainThread], @"HTMLForWord must be called on main thread");
    
    if ([[SCHDictionaryDownloadManager sharedDownloadManager] dictionaryProcessingState] != SCHDictionaryProcessingStateReady) {
        NSLog(@"Dictionary is not ready yet!");
        return nil;
    }
    
    // if the category isn't YD or OD, return
    if (!category ||
        ([category compare:kSCHDictionaryYoungReader] != NSOrderedSame && 
         [category compare:kSCHDictionaryOlderReader] != NSOrderedSame)) 
    {
        NSLog(@"Warning: unrecognised category %@ in HTMLForWord.", category);
        return nil;
    }
    
    SCHDictionaryEntry *entry = [self entryForWord:dictionaryWord category:category];
    
    if (!entry) {
        return nil;
    }
    
    // use the offset to fetch the HTML from entry table
    long offset = [entry.fileOffset longValue];
    
    __block NSString *result = nil;
    
    NSString *filePath = [[[SCHDictionaryDownloadManager sharedDownloadManager] dictionaryTextFilesDirectory] stringByAppendingPathComponent:@"EntryTable.txt"];
    
    dispatch_sync(self.dictionaryAccessQueue, ^{
        FILE *file = fopen([filePath UTF8String], "r");
        
        char line[kSCHDictionaryManifestEntryEntryTableBufferSize];
        char *completeLine, *start, *entryID, *headword, *level, *entryXML;
        NSMutableData *collectLine = nil;   
        NSString *tmpCompleteLine = nil;
        size_t strLength = 0;
        
        //NSLog(@"Seeking to offset %ld", offset);
        
        if (file != NULL) {
            setlinebuf(file);
            fseek(file, offset, 0);
            while (fgets(line, kSCHDictionaryManifestEntryEntryTableBufferSize, file) != NULL) {
                if (strLength = strlen(line), strLength > 0 && line[strLength-1] == '\n') {        
                    
                    if (collectLine == nil) {
                        completeLine = line;
                    } else {
                        [collectLine appendBytes:line length:strlen(line)];                                        
                        [collectLine appendBytes:(char []){'\0'} length:1];
                        [tmpCompleteLine release];
                        tmpCompleteLine = [[NSString alloc] initWithData:collectLine encoding:NSUTF8StringEncoding];
                        completeLine = (char *)[tmpCompleteLine UTF8String];
                        [collectLine release], collectLine = nil;
                    }
                    
                    start = strtok(completeLine, kSCHDictionaryManifestEntryColumnSeparator);
                    if (start != NULL) {
                        entryID = strtok(NULL, kSCHDictionaryManifestEntryColumnSeparator);                    // MATCH
                        if (entryID != NULL) {
                            headword = strtok(NULL, kSCHDictionaryManifestEntryColumnSeparator);
                            if (headword != NULL) {
                                level = strtok(NULL, kSCHDictionaryManifestEntryColumnSeparator);              // MATCH YD/OD
                                if (level != NULL) {
                                    entryXML = strtok(NULL, kSCHDictionaryManifestEntryColumnSeparator);
                                    if (entryXML != NULL) {
                                        entryXML[strlen(entryXML)-1] = '\0';    // remove the line end
                                        result = [[NSString stringWithUTF8String:entryXML] retain];
                                        break;
                                    }
                                }
                            }
                        }
                    }
                } else {
                    if (collectLine == nil) {
                        collectLine = [[NSMutableData alloc] initWithBytes:line length:strlen(line)];
                    } else {
                        [collectLine appendBytes:line length:strlen(line)];
                    }
                }
            }
            [collectLine release], collectLine = nil;
            [tmpCompleteLine release], tmpCompleteLine = nil;
            
            fclose(file);
        }
    });
    
    // write HEAD from YoungDictionary.css/OldDictionary.css
    // remove existing head from string
    NSRange headEnd = [result rangeOfString:@"</head>" options:NSCaseInsensitiveSearch]; 
    
    NSString *headless = [result substringFromIndex:headEnd.location + headEnd.length];
    
    NSString *cssText = nil;
    
    if ([category compare:kSCHDictionaryYoungReader] == NSOrderedSame) {
        cssText = self.youngDictionaryCSS;
    } else {
        cssText = self.oldDictionaryCSS;
    }
    
    NSString *resultWithNewHead = [NSString stringWithFormat:@"<html>%@%@", cssText, headless];

    // add bitwink additions to the CSS

    if ([category compare:kSCHDictionaryYoungReader] == NSOrderedSame) {
        cssText = self.youngAdditions;
    } else {
        cssText = self.oldAdditions;
    }

    headEnd = [resultWithNewHead rangeOfString:@"</head>" options:NSCaseInsensitiveSearch];
    
    NSString *resultWithAdditions = [NSString stringWithFormat:@"%@%@%@", 
                                     [resultWithNewHead substringToIndex:headEnd.location],
                                     cssText,
                                     [resultWithNewHead substringFromIndex:headEnd.location]];
    
    return resultWithAdditions;
}

- (void) speakWord: (NSString *) dictionaryWord category: (NSString *) category
{
    
    if ([[SCHDictionaryDownloadManager sharedDownloadManager] dictionaryProcessingState] != SCHDictionaryProcessingStateReady) {
        NSLog(@"Dictionary is not ready yet!");
        return;
    }
    
    // if the category isn't YD or OD, return
    if (!category ||
        ([category compare:kSCHDictionaryYoungReader] != NSOrderedSame && 
         [category compare:kSCHDictionaryOlderReader] != NSOrderedSame)) 
    {
        NSLog(@"Warning: unrecognised category %@ in HTMLForWord.", category);
        return;
    }

    /*
    SCHDictionaryEntry *entry = [self entryForWord:dictionaryWord category:category];
    
    // if no result is returned, don't try
    if (!entry) {
        return;
    }
    */
    
    // remove whitespace and punctuation characters
    NSString *trimmedWord = [dictionaryWord stringByTrimmingCharactersInSet:
                             [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    trimmedWord = [trimmedWord stringByTrimmingCharactersInSet:
                   [NSCharacterSet punctuationCharacterSet]];
    trimmedWord = [trimmedWord lowercaseString];

    NSString *mp3Path = [NSString stringWithFormat:@"%@/Pronunciation/pron_%@.mp3", 
                         [[SCHDictionaryDownloadManager sharedDownloadManager] dictionaryDirectory], trimmedWord];
    
    SCHDictionaryWordForm *rootWord = [[SCHDictionaryAccessManager sharedAccessManager] wordFormForBaseWord:trimmedWord category:category];
    
    NSString *mp3PathForRootWord = [NSString stringWithFormat:@"%@/Pronunciation/pron_%@.mp3", 
                                    [[SCHDictionaryDownloadManager sharedDownloadManager] dictionaryDirectory], rootWord.rootWord];
    
    BOOL trimmedWordExists = [[NSFileManager defaultManager] fileExistsAtPath:mp3Path];
    BOOL rootWordExists = [[NSFileManager defaultManager] fileExistsAtPath:mp3PathForRootWord];
    
    if (trimmedWordExists || (!trimmedWordExists && rootWordExists && [category compare:kSCHDictionaryOlderReader] == NSOrderedSame)) {
        
        NSURL *url = nil;
        
        if (!trimmedWordExists) {
            url = [NSURL fileURLWithPath:mp3PathForRootWord];
        } else {
            url = [NSURL fileURLWithPath:mp3Path];
        }
        
        NSError *error;
        
        if (self.player) {
            [self.player stop];
            self.player = nil;
        }
        
        self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        
        if (self.player == nil) {
            NSLog(@"Error playing word text: %@", [error localizedDescription]);
        } else {
            [self.player play];
        }
    } else {
        NSLog(@"No word file exists for word \"%@\".", trimmedWord);
    }
    
}

- (void) speakYoungerWordDefinition: (NSString *) dictionaryWord
{
    if ([[SCHDictionaryDownloadManager sharedDownloadManager] dictionaryProcessingState] != SCHDictionaryProcessingStateReady) {
        NSLog(@"Dictionary is not ready yet!");
        return;
    }
    
    SCHDictionaryEntry *entry = [self entryForWord:dictionaryWord category:kSCHDictionaryYoungReader];
    
    // if no result is returned, don't try
    if (!entry) {
        return;
    }
    
    //    NSLog(@"Dictionary entry: %@ %@ %@ %@", entry.baseWordID, entry.word, entry.category, [entry.fileOffset stringValue]);
    
    NSString *mp3Path = [NSString stringWithFormat:@"%@/ReadthroughAudio/fd_%@.mp3", 
                         [[SCHDictionaryDownloadManager sharedDownloadManager] dictionaryDirectory], entry.baseWordID];
    
    NSURL *url = [NSURL fileURLWithPath:mp3Path];
    
    NSError *error;
    
    if (self.player) {
        [self.player stop];
        self.player = nil;
    }
    
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    
	if (self.player == nil) {
		NSLog(@"Error playing word definition: %@", [error localizedDescription]);
    } else {
		[self.player play];
    }
    
}

- (void) stopAllSpeaking
{
    [self.player stop];
    self.player = nil;
}


@end
