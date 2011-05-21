//
//  SCHReadingNoteView.m
//  Scholastic
//
//  Created by Gordon Christie on 19/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//
//  Ported from Blio - BlioNotesView

#import "SCHReadingNoteView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+BlioAdditions.h"
#import "SCHNote.h"
#import "SCHBookAnnotations.h"

static const CGFloat kSCHNotesViewPhoneShadow = 16;
static const CGFloat kSCHNotesViewPadBorder = 6;
static const CGFloat kSCHNotesViewNoteHeight = 200;
static const CGFloat kSCHNotesViewNotePadWidth = 320;
static const CGFloat kSCHNotesViewNotePadBottomInset = 264;

static const CGFloat kSCHNotesViewNotePhoneYInset = -40;
static const CGFloat kSCHNotesViewNotePadYInset = -20;
static const CGFloat kSCHNotesViewToolbarHeight = 44;
static const CGFloat kSCHNotesViewToolbarLabelWidth = 140;
static const CGFloat kSCHNotesViewTextXInset = 8;
static const CGFloat kSCHNotesViewTextTopInset = 8;
static const CGFloat kSCHNotesViewTextBottomInset = 24;

static NSString * const SCHNotesViewShowFromTopAnimation = @"SCHNotesViewShowFromTopAnimation";
static NSString * const SCHNotesViewExitToTopAnimation = @"SCHNotesViewExitToTopAnimation";

#pragma mark - Class Extension

@interface SCHReadingNoteView()

@property (nonatomic, assign) UIView *showInView;
@property CGFloat bottomInset;

@end

#pragma mark -

@implementation SCHReadingNoteView

@synthesize delegate;
@synthesize textView;
@synthesize toolbarLabel;
@synthesize note;
@synthesize showInView;
@synthesize bottomInset;

- (void)dealloc {
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    
    [note release], note = nil;
    [textView release], textView = nil;
    [toolbarLabel release], toolbarLabel = nil;
    showInView = nil;
    delegate = nil;
    
    [super dealloc];
}

- (id)initWithNote:(SCHNote *)aNote {
    
    if ((self = [super initWithFrame:CGRectZero])) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];

        // Setting this forces layoutSubviews to be called on a rotation
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.autoresizesSubviews = YES;
        
        // Ensures that the note shows above it's sibling views
        self.layer.zPosition = 1000;
        
        self.bottomInset = kSCHNotesViewNotePadBottomInset;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
        }
        
        self.note = aNote;
        
    }
    return self;
}

- (void)showInView:(UIView *)view {
    [self showInView:view animated:YES];
}

- (void)layoutNote {
    CGRect newFrame;
    CGRect toolbarFrame;
    UIView *container = self.showInView;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        newFrame = CGRectMake(0, 
                              (container.bounds.size.height - (2 * kSCHNotesViewPhoneShadow + kSCHNotesViewNoteHeight))/2.0f + kSCHNotesViewNotePhoneYInset,
                              container.bounds.size.width,
                              2 * kSCHNotesViewPhoneShadow + kSCHNotesViewNoteHeight);
        toolbarFrame = CGRectMake((newFrame.size.width - kSCHNotesViewToolbarLabelWidth)/2.0f, kSCHNotesViewPhoneShadow, kSCHNotesViewToolbarLabelWidth, kSCHNotesViewToolbarHeight);
        
    } else {
        newFrame = CGRectMake((container.bounds.size.width - kSCHNotesViewNotePadWidth) / 2, 
                              container.bounds.size.height - (self.bottomInset + kSCHNotesViewNoteHeight) - kSCHNotesViewNotePadYInset,
                              kSCHNotesViewNotePadWidth,
                              kSCHNotesViewNoteHeight);
        toolbarFrame = CGRectMake((newFrame.size.width - kSCHNotesViewToolbarLabelWidth)/2.0f, kSCHNotesViewPadBorder, kSCHNotesViewToolbarLabelWidth, kSCHNotesViewToolbarHeight);
    }
    
    self.frame = newFrame;
    
    self.toolbarLabel.frame = toolbarFrame;
    //[self setNeedsDisplay];
}

