//
//  SCHBookStoryInteractionsTests.m
//  Scholastic
//
//  Created by Neil Gall on 03/11/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "SCHStoryInteraction.h"
#import "SCHBookStoryInteractions.h"

@interface TestStoryInteraction : SCHStoryInteraction

@property (nonatomic, assign) BOOL interactsWithPage;
@property (nonatomic, assign) NSInteger questionCount;
@property (nonatomic, assign) NSInteger questionCountOnLeft;
@property (nonatomic, assign) NSInteger questionCountOnRight;

+ (TestStoryInteraction *)storyInteractionWithPageNumber:(NSInteger)pageNumber;

@end

@implementation TestStoryInteraction

@synthesize interactsWithPage;
@synthesize questionCount;
@synthesize questionCountOnLeft;
@synthesize questionCountOnRight;

+ (TestStoryInteraction *)storyInteractionWithPageNumber:(NSInteger)pageNumber
{
    TestStoryInteraction *tsi = [[TestStoryInteraction alloc] init];
    tsi.documentPageNumber = pageNumber;
    tsi.interactsWithPage = NO;
    tsi.questionCount = 2;
    tsi.questionCountOnLeft = 2;
    tsi.questionCountOnRight = 2;
    return [tsi autorelease];
}

- (NSInteger)numberOfQuestionsWithPageAssociation:(enum SCHStoryInteractionQuestionPageAssociation)aPageAssociation
                                     withPageSize:(CGSize)pageSize
{
    switch (aPageAssociation) {
        case SCHStoryInteractionQuestionOnLeftPage:
            return questionCountOnLeft;
        case SCHStoryInteractionQuestionOnRightPage:
            return questionCountOnRight;
        case SCHStoryInteractionQuestionOnBothPages:
            return questionCount;
        default:
            NSAssert(NO, @"bad pageAssociation=%d", aPageAssociation);
            return 0;
    }
}

- (BOOL)requiresInteractionWithPage 
{
    return interactsWithPage;
}

@end

@interface Fixture : NSObject
@property (nonatomic, retain) NSArray *testStoryInteractions;
@property (nonatomic, retain) SCHBookStoryInteractions *book;
@property (nonatomic, assign) BOOL oddPagesOnLeft;
@end

@implementation Fixture 

@synthesize testStoryInteractions;
@synthesize book;
@synthesize oddPagesOnLeft;

- (id)init 
{
    if ((self = [super init])) {
        testStoryInteractions = [[NSArray alloc] initWithObjects:
                                 [TestStoryInteraction storyInteractionWithPageNumber:4],
                                 [TestStoryInteraction storyInteractionWithPageNumber:6],
                                 [TestStoryInteraction storyInteractionWithPageNumber:8],
                                 nil];
        oddPagesOnLeft = NO;
    }
    return self;
}

- (void)dealloc
{
    [testStoryInteractions release], testStoryInteractions = nil;
    [book release], book = nil;
    [super dealloc];
}

- (SCHBookStoryInteractions *)book
{
    // lazily init, allowing per-test modifications to the test fixture first
    if (book == nil) {
        book = [[SCHBookStoryInteractions alloc] init];
        book.oddPageIndicesAreLeftPages = self.oddPagesOnLeft;
        book.storyInteractions = self.testStoryInteractions;
    }
    return book;
}

- (TestStoryInteraction *)storyInteractionAtIndex:(NSInteger)index
{
    return [self.testStoryInteractions objectAtIndex:index];
}

@end

@interface SCHBookStoryInteractionsTests : SenTestCase {
    Fixture *fixture;
}
@end

@implementation SCHBookStoryInteractionsTests

- (void)setUp
{
    fixture = [[Fixture alloc] init];
}

- (void)tearDown
{
    [fixture release], fixture = nil;
}

- (void)testStoryInteractionLookupAll
{
    NSArray *all = [fixture.book allStoryInteractionsExcludingInteractionWithPage:NO];
    STAssertEqualObjects(all, fixture.testStoryInteractions, @"incorrect response from allStoryInteractionsExcludingInteractionsWithPage");
}

