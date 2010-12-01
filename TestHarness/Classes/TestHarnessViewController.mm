

#import "TestHarnessViewController.h"
#include <sys/time.h>
#import <QuartzCore/QuartzCore.h>

typedef enum {
    TestHarnessResourceTypeUnknown = 0,
    TestHarnessResourceTypePDF,
    TestHarnessResourceTypeXPS,
} TestHarnessResourceType;

@interface TestRenderingView : UIView {
    TestHarnessViewController *viewController;
    CGDataProviderRef dataProvider;
    TestHarnessResourceType resourceType;
    RasterImageInfo *imageInfo;
    XPS_HANDLE xpsHandle;
}

@property(nonatomic, retain) TestHarnessViewController *viewController;
@property(nonatomic) CGDataProviderRef dataProvider;
@property(nonatomic) TestHarnessResourceType resourceType;
@property(nonatomic) XPS_HANDLE xpsHandle;

@end


@implementation TestHarnessViewController

@synthesize resourcePath, tmpPath, currentPage, testView;

- (void)dealloc {
    self.resourcePath = nil;
    NSError *error;
    if (nil != self.tmpPath) {
    if (![[NSFileManager defaultManager] removeItemAtPath:self.tmpPath error:&error])
        NSLog(@"Could not delete directory %@", self.tmpPath);
        self.tmpPath = nil;
    }
    
    self.testView = nil;
              
    [super dealloc];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.testView;
}

- (void)loadView {
    UIScrollView *aScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,0,320,480)];
    aScrollView.minimumZoomScale = 1;
    aScrollView.maximumZoomScale = 20;
    aScrollView.delegate = self;
    
    TestRenderingView *aTestView = [[TestRenderingView alloc] initWithFrame:CGRectMake(0,0,320,480)];
    aTestView.viewController = self;
    [(CATiledLayer *)aTestView.layer setLevelsOfDetail:5];
    [(CATiledLayer *)aTestView.layer setLevelsOfDetailBias:4];
    [(CATiledLayer *)aTestView.layer setTileSize:CGSizeMake(256, 256)];
    aTestView.layer.geometryFlipped = YES;
    [aScrollView addSubview:aTestView];
    self.testView = aTestView;
    self.view = aScrollView;
    [aTestView release];
    [aScrollView release];
    
    struct timeval start, end;
    long mtime, seconds, useconds;
    gettimeofday(&start, NULL);
    
    fprintf(stderr, "Begin rendering '%s'\n", [[resourcePath lastPathComponent] UTF8String]);
    
    NSString *extension = [[resourcePath pathExtension] uppercaseString];
    TestHarnessResourceType resourceType = TestHarnessResourceTypeUnknown;
    
    if ([extension isEqualToString:@"XPS"]) {
        resourceType = TestHarnessResourceTypeXPS;
    } else if ([extension isEqualToString:@"PDF"]) {
        resourceType = TestHarnessResourceTypePDF;
    }
    
    testView.resourceType = resourceType;
    
    switch (resourceType) {
        case TestHarnessResourceTypePDF: {
            NSString *fileString = resourcePath;
            CFURLRef aPdfUrl = CFURLCreateWithFileSystemPath (
                                                              NULL,
                                                              (CFStringRef)fileString,
                                                              kCFURLPOSIXPathStyle,
                                                              false
                                                              );
            
            testView.dataProvider = CGDataProviderCreateWithURL(aPdfUrl);
            
            CGPDFDocumentRef aPDFDoc = CGPDFDocumentCreateWithProvider(testView.dataProvider);
            maxPages = CGPDFDocumentGetNumberOfPages(aPDFDoc);
            CGPDFDocumentRelease(aPDFDoc);
            
            CFRelease(fileString);
            CFRelease(aPdfUrl);
            
            gettimeofday(&end, NULL);
            seconds  = end.tv_sec  - start.tv_sec;
            useconds = end.tv_usec - start.tv_usec;
            mtime = ((seconds) * 1000 + useconds/1000.0) + 0.5;
            fprintf(stderr, "PDF: %ld ms to open document for first time\n", mtime);
            
            currentPage = 1;
        } break;
        case TestHarnessResourceTypeXPS: {
            NSArray  *paths  = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            CFUUIDRef theUUID = CFUUIDCreate(NULL);
            CFStringRef UUIDString = CFUUIDCreateString(NULL, theUUID);            
            self.tmpPath = [NSString stringWithFormat:@"%@/tmp/%@", [paths objectAtIndex:0], (NSString *)UUIDString];
            CFRelease(theUUID);
            CFRelease(UUIDString);
            const char *f = [resourcePath UTF8String];
            const char *d = [tmpPath cStringUsingEncoding:NSASCIIStringEncoding];
            NSError *error;
            
            if (![[NSFileManager defaultManager] fileExistsAtPath:tmpPath]) {
                if (![[NSFileManager defaultManager] createDirectoryAtPath:tmpPath withIntermediateDirectories:YES attributes:nil error:&error]) {
                    NSLog(@"Unable to create directory at path %@ with error %@ %@", tmpPath, error, [error userInfo]);
                } else {
                    NSLog(@"Directory created at path %@", tmpPath);
                }
            } else {
                NSLog(@"Directory exists at path %@", tmpPath);
            }

            XPS_Start();
            testView.xpsHandle = XPS_Open(f, d);
            XPS_SetAntiAliasMode(testView.xpsHandle,XPS_ANTIALIAS_ON);
            maxPages   = XPS_GetNumberPages(testView.xpsHandle, 0);
            
            gettimeofday(&end, NULL);
            seconds  = end.tv_sec  - start.tv_sec;
            useconds = end.tv_usec - start.tv_usec;
            mtime = ((seconds) * 1000 + useconds/1000.0) + 0.5;
            fprintf(stderr, "XPS: %ld ms to open document for first time\n", mtime);
            
            currentPage = 1;
            
        } break;
        default:
            NSLog(@"Incompatible resource type found");
            break;
    }
    
    [self.navigationItem setTitle:[NSString stringWithFormat:@"Page %d", currentPage]];
    UIBarButtonItem *advance = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(next:)];

    [self.navigationItem setRightBarButtonItem:advance];
    [advance release];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {  
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [super viewWillAppear:animated];  
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController.navigationBar setTranslucent:NO];
    [super viewWillDisappear:animated];  
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.view = nil;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.navigationController.navigationBar setTranslucent:YES];
    [self.navigationController setNavigationBarHidden:![self.navigationController isNavigationBarHidden] animated:YES];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    NSLog(@"DID RECEIVE MEMORY WARNING");
}