- (void)showInView:(UIView *)view animated:(BOOL)animated {

    [self removeFromSuperview];
    self.showInView = view;
    
    // Insert below the view so that it gets the rotation resizing
    // The layer zPosition will take care of showing it above it's sibling
    [[self.showInView superview] insertSubview:self belowSubview:self.showInView];
    [self.showInView setUserInteractionEnabled:NO];
    
    UILabel *aToolbarLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self addSubview:aToolbarLabel];
    self.toolbarLabel = aToolbarLabel;
    [aToolbarLabel release];
    
    [self layoutNote];
    
    CGFloat inset;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        inset = kSCHNotesViewPhoneShadow;
    } else {
        inset = kSCHNotesViewPadBorder;
    }
    
    UIFont *buttonFont = [UIFont boldSystemFontOfSize:12.0f];
	NSString *buttonText = NSLocalizedString(@"Cancel",@"\"Cancel\" button label for Notes View"); 
    UIImage *buttonImage = [UIImage imageWithString:buttonText font:buttonFont color:[UIColor whiteColor]];
    
    UISegmentedControl *aButtonSegment = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:buttonImage]];
    aButtonSegment.segmentedControlStyle = UISegmentedControlStyleBar;
    aButtonSegment.frame = CGRectMake(inset + kSCHNotesViewTextXInset, inset + ((kSCHNotesViewToolbarHeight - aButtonSegment.frame.size.height)/2.0f), aButtonSegment.frame.size.width + 4, aButtonSegment.frame.size.height);

    aButtonSegment.tintColor = [UIColor colorWithRed:0.106 green:0.584 blue:0.871 alpha:1.0f];
    [[aButtonSegment imageForSegmentAtIndex:0] setAccessibilityLabel:NSLocalizedString(@"Cancel", @"Accessibility label for Notes View Cancel button")];
    
    [aButtonSegment addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventValueChanged];
    [aButtonSegment setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
    [self addSubview:aButtonSegment];
    [aButtonSegment release];
    
	buttonText = NSLocalizedString(@"Save",@"\"Save\" button label for Notes View");
    buttonImage = [UIImage imageWithString:buttonText font:buttonFont color:[UIColor whiteColor]];
    
    aButtonSegment = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:buttonImage]];
    aButtonSegment.segmentedControlStyle = UISegmentedControlStyleBar;
    aButtonSegment.frame = CGRectMake(self.frame.size.width - inset - kSCHNotesViewTextXInset - aButtonSegment.frame.size.width - 8, inset + ((kSCHNotesViewToolbarHeight - aButtonSegment.frame.size.height)/2.0f), aButtonSegment.frame.size.width + 8, aButtonSegment.frame.size.height);

    aButtonSegment.tintColor = [UIColor colorWithRed:0.106 green:0.584 blue:0.871 alpha:1.0f];
    [[aButtonSegment imageForSegmentAtIndex:0] setAccessibilityLabel:NSLocalizedString(@"Save", @"Accessibility label for Notes View Save button")];
    
    [aButtonSegment addTarget:self action:@selector(save:) forControlEvents:UIControlEventValueChanged];
    [aButtonSegment setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
    [self addSubview:aButtonSegment];
    [aButtonSegment release];
    
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateStyle:NSDateFormatterShortStyle];
    NSString *dateString = [dateFormat stringFromDate:date];  
    [dateFormat release];
    
    NSNumber *pageNum = [self.note NotePageNumber];

    if (nil != pageNum) {
		self.toolbarLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Page %d, %@", @"Page and date toolbar label for Notes View"), [pageNum intValue], dateString];
    } else {
    // FIXME: change this to use the actual page
        self.toolbarLabel.text = [NSString stringWithFormat:@"%@", dateString];
    }
    
    self.toolbarLabel.adjustsFontSizeToFitWidth = YES;
    //self.toolbarLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    self.toolbarLabel.font = [UIFont fontWithName:@"Marker Felt" size:18.0f];
    self.toolbarLabel.backgroundColor = [UIColor clearColor];
    self.toolbarLabel.textAlignment = UITextAlignmentCenter;
    
    UITextView *aTextView = [[UITextView alloc] initWithFrame:
                             CGRectMake(inset + kSCHNotesViewTextXInset, 
                                        inset + kSCHNotesViewToolbarHeight + kSCHNotesViewTextTopInset, 
                                        self.frame.size.width - 2*(inset + kSCHNotesViewTextXInset), 
                                        self.frame.size.height - 2*inset - kSCHNotesViewTextTopInset - kSCHNotesViewTextBottomInset - kSCHNotesViewToolbarHeight)];
    //aTextView.font = [UIFont boldSystemFontOfSize:14.0f];
    aTextView.font = [UIFont fontWithName:@"Marker Felt" size:18.0f];
    aTextView.backgroundColor = [UIColor clearColor];
    aTextView.keyboardAppearance = UIKeyboardAppearanceAlert;
    aTextView.text = [self.note NoteText];
    [aTextView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [self addSubview:aTextView];
    self.textView = aTextView;
    [aTextView release];    
    
    if (animated) {
        CGFloat yOffscreen = -CGRectGetMaxY(self.frame);
        self.transform = CGAffineTransformMakeTranslation(0, yOffscreen);
        [UIView beginAnimations:SCHNotesViewShowFromTopAnimation context:nil];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationWillStartSelector:@selector(animationWillStart:context:)];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView setAnimationDuration:0.35f];
        self.transform = CGAffineTransformIdentity;
        [UIView commitAnimations];
    } else {
        [self.textView becomeFirstResponder];
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.layer.shadowOpacity = 0.3f;
        self.layer.shadowRadius = 20.0f;
        self.layer.shadowOffset = CGSizeZero;
    }
    
}