- (void)testStoryInteractionLookupByPageWithNoInteractionsExcluded
{
    NSArray *page4 = [fixture.book storyInteractionsForPageIndices:NSMakeRange(4, 1)
                              excludingInteractionWithPage:NO];
    STAssertEquals([page4 count], 1U, @"one SI expected on page 4");
    STAssertEquals([page4 objectAtIndex:0], [fixture storyInteractionAtIndex:0], @"first SI expected on page 4");
    
    NSArray *page6 = [fixture.book storyInteractionsForPageIndices:NSMakeRange(6, 1)
                              excludingInteractionWithPage:NO];
    STAssertEquals([page6 count], 1U, @"one SI expected on page 6");
    STAssertEquals([page6 objectAtIndex:0], [fixture storyInteractionAtIndex:1], @"second SI expected on page 6");

    NSArray *page8 = [fixture.book storyInteractionsForPageIndices:NSMakeRange(8, 1)
                              excludingInteractionWithPage:NO];
    STAssertEquals([page8 count], 1U, @"one SI expected on page 8");
    STAssertEquals([page8 objectAtIndex:0], [fixture storyInteractionAtIndex:2], @"third SI expected on page 8");

    NSArray *pages4to6 = [fixture.book storyInteractionsForPageIndices:NSMakeRange(4, 3)
                              excludingInteractionWithPage:NO];
    STAssertEquals([pages4to6 count], 2U, @"two SI expected on pages 4-6");
    STAssertEquals([pages4to6 objectAtIndex:0], [fixture storyInteractionAtIndex:0], @"first SI expected on page 4");
    STAssertEquals([pages4to6 objectAtIndex:1], [fixture storyInteractionAtIndex:1], @"second SI expected on page 6");

    NSArray *pages1to15 = [fixture.book storyInteractionsForPageIndices:NSMakeRange(1, 15)
                                  excludingInteractionWithPage:NO];
    STAssertEquals([pages1to15 count], 3U, @"three SI expected on pages 1-15");
    STAssertEquals([pages1to15 objectAtIndex:0], [fixture storyInteractionAtIndex:0], @"first SI expected on page 4");
    STAssertEquals([pages1to15 objectAtIndex:1], [fixture storyInteractionAtIndex:1], @"second SI expected on page 6");
    STAssertEquals([pages1to15 objectAtIndex:2], [fixture storyInteractionAtIndex:2], @"third SI expected on page 8");
}

- (void)testStoryInteractionLookupWithInteractionsExcluded
{
    [[fixture storyInteractionAtIndex:1] setInteractsWithPage:YES];

    NSArray *pages1to15 = [fixture.book storyInteractionsForPageIndices:NSMakeRange(1, 15)
                                   excludingInteractionWithPage:YES];
    STAssertEquals([pages1to15 count], 2U, @"three non-page-interacting SI expected on pages 1-15");
    STAssertEquals([pages1to15 objectAtIndex:0], [fixture storyInteractionAtIndex:0], @"first SI expected on page 4");
    STAssertEquals([pages1to15 objectAtIndex:1], [fixture storyInteractionAtIndex:2], @"third SI expected on page 8");
}