- (void)next:(id)sender {
    currentPage++;
    if (currentPage <= maxPages) {
        self.testView.layer.contents = nil;
        [self.testView.layer setNeedsDisplay];
        [self.navigationItem setTitle:[NSString stringWithFormat:@"Page %d", currentPage]];

    } else {
        fprintf(stderr, "Finished rendering '%s'\n", [[resourcePath lastPathComponent] UTF8String]);
    }
}


@end

@implementation TestRenderingView

@synthesize viewController, dataProvider, resourceType, xpsHandle;

+ (Class)layerClass {
    return [CATiledLayer class];
}

- (void)dealloc {
    self.viewController = nil;
    if (dataProvider) CGDataProviderRelease(dataProvider);
    if (xpsHandle) {
        XPS_Close(xpsHandle);
        XPS_End();
    }
    [super dealloc];
}

- (void)drawPDFPage:(NSInteger)aPageNumber inContext:(CGContextRef)ctx rect:(CGRect)rect {

    CGContextSetRGBFillColor(ctx, 1, 1, 1, 1);
    CGContextFillRect(ctx,rect);
    
    CGContextTranslateCTM(ctx, 0, rect.size.height);
    CGContextScaleCTM(ctx, 1, -1);
    struct timeval start, end;
    long mtime, seconds, useconds;
    gettimeofday(&start, NULL);
    
    CGPDFDocumentRef aPDFDoc = CGPDFDocumentCreateWithProvider(dataProvider);
    CGPDFPageRef aPDFPage = CGPDFDocumentGetPage(aPDFDoc, aPageNumber);
    
    CGAffineTransform pdfFitTransform = CGPDFPageGetDrawingTransform(aPDFPage, kCGPDFCropBox, rect, 0, true);
    CGContextConcatCTM(ctx, pdfFitTransform);
    CGContextClipToRect(ctx, CGPDFPageGetBoxRect(aPDFPage, kCGPDFCropBox));
    CGContextDrawPDFPage(ctx, aPDFPage);
    CGPDFDocumentRelease(aPDFDoc);
    gettimeofday(&end, NULL);
    seconds  = end.tv_sec  - start.tv_sec;
    useconds = end.tv_usec - start.tv_usec;
    mtime = ((seconds) * 1000 + useconds/1000.0) + 0.5;
    fprintf(stderr, "PDF: %ld ms to render page %d\n", mtime, aPageNumber);
    
    // Revert the context transform
    CGContextConcatCTM(ctx, CGAffineTransformInvert(CGContextGetCTM(ctx)));

}

void RenderCallback1(void *userdata, RasterImageInfo *data);

void RenderCallback1(void *userdata, RasterImageInfo *data) {
	TestRenderingView *view = (TestRenderingView *)userdata;	
	view->imageInfo = data;
}

static void dataReleaseCallback(void *info, const void *data, size_t size) {
	XPS_ReleaseImageMemory((void *)data);
}

