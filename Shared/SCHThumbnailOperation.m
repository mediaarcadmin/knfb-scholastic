//
//  SCHThumbnailOperation.m
//  Scholastic
//
//  Created by Gordon Christie on 11/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHThumbnailOperation.h"
#import "SCHThumbnailFactory.h"
#import "SCHProcessingManager.h"
#import "SCHAppBook.h"
#import "SCHBookManager.h"

@implementation SCHThumbnailOperation

@synthesize aspect;
@synthesize size;
@synthesize flip;

- (void)dealloc {
	[super dealloc];
}

// overriding setBookInfo - image operation doesn't set the book as processing
// since image processing can happen while the book is already processing, as long
// as the cover image is set.
- (void) setIsbn:(NSString *) newIsbn
{
    [self setIsbnWithoutUpdatingProcessingStatus:newIsbn];
}

#pragma mark - Book Operation methods

- (void)beginOperation 
{
	
	// for testing: insert a random processing delay
	//	int randomValue = (arc4random() % 5) + 3;
	//	[NSThread sleepForTimeInterval:randomValue];

	SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:self.isbn];
	
	NSString *fullImagePath = [book coverImagePath];
	NSString *thumbPath = [book thumbPathForSize:size];
	
	UIImage *thumbImage = nil;
	
    NSFileManager *threadLocalFileManager = [[[NSFileManager alloc] init] autorelease];
    
    CGSize coverSize = CGSizeZero;
    
	if ([threadLocalFileManager fileExistsAtPath:thumbPath]) {
		thumbImage = [SCHThumbnailFactory imageWithPath:thumbPath];
        
        CGSize fullSize = [book bookCoverImageSize];
        
        coverSize = [SCHThumbnailFactory coverSizeForImageOfSize:fullSize
                                                 thumbNailOfSize:thumbImage.size aspect:self.aspect];
        
	} else {
        UIImage *fullImage = [SCHThumbnailFactory imageWithPath:fullImagePath];
        
        
        if (fullImage) {
//            [[SCHBookManager sharedBookManager] threadSafeUpdateBookWithISBN:self.isbn
//                                                                    setValue:[NSNumber numberWithFloat:fullImage.size.width]
//                                                                      forKey:kSCHAppBookCoverImageWidth];
//            
//            [[SCHBookManager sharedBookManager] threadSafeUpdateBookWithISBN:self.isbn
//                                                                    setValue:[NSNumber numberWithFloat:fullImage.size.height]
//                                                                      forKey:kSCHAppBookCoverImageHeight];
            
            thumbImage = [SCHThumbnailFactory thumbnailImageOfSize:self.size 
														  forImage:fullImage
                                                    maintainAspect:self.aspect];
            
            if (thumbImage) {
                NSData *pngData = UIImagePNGRepresentation(thumbImage);
                [pngData writeToFile:thumbPath atomically:YES];
            }
        }
        
 	}
    
	if (thumbImage) {
		NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                  self.isbn, @"isbn",
								  [NSValue valueWithCGSize:size], @"thumbSize", 
								  thumbImage, @"image", 
								  nil];
		
		[self performSelectorOnMainThread:@selector(imageReady:) 
							   withObject:userInfo 
							waitUntilDone:YES];
	}
    
    [self endOperation];    
}

// used on the main thread - notifies the UI when new thumbs are available
// specifically used by SCHASyncBookCoverImageView
- (void)imageReady:(NSDictionary *)userInfo {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SCHNewImageAvailable" object:nil userInfo:userInfo];
}

@end