- (void)testStoryInterationLookupWithInteractionSplitOverTwoPages_OddPagesOnRight
{
    // set the first SI to have 1 question on page 4 and 2 on page 5
    [fixture storyInteractionAtIndex:0].questionCount = 3;
    [fixture storyInteractionAtIndex:0].questionCountOnLeft = 1;
    [fixture storyInteractionAtIndex:0].questionCountOnRight = 2;
    
    NSArray *page4 = [fixture.book storyInteractionsForPageIndices:NSMakeRange(4, 1) excludingInteractionWithPage:NO];
    STAssertEquals([page4 count], 1U, @"expect 1 SI on page 4");
    
    NSArray *page5 = [fixture.book storyInteractionsForPageIndices:NSMakeRange(5, 1) excludingInteractionWithPage:NO];
    STAssertEquals([page5 count], 1U, @"expect 1 SI on page 5");
    STAssertEqualObjects(page4, page5, @"expect same SI on pages 4 and 5");
    
    NSArray *pages4to5 = [fixture.book storyInteractionsForPageIndices:NSMakeRange(4, 2) excludingInteractionWithPage:NO];
    STAssertEquals([pages4to5 count], 1U, @"expect 1 SI on pages 4-5");
    STAssertEqualObjects(page4, pages4to5, @"expect same SI on page 4 and pages 4-5");
}

- (void)testStoryInterationLookupWithInteractionSplitOverTwoPages_OddPagesOnLeft
{
    // set the first SI to have 1 question on page 3 and 2 on page 4
    [fixture storyInteractionAtIndex:0].questionCount = 3;
    [fixture storyInteractionAtIndex:0].questionCountOnLeft = 1;
    [fixture storyInteractionAtIndex:0].questionCountOnRight = 2;
    fixture.oddPagesOnLeft = YES;
    
    NSArray *page3 = [fixture.book storyInteractionsForPageIndices:NSMakeRange(3, 1) excludingInteractionWithPage:NO];
    STAssertEquals([page3 count], 1U, @"expect 1 SI on page 3");
    
    NSArray *page4 = [fixture.book storyInteractionsForPageIndices:NSMakeRange(4, 1) excludingInteractionWithPage:NO];
    STAssertEquals([page4 count], 1U, @"expect 1 SI on page 4");
    STAssertEqualObjects(page3, page4, @"expect same SI on pages 3 and 4");
    
    NSArray *pages3to4 = [fixture.book storyInteractionsForPageIndices:NSMakeRange(3, 2) excludingInteractionWithPage:NO];
    STAssertEquals([pages3to4 count], 1U, @"expect 1 SI on pages 3-4");
    STAssertEqualObjects(page3, pages3to4, @"expect same SI on page 3 and pages 3-4");
}

- (void)testStoryInteractionQuestionCountForNormalStoryInteractions
{
    [fixture storyInteractionAtIndex:0].questionCount = 2;
    [fixture storyInteractionAtIndex:0].questionCountOnLeft = 2;
    [fixture storyInteractionAtIndex:0].questionCountOnRight = 2;
    [fixture storyInteractionAtIndex:1].questionCount = 3;
    [fixture storyInteractionAtIndex:1].questionCountOnLeft = 3;
    [fixture storyInteractionAtIndex:1].questionCountOnRight = 3;
    [fixture storyInteractionAtIndex:2].questionCount = 4;
    [fixture storyInteractionAtIndex:2].questionCountOnLeft = 4;
    [fixture storyInteractionAtIndex:2].questionCountOnRight = 4;
    
    STAssertEquals([fixture.book storyInteractionQuestionCountForPageIndices:NSMakeRange(4, 1)], 2, @"expect 2 questions on page 4");
    STAssertEquals([fixture.book storyInteractionQuestionCountForPageIndices:NSMakeRange(5, 1)], 0, @"expect 0 questions on page 5");
    STAssertEquals([fixture.book storyInteractionQuestionCountForPageIndices:NSMakeRange(4, 2)], 2, @"expect 2 questions on page 4-5");

    STAssertEquals([fixture.book storyInteractionQuestionCountForPageIndices:NSMakeRange(6, 1)], 3, @"expect 3 questions on page 6");
    STAssertEquals([fixture.book storyInteractionQuestionCountForPageIndices:NSMakeRange(7, 1)], 0, @"expect 0 questions on page 7");
    STAssertEquals([fixture.book storyInteractionQuestionCountForPageIndices:NSMakeRange(6, 2)], 3, @"expect 3 questions on page 6-7");

    STAssertEquals([fixture.book storyInteractionQuestionCountForPageIndices:NSMakeRange(8, 1)], 4, @"expect 4 questions on page 8");
    STAssertEquals([fixture.book storyInteractionQuestionCountForPageIndices:NSMakeRange(9, 1)], 0, @"expect 0 questions on page 9");
    STAssertEquals([fixture.book storyInteractionQuestionCountForPageIndices:NSMakeRange(8, 2)], 4, @"expect 4 questions on page 8-9");
}

