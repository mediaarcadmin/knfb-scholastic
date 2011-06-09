//
//  SCHStoryInteractionControllerTitleTwister.m
//  Scholastic
//
//  Created by Neil Gall on 09/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionControllerTitleTwister.h"


@implementation SCHStoryInteractionControllerTitleTwister

@synthesize openingScreenTitleLabel;
@synthesize answerBuildTarget;
@synthesize answerHeadingCounts;
@synthesize answerTables;

- (void)dealloc
{
    [openingScreenTitleLabel release];
    [answerBuildTarget release];
    [answerHeadingCounts release];
    [answerTables release];
    [super dealloc];
}

- (void)setupViewAtIndex:(NSInteger)screenIndex
{
    
}

#pragma mark - Actions

- (void)goButtonTapped:(id)sender
{
    [self presentNextView];
}

- (void)doneButtonTapped:(id)sender
{
    
}

- (void)clearButtonTapped:(id)sender
{
    
}


#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

@end
