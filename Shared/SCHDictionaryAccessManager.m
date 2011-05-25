//
//  SCHDictionaryAccessManager.m
//  Scholastic
//
//  Created by Gordon Christie on 25/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHDictionaryAccessManager.h"
#import "SCHDictionaryDownloadManager.h"
#import <CoreData/CoreData.h>
#import "SCHDictionaryWordForm.h"
#import "SCHBookManager.h"
#import "SCHDictionaryEntry.h"


@implementation SCHDictionaryAccessManager

@synthesize dictionaryAccessQueue;

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

- (void) dealloc
{
    if (dictionaryAccessQueue) {
        dispatch_release(dictionaryAccessQueue);
        dictionaryAccessQueue = nil;
    }
    [super dealloc];
}

#pragma mark -
#pragma mark Dictionary Definition Methods

- (NSString *) HTMLForWord: (NSString *) dictionaryWord category: (NSString *) category
{
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
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:kSCHDictionaryWordForm 
											  inManagedObjectContext:[[SCHBookManager sharedBookManager] managedObjectContextForCurrentThread]];
    [fetchRequest setEntity:entity];
    entity = nil;
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"word == %@", trimmedWord];
    
    [fetchRequest setPredicate:pred];
    pred = nil;
    
	NSError *error = nil;				
	NSArray *results = [[[SCHBookManager sharedBookManager] managedObjectContextForCurrentThread] executeFetchRequest:fetchRequest error:&error];
	
    [fetchRequest release], fetchRequest = nil;
	
	if (error) {
		NSLog(@"error when retrieving word %@: %@", dictionaryWord, [error localizedDescription]);
		return nil;
	}
	
	if (!results || [results count] != 1) {
        int resultCount = -1;
        if (results) {
            resultCount = [results count];
        }
        
		NSLog(@"error when retrieving word %@: %d results retrieved.", dictionaryWord, resultCount);
		return nil;
	}
    
    
    SCHDictionaryWordForm *wordForm = [results objectAtIndex:0];
    results = nil;
    [[[SCHBookManager sharedBookManager] managedObjectContextForCurrentThread] refreshObject:wordForm mergeChanges:YES];
    
    fetchRequest = [[NSFetchRequest alloc] init];
    
    entity = [NSEntityDescription entityForName:kSCHDictionaryEntry
                         inManagedObjectContext:[[SCHBookManager sharedBookManager] managedObjectContextForCurrentThread]];
    
    [fetchRequest setEntity:entity];
    
    pred = [NSPredicate predicateWithFormat:@"baseWordID == %@ AND category == %@", wordForm.baseWordID, category];
    
    NSLog(@"attempting to get dictionary entry for %@, category %@", wordForm.baseWordID, category);
    
    [fetchRequest setPredicate:pred];
    pred = nil;
    
	results = [[[SCHBookManager sharedBookManager] managedObjectContextForCurrentThread] executeFetchRequest:fetchRequest error:&error];
	
	[fetchRequest release];
	
	if (error) {
		NSLog(@"error when retrieving definition for word %@: %@", dictionaryWord, [error localizedDescription]);
		return nil;
	}
	
	if (!results || [results count] != 1) {
        int resultCount = -1;
        if (results) {
            resultCount = [results count];
        }
        
		NSLog(@"error when retrieving definition for word %@: %d results retrieved.", dictionaryWord, resultCount);
		return nil;
	}
    
    SCHDictionaryEntry *entry = [results objectAtIndex:0];
    
    NSLog(@"Dictionary entry: %@ %@ %@ %@", entry.baseWordID, entry.word, entry.category, [entry.fileOffset stringValue]);
    
    results = nil;
    
    long offset = [entry.fileOffset longValue];
    
    __block NSString *result = nil;
    
    SCHDictionaryDownloadManager *dictManager = [SCHDictionaryDownloadManager sharedDownloadManager];
    
    NSString *filePath = [[dictManager dictionaryTextFilesDirectory] stringByAppendingPathComponent:@"EntryTable.txt"];
    
    
    //    [self.entryTableMutationLock lock];
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
                                        result = [NSString stringWithUTF8String:entryXML];
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
    
    return result;
}


@end