- (void)testStoryInteractionQuestionCountForStoryInteractionSplitOverTwoPages_OddPagesOnRight
{
    [fixture storyInteractionAtIndex:0].questionCount = 2;
    [fixture storyInteractionAtIndex:0].questionCountOnLeft = 1;
    [fixture storyInteractionAtIndex:0].questionCountOnRight = 1;
    [fixture storyInteractionAtIndex:1].questionCount = 3;
    [fixture storyInteractionAtIndex:1].questionCountOnLeft = 1;
    [fixture storyInteractionAtIndex:1].questionCountOnRight = 2;
    [fixture storyInteractionAtIndex:2].questionCount = 4;
    [fixture storyInteractionAtIndex:2].questionCountOnLeft = 1;
    [fixture storyInteractionAtIndex:2].questionCountOnRight = 3;
    
    STAssertEquals([fixture.book storyInteractionQuestionCountForPageIndices:NSMakeRange(4, 1)], 1, @"expect 1 questions on page 4");
    STAssertEquals([fixture.book storyInteractionQuestionCountForPageIndices:NSMakeRange(5, 1)], 1, @"expect 1 questions on page 5");
    STAssertEquals([fixture.book storyInteractionQuestionCountForPageIndices:NSMakeRange(4, 2)], 2, @"expect 2 questions on page 4-5");
    
    STAssertEquals([fixture.book storyInteractionQuestionCountForPageIndices:NSMakeRange(6, 1)], 1, @"expect 1 questions on page 6");
    STAssertEquals([fixture.book storyInteractionQuestionCountForPageIndices:NSMakeRange(7, 1)], 2, @"expect 2 questions on page 7");
    STAssertEquals([fixture.book storyInteractionQuestionCountForPageIndices:NSMakeRange(6, 2)], 3, @"expect 3 questions on page 6-7");
    
    STAssertEquals([fixture.book storyInteractionQuestionCountForPageIndices:NSMakeRange(8, 1)], 1, @"expect 1 questions on page 8");
    STAssertEquals([fixture.book storyInteractionQuestionCountForPageIndices:NSMakeRange(9, 1)], 3, @"expect 3 questions on page 9");
    STAssertEquals([fixture.book storyInteractionQuestionCountForPageIndices:NSMakeRange(8, 2)], 4, @"expect 4 questions on page 8-9");
}