- (void)keyboardDidShow:(NSNotification *)notification {
    NSDictionary* info = [notification userInfo];
    
    CGRect keyboardRect = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    keyboardRect = [[self superview] convertRect:keyboardRect fromView:nil];
    
    self.bottomInset = keyboardRect.size.height;
    
    [UIView beginAnimations:@"keyboardAdjust" context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.35f];
    [self layoutNote];
    [UIView commitAnimations];
}

- (void)layoutSubviews {
    [self layoutNote];
}

void drawGlossGradient(CGContextRef c, CGRect rect) {
    CGGradientRef glossGradient;
    CGColorSpaceRef rgbColorspace;
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat components[8] = { 1.0, 1.0, 1.0, 0.380,  // Start color
        1.0, 1.0, 1.0, 0.188 }; // End color
    
    rgbColorspace = CGColorSpaceCreateDeviceRGB();
    glossGradient = CGGradientCreateWithColorComponents(rgbColorspace, components, locations, num_locations);
    
    CGPoint topCenter = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPoint bottomCenter = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
    CGContextDrawLinearGradient(c, glossGradient, topCenter, bottomCenter, 0);    
    CGGradientRelease(glossGradient);
    CGColorSpaceRelease(rgbColorspace);
}

void addRoundedRectToPath(CGContextRef c, CGFloat radius, CGRect rect) {
    CGContextSaveGState(c);
    
    if (radius > rect.size.width/2.0)
        radius = rect.size.width/2.0;
    if (radius > rect.size.height/2.0)
        radius = rect.size.height/2.0;    
    
    CGFloat minx = CGRectGetMinX(rect);
    CGFloat midx = CGRectGetMidX(rect);
    CGFloat maxx = CGRectGetMaxX(rect);
    CGFloat miny = CGRectGetMinY(rect);
    CGFloat midy = CGRectGetMidY(rect);
    CGFloat maxy = CGRectGetMaxY(rect);
    CGContextMoveToPoint(c, minx, midy);
    CGContextAddArcToPoint(c, minx, miny, midx, miny, radius);
    CGContextAddArcToPoint(c, maxx, miny, maxx, midy, radius);
    CGContextAddArcToPoint(c, maxx, maxy, midx, maxy, radius);
    CGContextAddArcToPoint(c, minx, maxy, minx, midy, radius);
    
    CGContextClosePath(c); 
    CGContextRestoreGState(c); 
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGFloat inset;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        inset = kSCHNotesViewPhoneShadow;
        CGContextSetShadowWithColor(ctx, CGSizeZero, kSCHNotesViewPhoneShadow, [UIColor colorWithWhite:0.3f alpha:0.8f].CGColor);
    } else {
        inset = kSCHNotesViewPadBorder;
    }
    
    CGRect inRect = CGRectInset(rect, inset, inset);
    CGContextBeginTransparencyLayer(ctx, NULL);
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        CGContextBeginPath(ctx);
        addRoundedRectToPath(ctx, 7.0f, rect);
        CGContextClip(ctx); 
        CGContextSetRGBFillColor(ctx, 0.141f, 0.224f, 0.443f, 0.95f);
        CGContextFillRect(ctx, rect);
        CGRect glossRect = rect;
        glossRect.size.height = 26.0f;
        drawGlossGradient(ctx, glossRect);
    }
    
    CGFloat components[8] = { 0.561f, 0.804f, 0.953f, 1.0f,  // Start color
        0.486f, 0.773f, 0.945f, 1.0f }; // End color
    
    CGColorSpaceRef myColorspace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef myGradient = CGGradientCreateWithColorComponents (myColorspace, components, NULL, 2);
    CGColorSpaceRelease(myColorspace);
    
    CGContextSaveGState(ctx);
    CGContextClipToRect(ctx, inRect);
    CGContextDrawLinearGradient (ctx, myGradient, CGPointMake(CGRectGetMinX(inRect), CGRectGetMinY(inRect)), CGPointMake(CGRectGetMinX(inRect), CGRectGetMaxY(inRect)), 0);
    CGGradientRelease(myGradient);
    
    CGContextSetRGBFillColor(ctx, 1.0f, 1.0f, 1.0f, 0.7f);
    
    CGContextSetShadow(ctx, CGSizeMake(0,1), 0);
    CGContextFillRect(ctx, CGRectMake(inRect.origin.x + kSCHNotesViewTextXInset, inRect.origin.y + kSCHNotesViewToolbarHeight + 1, inRect.size.width - 2 * kSCHNotesViewTextXInset, 1));
    
    CGContextRestoreGState(ctx);
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {        
        CGContextBeginPath(ctx);
        addRoundedRectToPath(ctx, 7.0f, rect);
        CGContextSetLineWidth(ctx, 2.0f);
        CGContextSetRGBStrokeColor(ctx, 0.491f, 0.486f, 0.342f, 1.0f);
        CGContextSetShadowWithColor(ctx, CGSizeMake(0, 1), 0, [UIColor colorWithWhite:1 alpha:0.3f].CGColor);
        CGContextStrokePath(ctx);
        
    }
    
    CGContextEndTransparencyLayer(ctx);
}