- (void)drawXPSPage:(NSInteger)page inContext:(CGContextRef)ctx inRect:(CGRect)rect withTransform:(CGAffineTransform)transform {
    //fprintf(stderr, "\n");
#if TARGET_IPHONE_SIMULATOR
    @synchronized(self) {
#endif
        
        NSLog(@"Draw XPSPage %d", page);
    CGAffineTransform ctm = CGContextGetCTM(ctx);

    NSLog(@"ctm %@", NSStringFromCGAffineTransform(ctm));
    NSLog(@"rect: %@", NSStringFromCGRect(rect));
    
    
    // FOR RANDAIR
    // Stage 1. Retrieve the page size
    FixedPageProperties properties;
    memset(&properties,0,sizeof(properties));
    XPS_GetFixedPageProperties(xpsHandle, 0, page - 1, &properties);
    CGRect pageCropRect = CGRectMake(properties.contentBox.x, properties.contentBox.y, properties.contentBox.width, properties.contentBox.height);
    NSLog(@"pageCropRect: %@", NSStringFromCGRect(pageCropRect));
    
    // FOR RANDAIR
    // Stage 2. Calculate the scale to fit this page inside a rectangle that is the 288x 448, then multiply the scale by the tile scale factor
    // This gives us the page scale, i.e. teh size we want to scale the pageCropRect calculated in 1.
    CGRect insetRect = CGRectInset(rect, 16, 16);
    CGFloat widthScale = (CGRectGetWidth(insetRect) / CGRectGetWidth(pageCropRect)) * ctm.a;
    CGFloat heightScale = (CGRectGetHeight(insetRect) / CGRectGetHeight(pageCropRect)) * ctm.d;
    CGFloat pageScale = MIN(widthScale, heightScale);
    
    
    // FOR RANDAIR
    // Stage 3. Calculate the size of the page when it is scaled, and the subsequent size once it is truncated
    CGRect scaledPage = CGRectMake(pageCropRect.origin.x, pageCropRect.origin.y, pageCropRect.size.width * pageScale, pageCropRect.size.height * pageScale);
    CGRect truncatedPage = CGRectMake(scaledPage.origin.x, scaledPage.origin.y, floorf(scaledPage.size.width), floorf(scaledPage.size.height));
    
    // FOR RANDAIR
    // Stage 4. Calculate the tile we currently want, includng it's offset
    CGRect clipRect = CGContextGetClipBoundingBox(ctx);
    CGRect tileRect = CGRectApplyAffineTransform(clipRect, ctm); 
    tileRect.origin = CGPointMake(clipRect.origin.x * ctm.a, clipRect.origin.y * ctm.d);
    NSLog(@"tileRect: %@", NSStringFromCGRect(tileRect));

    // FOR RANDAIR
    // Stage 5. Calculate the pagesizescalewidth & pagesizescaleheight to produce an image that should match the tile size
    // This is where we use the truncated page size
    CGFloat pagesizescalewidth = (CGRectGetWidth(tileRect))/ CGRectGetWidth(truncatedPage);
    CGFloat pagesizescaleheight = (CGRectGetHeight(tileRect))/ CGRectGetHeight(truncatedPage);
    
    
        
    OutputFormat format;
    memset(&format,0,sizeof(format));
    
    // FOR RANDAIR
    // Stage 6. Calculate where the top left of the tile is offset from the bottom left of the screen
    // These values are used to translate the page
    CGPoint topLeftOfTileOffsetFromBottomLeft = CGPointMake(tileRect.origin.x, CGRectGetHeight(rect)*ctm.d - CGRectGetMaxY(tileRect));
    NSLog(@"topLeftOfTile %@", NSStringFromCGPoint(topLeftOfTileOffsetFromBottomLeft));

    XPS_ctm render_ctm = { pageScale, 0, 0, pageScale, -topLeftOfTileOffsetFromBottomLeft.x, -topLeftOfTileOffsetFromBottomLeft.y };
    NSLog(@"render_ctm { %f, %f, %f, %f, %f, %f }", render_ctm.a, render_ctm.b, render_ctm.c, render_ctm.d, render_ctm.tx, render_ctm.ty);
    format.xResolution = 96;			
    format.yResolution = 96;	
    format.colorDepth = 8;
    format.colorSpace = XPS_COLORSPACE_RGB;
    format.pagesizescale = pageScale;	
    format.pagesizescalewidth = pagesizescalewidth;		
    format.pagesizescaleheight = pagesizescaleheight;
  
    format.ctm = &render_ctm;				
    format.formatType = OutputFormat_RAW;
    imageInfo = NULL;
    
    XPS_RegisterPageCompleteCallback(xpsHandle, RenderCallback1);
    XPS_SetUserData(xpsHandle, self);
    
    XPS_Convert(xpsHandle, NULL, 0, page - 1, 1, &format);
    
    if (imageInfo) {
        size_t width  = imageInfo->widthInPixels;
        size_t height = imageInfo->height;
        size_t dataLength = width * height * 3;
        
        CGDataProviderRef providerRef = CGDataProviderCreateWithData(self, imageInfo->pBits, dataLength, dataReleaseCallback);
        CGImageRef imageRef =
        CGImageCreate(width, height, 8, 24, width * 3, CGColorSpaceCreateDeviceRGB(), 
                      kCGImageAlphaNone
                      , providerRef, NULL, true, 
                      kCGRenderingIntentDefault);
        
        NSLog(@"imageInfo->widthInPixels: %d", imageInfo->widthInPixels);
        NSLog(@"imageInfo->height: %d", imageInfo->height);
        
        // FOR RANDAIR
        // Stage 7. Remove the transform and interpolation currently applied to the context so we guarantee we get 1:1 pixel calculation when we draw the image
        CGContextConcatCTM(ctx, CGAffineTransformInvert(ctm));
        CGContextSetInterpolationQuality(ctx, kCGInterpolationNone);
                
        // FOR RANDAIR
        // Stage 8. If the image is taller than the tile then offset the image by the difference in height
        // We want the top left of the image to be drawn at the top left of the tile but the origin is at the bottom left
        CGRect imageRect = CGRectMake(0, tileRect.size.height - height, width, height);
        NSLog(@"imageRect: %@", NSStringFromCGRect(imageRect));


        CGContextDrawImage(ctx, imageRect, imageRef);
        
        CGDataProviderRelease(providerRef);
        CGImageRelease(imageRef);        

    }
        
#if TARGET_IPHONE_SIMULATOR
    }
#endif
    
}