- (void)testStoryInteractionQuestionCountForStoryInteractionSplitOverTwoPages_OddPagesOnLeft
{
    fixture.oddPagesOnLeft = YES;
    [fixture storyInteractionAtIndex:0].questionCount = 2;
    [fixture storyInteractionAtIndex:0].questionCountOnLeft = 1;
    [fixture storyInteractionAtIndex:0].questionCountOnRight = 1;
    [fixture storyInteractionAtIndex:1].questionCount = 3;
    [fixture storyInteractionAtIndex:1].questionCountOnLeft = 1;
    [fixture storyInteractionAtIndex:1].questionCountOnRight = 2;
    [fixture storyInteractionAtIndex:2].questionCount = 4;
    [fixture storyInteractionAtIndex:2].questionCountOnLeft = 1;
    [fixture storyInteractionAtIndex:2].questionCountOnRight = 3;
    
    STAssertEquals([fixture.book storyInteractionQuestionCountForPageIndices:NSMakeRange(3, 1)], 1, @"expect 1 questions on page 3");
    STAssertEquals([fixture.book storyInteractionQuestionCountForPageIndices:NSMakeRange(4, 1)], 1, @"expect 1 questions on page 4");
    STAssertEquals([fixture.book storyInteractionQuestionCountForPageIndices:NSMakeRange(3, 2)], 2, @"expect 2 questions on page 3-4");
    
    STAssertEquals([fixture.book storyInteractionQuestionCountForPageIndices:NSMakeRange(5, 1)], 1, @"expect 1 questions on page 5");
    STAssertEquals([fixture.book storyInteractionQuestionCountForPageIndices:NSMakeRange(6, 1)], 2, @"expect 2 questions on page 6");
    STAssertEquals([fixture.book storyInteractionQuestionCountForPageIndices:NSMakeRange(5, 2)], 3, @"expect 3 questions on page 5-6");
    
    STAssertEquals([fixture.book storyInteractionQuestionCountForPageIndices:NSMakeRange(7, 1)], 1, @"expect 1 questions on page 7");
    STAssertEquals([fixture.book storyInteractionQuestionCountForPageIndices:NSMakeRange(8, 1)], 3, @"expect 3 questions on page 8");
    STAssertEquals([fixture.book storyInteractionQuestionCountForPageIndices:NSMakeRange(7, 2)], 4, @"expect 4 questions on page 7-8");
}

- (void)testIncrementStoryInteractionCompletedQuestionCountForNormalStoryInteraction_1up
{
    [fixture storyInteractionAtIndex:0].questionCount = 2;
    [fixture storyInteractionAtIndex:0].questionCountOnLeft = 2;
    [fixture storyInteractionAtIndex:0].questionCountOnRight = 2;

    for (NSInteger page = 3; page <= 8; ++page) {
        STAssertEquals([fixture.book storyInteractionQuestionsCompletedForPageIndices:NSMakeRange(page, 1)], 0, @"expect 0 questions completed on page %d", page);
        if (page & 1) {
            STAssertTrue([fixture.book allQuestionsCompletedForPageIndices:NSMakeRange(page, 1)], @"expect complete on page %d (no SIs)", page);
        } else {
            STAssertFalse([fixture.book allQuestionsCompletedForPageIndices:NSMakeRange(page, 1)], @"expect not complete on page %d", page);
        }
    }
    STAssertEquals([fixture.book storyInteractionQuestionsCompletedForPageIndices:NSMakeRange(3, 6)], 0, @"expect 0 questions completed on pages 3-8");
    STAssertFalse([fixture.book allQuestionsCompletedForPageIndices:NSMakeRange(3, 6)], @"expect not complete on pages 3-8");
    
    [fixture.book incrementQuestionsCompletedForStoryInteraction:[fixture storyInteractionAtIndex:0] pageIndices:NSMakeRange(4, 1)];
    
    STAssertEquals([fixture.book storyInteractionQuestionsCompletedForPageIndices:NSMakeRange(4, 1)], 1, @"expect 1 questions completed on page 4");
    STAssertEquals([fixture.book storyInteractionQuestionsCompletedForPageIndices:NSMakeRange(5, 1)], 0, @"expect 0 questions completed on page 5");
    STAssertEquals([fixture.book storyInteractionQuestionsCompletedForPageIndices:NSMakeRange(4, 2)], 1, @"expect 1 questions completed on pages 4-5");
    STAssertFalse([fixture.book allQuestionsCompletedForPageIndices:NSMakeRange(4, 1)], @"expect not complete on page 4");
    
    [fixture.book incrementQuestionsCompletedForStoryInteraction:[fixture storyInteractionAtIndex:0] pageIndices:NSMakeRange(4, 1)];
    
    STAssertEquals([fixture.book storyInteractionQuestionsCompletedForPageIndices:NSMakeRange(4, 1)], 2, @"expect 2 questions completed on page 4");
    STAssertTrue([fixture.book allQuestionsCompletedForPageIndices:NSMakeRange(4, 1)], @"expect complete on page 4");
}