- (void)dismiss:(id)sender {
    [self.textView resignFirstResponder];
    CGFloat yOffscreen = -CGRectGetMaxY(self.frame);
    
    [UIView beginAnimations:SCHNotesViewExitToTopAnimation context:self];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDuration:0.35f];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    self.transform = CGAffineTransformMakeTranslation(0, yOffscreen);
    [UIView commitAnimations];
    
    [self.showInView setUserInteractionEnabled:YES];
	
}

- (void)save:(id)sender {
    self.note.NoteText = self.textView.text;
    
    if ([self.delegate respondsToSelector:@selector(notesView:savedNote:)]) {
        [self.delegate notesView:self savedNote:self.note];
    }
    
    [self dismiss:sender];
}

- (void)cancel:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(notesViewCancelled:)]) {
        [self.delegate performSelector:@selector(notesViewCancelled:) withObject:self];
    }
    
    [self dismiss:sender];
}

- (void)animationWillStart:(NSString *)animationID context:(void *)context {
    if ([animationID isEqualToString:SCHNotesViewShowFromTopAnimation]) {
        [self.textView becomeFirstResponder];
    }
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    if ([animationID isEqualToString:SCHNotesViewExitToTopAnimation]) {
        [(UIView *)context removeFromSuperview];
    }
}                                                  

@end