static CGAffineTransform transformRectToFitRectWidth(CGRect sourceRect, CGRect targetRect) {
    CGFloat scale = targetRect.size.width / sourceRect.size.width;
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(scale, scale);
    CGRect scaledRect = CGRectApplyAffineTransform(sourceRect, scaleTransform);
    CGFloat xOffset = (targetRect.size.width - scaledRect.size.width);
    CGFloat yOffset = (targetRect.size.height - scaledRect.size.height);
    CGAffineTransform offsetTransform = CGAffineTransformMakeTranslation((targetRect.origin.x - scaledRect.origin.x) + xOffset/2.0f, (targetRect.origin.y - scaledRect.origin.y) + yOffset/2.0f);
    CGAffineTransform transform = CGAffineTransformConcat(scaleTransform, offsetTransform);
    return transform;
}

- (void)drawRect:(CGRect)rect 
{
    // Drawing code
	CGContextRef ctx=UIGraphicsGetCurrentContext();

    fprintf(stderr, "\n");
    NSLog(@"drawTile %d inContext %@ inBounds %@ withClip %@", viewController.currentPage, NSStringFromCGAffineTransform(CGContextGetCTM(ctx)), NSStringFromCGRect(self.bounds), NSStringFromCGRect(CGContextGetClipBoundingBox(ctx)));

	
    switch (resourceType) {
        case TestHarnessResourceTypePDF:
            [self drawPDFPage:viewController.currentPage inContext:ctx rect:rect];
            break;
        case TestHarnessResourceTypeXPS: {
            
            FixedPageProperties properties;
            memset(&properties,0,sizeof(properties));
            XPS_GetFixedPageProperties(xpsHandle, 0, viewController.currentPage - 1, &properties);
            CGRect pageCropRect = CGRectMake(properties.contentBox.x, properties.contentBox.y, properties.contentBox.width, properties.contentBox.height);
            
            CGRect contentBounds = self.bounds;
            CGRect insetBounds = UIEdgeInsetsInsetRect(contentBounds, UIEdgeInsetsMake(16, 16, 16, 16));
            CGAffineTransform boundsTransform = transformRectToFitRectWidth(pageCropRect, insetBounds);
            boundsTransform.tx = roundf(boundsTransform.tx);
            boundsTransform.ty = roundf(boundsTransform.ty);
            boundsTransform.ty += 30;
            CGRect cropRect = CGRectApplyAffineTransform(pageCropRect, boundsTransform);
            cropRect.size.width = floorf(cropRect.size.width);
            cropRect.size.height = floorf(cropRect.size.height);
            
            //[self drawXPSPage:viewController.currentPage inContext:ctx inRect:cropRect withTransform:boundsTransform];
            [self drawXPSPage:viewController.currentPage inContext:ctx inRect:contentBounds withTransform:boundsTransform];

        } break;
        default:
            [[UIColor redColor] set];
            CGContextFillRect(ctx, rect);
            return;
    }
    
    //[self.viewController performSelectorOnMainThread:@selector(renderComplete) withObject:nil waitUntilDone:NO];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.viewController touchesEnded:touches withEvent:event];
}

@end