- (void)testIncrementStoryInteractionCompletedQuestionCountForNormalStoryInteraction_2up
{
    [fixture storyInteractionAtIndex:0].questionCount = 2;
    [fixture storyInteractionAtIndex:0].questionCountOnLeft = 2;
    [fixture storyInteractionAtIndex:0].questionCountOnRight = 2;
    
    STAssertEquals([fixture.book storyInteractionQuestionsCompletedForPageIndices:NSMakeRange(4, 2)], 0, @"expect 0 questions completed on pages 4-5");
    STAssertFalse([fixture.book allQuestionsCompletedForPageIndices:NSMakeRange(4, 2)], @"expect not complete on pages 4-5");
    
    [fixture.book incrementQuestionsCompletedForStoryInteraction:[fixture storyInteractionAtIndex:0] pageIndices:NSMakeRange(4, 2)];
    
    STAssertEquals([fixture.book storyInteractionQuestionsCompletedForPageIndices:NSMakeRange(4, 1)], 1, @"expect 1 questions completed on page 4");
    STAssertEquals([fixture.book storyInteractionQuestionsCompletedForPageIndices:NSMakeRange(5, 1)], 0, @"expect 0 questions completed on page 5");
    STAssertEquals([fixture.book storyInteractionQuestionsCompletedForPageIndices:NSMakeRange(4, 2)], 1, @"expect 1 questions completed on pages 4-5");
    STAssertFalse([fixture.book allQuestionsCompletedForPageIndices:NSMakeRange(4, 2)], @"expect not complete on page 4");
    
    [fixture.book incrementQuestionsCompletedForStoryInteraction:[fixture storyInteractionAtIndex:0] pageIndices:NSMakeRange(4, 2)];
    
    STAssertEquals([fixture.book storyInteractionQuestionsCompletedForPageIndices:NSMakeRange(4, 2)], 2, @"expect 2 questions completed on pages 4-5");
    STAssertTrue([fixture.book allQuestionsCompletedForPageIndices:NSMakeRange(4, 2)], @"expect complete on pages 4-5");   
}

- (void)testIncrementstoryInteractionCompletedQuestionCountForStoryInteractionSplitOverTwoPages_OddPagesOnRight
{
    [fixture storyInteractionAtIndex:0].questionCount = 3;
    [fixture storyInteractionAtIndex:0].questionCountOnLeft = 2;
    [fixture storyInteractionAtIndex:0].questionCountOnRight = 1;
    
    STAssertEquals([fixture.book storyInteractionQuestionsCompletedForPageIndices:NSMakeRange(4, 1)], 0, @"expect 0 questions completed on page 4");
    STAssertEquals([fixture.book storyInteractionQuestionsCompletedForPageIndices:NSMakeRange(5, 1)], 0, @"expect 0 questions completed on page 5");
    STAssertEquals([fixture.book storyInteractionQuestionsCompletedForPageIndices:NSMakeRange(4, 2)], 0, @"expect 0 questions completed on pages 4-5");
    STAssertFalse([fixture.book allQuestionsCompletedForPageIndices:NSMakeRange(4, 1)], @"expect not complete on page 4");
    STAssertFalse([fixture.book allQuestionsCompletedForPageIndices:NSMakeRange(5, 1)], @"expect not complete on page 5");
    STAssertFalse([fixture.book allQuestionsCompletedForPageIndices:NSMakeRange(4, 2)], @"expect not complete on pages 4-5");
    
    [fixture.book incrementQuestionsCompletedForStoryInteraction:[fixture storyInteractionAtIndex:0] pageIndices:NSMakeRange(4, 1)];
    
    STAssertEquals([fixture.book storyInteractionQuestionsCompletedForPageIndices:NSMakeRange(4, 1)], 1, @"expect 1 questions completed on page 4");
    STAssertEquals([fixture.book storyInteractionQuestionsCompletedForPageIndices:NSMakeRange(5, 1)], 0, @"expect 0 questions completed on page 5");
    STAssertEquals([fixture.book storyInteractionQuestionsCompletedForPageIndices:NSMakeRange(4, 2)], 1, @"expect 1 questions completed on pages 4-5");
    STAssertFalse([fixture.book allQuestionsCompletedForPageIndices:NSMakeRange(4, 1)], @"expect not complete on page 4");
    STAssertFalse([fixture.book allQuestionsCompletedForPageIndices:NSMakeRange(5, 1)], @"expect not complete on page 5");
    STAssertFalse([fixture.book allQuestionsCompletedForPageIndices:NSMakeRange(4, 2)], @"expect not complete on pages 4-5");
    
    [fixture.book incrementQuestionsCompletedForStoryInteraction:[fixture storyInteractionAtIndex:0] pageIndices:NSMakeRange(5, 1)];
    
    STAssertEquals([fixture.book storyInteractionQuestionsCompletedForPageIndices:NSMakeRange(4, 1)], 1, @"expect 1 questions completed on page 4");
    STAssertEquals([fixture.book storyInteractionQuestionsCompletedForPageIndices:NSMakeRange(5, 1)], 1, @"expect 1 questions completed on page 5");
    STAssertEquals([fixture.book storyInteractionQuestionsCompletedForPageIndices:NSMakeRange(4, 2)], 2, @"expect 2 questions completed on pages 4-5");
    STAssertFalse([fixture.book allQuestionsCompletedForPageIndices:NSMakeRange(4, 1)], @"expect not complete on page 4");
    STAssertTrue([fixture.book allQuestionsCompletedForPageIndices:NSMakeRange(5, 1)], @"expect complete on page 5");
    STAssertFalse([fixture.book allQuestionsCompletedForPageIndices:NSMakeRange(4, 2)], @"expect not complete on pages 4-5");

    [fixture.book incrementQuestionsCompletedForStoryInteraction:[fixture storyInteractionAtIndex:0] pageIndices:NSMakeRange(4, 1)];
    
    STAssertEquals([fixture.book storyInteractionQuestionsCompletedForPageIndices:NSMakeRange(4, 1)], 2, @"expect 2 questions completed on page 4");
    STAssertEquals([fixture.book storyInteractionQuestionsCompletedForPageIndices:NSMakeRange(5, 1)], 1, @"expect 1 questions completed on page 5");
    STAssertEquals([fixture.book storyInteractionQuestionsCompletedForPageIndices:NSMakeRange(4, 2)], 3, @"expect 3 questions completed on pages 4-5");
    STAssertTrue([fixture.book allQuestionsCompletedForPageIndices:NSMakeRange(4, 1)], @"expect complete on page 4");
    STAssertTrue([fixture.book allQuestionsCompletedForPageIndices:NSMakeRange(5, 1)], @"expect complete on page 5");
    STAssertTrue([fixture.book allQuestionsCompletedForPageIndices:NSMakeRange(4, 2)], @"expect complete on pages 4-5");
}

- (void)testIncrementstoryInteractionCompletedQuestionCountForStoryInteractionSplitOverTwoPages_OddPagesOnLeft
{
    fixture.oddPagesOnLeft = YES;
    [fixture storyInteractionAtIndex:0].questionCount = 3;
    [fixture storyInteractionAtIndex:0].questionCountOnLeft = 2;
    [fixture storyInteractionAtIndex:0].questionCountOnRight = 1;
    
    STAssertEquals([fixture.book storyInteractionQuestionsCompletedForPageIndices:NSMakeRange(3, 1)], 0, @"expect 0 questions completed on page 3");
    STAssertEquals([fixture.book storyInteractionQuestionsCompletedForPageIndices:NSMakeRange(4, 1)], 0, @"expect 0 questions completed on page 4");
    STAssertEquals([fixture.book storyInteractionQuestionsCompletedForPageIndices:NSMakeRange(3, 2)], 0, @"expect 0 questions completed on pages 3-4");
    STAssertFalse([fixture.book allQuestionsCompletedForPageIndices:NSMakeRange(3, 1)], @"expect not complete on page 3");
    STAssertFalse([fixture.book allQuestionsCompletedForPageIndices:NSMakeRange(4, 1)], @"expect not complete on page 4");
    STAssertFalse([fixture.book allQuestionsCompletedForPageIndices:NSMakeRange(3, 2)], @"expect not complete on pages 3-4");
    
    [fixture.book incrementQuestionsCompletedForStoryInteraction:[fixture storyInteractionAtIndex:0] pageIndices:NSMakeRange(3, 1)];
    
    STAssertEquals([fixture.book storyInteractionQuestionsCompletedForPageIndices:NSMakeRange(3, 1)], 1, @"expect 1 questions completed on page 3");
    STAssertEquals([fixture.book storyInteractionQuestionsCompletedForPageIndices:NSMakeRange(4, 1)], 0, @"expect 0 questions completed on page 4");
    STAssertEquals([fixture.book storyInteractionQuestionsCompletedForPageIndices:NSMakeRange(3, 2)], 1, @"expect 1 questions completed on pages 3-4");
    STAssertFalse([fixture.book allQuestionsCompletedForPageIndices:NSMakeRange(3, 1)], @"expect not complete on page 3");
    STAssertFalse([fixture.book allQuestionsCompletedForPageIndices:NSMakeRange(4, 1)], @"expect not complete on page 4");
    STAssertFalse([fixture.book allQuestionsCompletedForPageIndices:NSMakeRange(3, 2)], @"expect not complete on pages 3-4");
    
    [fixture.book incrementQuestionsCompletedForStoryInteraction:[fixture storyInteractionAtIndex:0] pageIndices:NSMakeRange(4, 1)];
    
    STAssertEquals([fixture.book storyInteractionQuestionsCompletedForPageIndices:NSMakeRange(3, 1)], 1, @"expect 1 questions completed on page 3");
    STAssertEquals([fixture.book storyInteractionQuestionsCompletedForPageIndices:NSMakeRange(4, 1)], 1, @"expect 1 questions completed on page 4");
    STAssertEquals([fixture.book storyInteractionQuestionsCompletedForPageIndices:NSMakeRange(3, 2)], 2, @"expect 2 questions completed on pages 3-4");
    STAssertFalse([fixture.book allQuestionsCompletedForPageIndices:NSMakeRange(3, 1)], @"expect not complete on page 4");
    STAssertTrue([fixture.book allQuestionsCompletedForPageIndices:NSMakeRange(4, 1)], @"expect complete on page 5");
    STAssertFalse([fixture.book allQuestionsCompletedForPageIndices:NSMakeRange(3, 2)], @"expect not complete on pages 4-5");
    
    [fixture.book incrementQuestionsCompletedForStoryInteraction:[fixture storyInteractionAtIndex:0] pageIndices:NSMakeRange(3, 1)];
    
    STAssertEquals([fixture.book storyInteractionQuestionsCompletedForPageIndices:NSMakeRange(3, 1)], 2, @"expect 2 questions completed on page 3");
    STAssertEquals([fixture.book storyInteractionQuestionsCompletedForPageIndices:NSMakeRange(4, 1)], 1, @"expect 1 questions completed on page 4");
    STAssertEquals([fixture.book storyInteractionQuestionsCompletedForPageIndices:NSMakeRange(3, 2)], 3, @"expect 3 questions completed on pages 3-4");
    STAssertTrue([fixture.book allQuestionsCompletedForPageIndices:NSMakeRange(3, 1)], @"expect complete on page 3");
    STAssertTrue([fixture.book allQuestionsCompletedForPageIndices:NSMakeRange(4, 1)], @"expect complete on page 4");
    STAssertTrue([fixture.book allQuestionsCompletedForPageIndices:NSMakeRange(3, 2)], @"expect complete on pages 3-4");
}

@end
