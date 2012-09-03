#import "LibreAccessServiceSvc.h"
#import <libxml/xmlstring.h>
#if TARGET_OS_IPHONE
#import <CFNetwork/CFNetwork.h>
#endif
@implementation LibreAccessServiceSvc
+ (void)initialize
{
	[[USGlobals sharedInstance].wsdlStandardNamespaces setObject:@"xsd" forKey:@"http://www.w3.org/2001/XMLSchema"];
	[[USGlobals sharedInstance].wsdlStandardNamespaces setObject:@"LibreAccessServiceSvc" forKey:@"http://webservices.libredigital.com/LibreAccess/v1.2.0"];
	[[USGlobals sharedInstance].wsdlStandardNamespaces setObject:@"tns1" forKey:@"http://webservices.libredigital.com/LibreAccess/schema/types/v1.2.0"];
}
+ (LibreAccessService_1_2_0Soap11Binding *)LibreAccessService_1_2_0Soap11Binding
{
	return [[[LibreAccessService_1_2_0Soap11Binding alloc] initWithAddress:@"http://laesb.dev.cld.libredigital.com/services/LibreAccessService_1_2_0.LibreAccessService_1_2_0HttpSoap11Endpoint"] autorelease];
}
@end
@implementation LibreAccessService_1_2_0Soap11Binding
@synthesize address;
@synthesize timeout;
@synthesize logXMLInOut;
@synthesize cookies;
@synthesize customHeaders;
@synthesize authUsername;
@synthesize authPassword;
@synthesize operationPointers;
+ (NSTimeInterval)defaultTimeout
{
	return 10;
}
- (id)init
{
	if((self = [super init])) {
		address = nil;
		cookies = nil;
		customHeaders = [NSMutableDictionary new];
		timeout = [[self class] defaultTimeout];
		logXMLInOut = NO;
		synchronousOperationComplete = NO;
        operationPointers = [[NSMutableArray alloc] init];
	}
	
	return self;
}
- (id)initWithAddress:(NSString *)anAddress
{
	if((self = [self init])) {
		self.address = [NSURL URLWithString:anAddress];
	}
	
	return self;
}
- (NSString *)MIMEType
{
	return @"text/xml";
}
- (void)addCookie:(NSHTTPCookie *)toAdd
{
	if(toAdd != nil) {
		if(cookies == nil) cookies = [[NSMutableArray alloc] init];
		[cookies addObject:toAdd];
	}
}
- (LibreAccessService_1_2_0Soap11BindingResponse *)performSynchronousOperation:(LibreAccessService_1_2_0Soap11BindingOperation *)operation
{
	synchronousOperationComplete = NO;
	[operation start];
	
	// Now wait for response
	NSRunLoop *theRL = [NSRunLoop currentRunLoop];
	
	while (!synchronousOperationComplete && [theRL runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]);
	return operation.response;
}
- (void)performAsynchronousOperation:(LibreAccessService_1_2_0Soap11BindingOperation *)operation
{
	[operation start];
}
- (void) operation:(LibreAccessService_1_2_0Soap11BindingOperation *)operation completedWithResponse:(LibreAccessService_1_2_0Soap11BindingResponse *)response
{
	synchronousOperationComplete = YES;
}
- (LibreAccessService_1_2_0Soap11BindingResponse *)SetLoggingLevelUsingParameters:(tns1_SetLoggingLevelRequest *)aParameters 
{
	return [self performSynchronousOperation:[[(LibreAccessService_1_2_0Soap11Binding_SetLoggingLevel*)[LibreAccessService_1_2_0Soap11Binding_SetLoggingLevel alloc] initWithBinding:self delegate:self
																							parameters:aParameters
																							] autorelease]];
}
- (void)SetLoggingLevelAsyncUsingParameters:(tns1_SetLoggingLevelRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
{
	[self performAsynchronousOperation: [[(LibreAccessService_1_2_0Soap11Binding_SetLoggingLevel*)[LibreAccessService_1_2_0Soap11Binding_SetLoggingLevel alloc] initWithBinding:self delegate:responseDelegate
																							 parameters:aParameters
																							 ] autorelease]];
}
- (LibreAccessService_1_2_0Soap11BindingResponse *)ListDefaultBooksUsingParameters:(tns1_ListDefaultBooksRequest *)aParameters 
{
	return [self performSynchronousOperation:[[(LibreAccessService_1_2_0Soap11Binding_ListDefaultBooks*)[LibreAccessService_1_2_0Soap11Binding_ListDefaultBooks alloc] initWithBinding:self delegate:self
																							parameters:aParameters
																							] autorelease]];
}
- (void)ListDefaultBooksAsyncUsingParameters:(tns1_ListDefaultBooksRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
{
	[self performAsynchronousOperation: [[(LibreAccessService_1_2_0Soap11Binding_ListDefaultBooks*)[LibreAccessService_1_2_0Soap11Binding_ListDefaultBooks alloc] initWithBinding:self delegate:responseDelegate
																							 parameters:aParameters
																							 ] autorelease]];
}
- (LibreAccessService_1_2_0Soap11BindingResponse *)AuthenticateDeviceUsingBody:(tns1_AuthenticateDeviceRequest *)aBody 
{
	return [self performSynchronousOperation:[[(LibreAccessService_1_2_0Soap11Binding_AuthenticateDevice*)[LibreAccessService_1_2_0Soap11Binding_AuthenticateDevice alloc] initWithBinding:self delegate:self
																							body:aBody
																							] autorelease]];
}
- (void)AuthenticateDeviceAsyncUsingBody:(tns1_AuthenticateDeviceRequest *)aBody  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
{
	[self performAsynchronousOperation: [[(LibreAccessService_1_2_0Soap11Binding_AuthenticateDevice*)[LibreAccessService_1_2_0Soap11Binding_AuthenticateDevice alloc] initWithBinding:self delegate:responseDelegate
																							 body:aBody
																							 ] autorelease]];
}
- (LibreAccessService_1_2_0Soap11BindingResponse *)ListReadingStatisticsDetailedUsingParameters:(tns1_ListReadingStatisticsDetailedRequest *)aParameters 
{
	return [self performSynchronousOperation:[[(LibreAccessService_1_2_0Soap11Binding_ListReadingStatisticsDetailed*)[LibreAccessService_1_2_0Soap11Binding_ListReadingStatisticsDetailed alloc] initWithBinding:self delegate:self
																							parameters:aParameters
																							] autorelease]];
}
- (void)ListReadingStatisticsDetailedAsyncUsingParameters:(tns1_ListReadingStatisticsDetailedRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
{
	[self performAsynchronousOperation: [[(LibreAccessService_1_2_0Soap11Binding_ListReadingStatisticsDetailed*)[LibreAccessService_1_2_0Soap11Binding_ListReadingStatisticsDetailed alloc] initWithBinding:self delegate:responseDelegate
																							 parameters:aParameters
																							 ] autorelease]];
}
- (LibreAccessService_1_2_0Soap11BindingResponse *)ListContentMetadataUsingBody:(tns1_ListContentMetadata *)aBody 
{
	return [self performSynchronousOperation:[[(LibreAccessService_1_2_0Soap11Binding_ListContentMetadata*)[LibreAccessService_1_2_0Soap11Binding_ListContentMetadata alloc] initWithBinding:self delegate:self
																							body:aBody
																							] autorelease]];
}
- (void)ListContentMetadataAsyncUsingBody:(tns1_ListContentMetadata *)aBody  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
{
	[self performAsynchronousOperation: [[(LibreAccessService_1_2_0Soap11Binding_ListContentMetadata*)[LibreAccessService_1_2_0Soap11Binding_ListContentMetadata alloc] initWithBinding:self delegate:responseDelegate
																							 body:aBody
																							 ] autorelease]];
}
- (LibreAccessService_1_2_0Soap11BindingResponse *)GetVersionUsingParameters:(tns1_GetVersionRequest *)aParameters 
{
	return [self performSynchronousOperation:[[(LibreAccessService_1_2_0Soap11Binding_GetVersion*)[LibreAccessService_1_2_0Soap11Binding_GetVersion alloc] initWithBinding:self delegate:self
																							parameters:aParameters
																							] autorelease]];
}
- (void)GetVersionAsyncUsingParameters:(tns1_GetVersionRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
{
	[self performAsynchronousOperation: [[(LibreAccessService_1_2_0Soap11Binding_GetVersion*)[LibreAccessService_1_2_0Soap11Binding_GetVersion alloc] initWithBinding:self delegate:responseDelegate
																							 parameters:aParameters
																							 ] autorelease]];
}
- (LibreAccessService_1_2_0Soap11BindingResponse *)AssignBooksToAllUsersUsingParameters:(tns1_AssignBooksToAllUsersRequest *)aParameters 
{
	return [self performSynchronousOperation:[[(LibreAccessService_1_2_0Soap11Binding_AssignBooksToAllUsers*)[LibreAccessService_1_2_0Soap11Binding_AssignBooksToAllUsers alloc] initWithBinding:self delegate:self
																							parameters:aParameters
																							] autorelease]];
}
- (void)AssignBooksToAllUsersAsyncUsingParameters:(tns1_AssignBooksToAllUsersRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
{
	[self performAsynchronousOperation: [[(LibreAccessService_1_2_0Soap11Binding_AssignBooksToAllUsers*)[LibreAccessService_1_2_0Soap11Binding_AssignBooksToAllUsers alloc] initWithBinding:self delegate:responseDelegate
																							 parameters:aParameters
																							 ] autorelease]];
}
- (LibreAccessService_1_2_0Soap11BindingResponse *)DeregisterAllDevicesUsingParameters:(tns1_DeregisterAllDevicesRequest *)aParameters 
{
	return [self performSynchronousOperation:[[(LibreAccessService_1_2_0Soap11Binding_DeregisterAllDevices*)[LibreAccessService_1_2_0Soap11Binding_DeregisterAllDevices alloc] initWithBinding:self delegate:self
																							parameters:aParameters
																							] autorelease]];
}
- (void)DeregisterAllDevicesAsyncUsingParameters:(tns1_DeregisterAllDevicesRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
{
	[self performAsynchronousOperation: [[(LibreAccessService_1_2_0Soap11Binding_DeregisterAllDevices*)[LibreAccessService_1_2_0Soap11Binding_DeregisterAllDevices alloc] initWithBinding:self delegate:responseDelegate
																							 parameters:aParameters
																							 ] autorelease]];
}
- (LibreAccessService_1_2_0Soap11BindingResponse *)HealthCheckUsingParameters:(tns1_HealthCheckRequest *)aParameters 
{
	return [self performSynchronousOperation:[[(LibreAccessService_1_2_0Soap11Binding_HealthCheck*)[LibreAccessService_1_2_0Soap11Binding_HealthCheck alloc] initWithBinding:self delegate:self
																							parameters:aParameters
																							] autorelease]];
}
- (void)HealthCheckAsyncUsingParameters:(tns1_HealthCheckRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
{
	[self performAsynchronousOperation: [[(LibreAccessService_1_2_0Soap11Binding_HealthCheck*)[LibreAccessService_1_2_0Soap11Binding_HealthCheck alloc] initWithBinding:self delegate:responseDelegate
																							 parameters:aParameters
																							 ] autorelease]];
}
- (LibreAccessService_1_2_0Soap11BindingResponse *)ListReadingStatisticsDailyAggregateByTitleUsingParameters:(tns1_ListReadingStatisticsDailyAggregateByTitleRequest *)aParameters 
{
	return [self performSynchronousOperation:[[(LibreAccessService_1_2_0Soap11Binding_ListReadingStatisticsDailyAggregateByTitle*)[LibreAccessService_1_2_0Soap11Binding_ListReadingStatisticsDailyAggregateByTitle alloc] initWithBinding:self delegate:self
																							parameters:aParameters
																							] autorelease]];
}
- (void)ListReadingStatisticsDailyAggregateByTitleAsyncUsingParameters:(tns1_ListReadingStatisticsDailyAggregateByTitleRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
{
	[self performAsynchronousOperation: [[(LibreAccessService_1_2_0Soap11Binding_ListReadingStatisticsDailyAggregateByTitle*)[LibreAccessService_1_2_0Soap11Binding_ListReadingStatisticsDailyAggregateByTitle alloc] initWithBinding:self delegate:responseDelegate
																							 parameters:aParameters
																							 ] autorelease]];
}
- (LibreAccessService_1_2_0Soap11BindingResponse *)GetLastPageLocationUsingParameters:(tns1_GetLastPageLocationRequest *)aParameters 
{
	return [self performSynchronousOperation:[[(LibreAccessService_1_2_0Soap11Binding_GetLastPageLocation*)[LibreAccessService_1_2_0Soap11Binding_GetLastPageLocation alloc] initWithBinding:self delegate:self
																							parameters:aParameters
																							] autorelease]];
}
- (void)GetLastPageLocationAsyncUsingParameters:(tns1_GetLastPageLocationRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
{
	[self performAsynchronousOperation: [[(LibreAccessService_1_2_0Soap11Binding_GetLastPageLocation*)[LibreAccessService_1_2_0Soap11Binding_GetLastPageLocation alloc] initWithBinding:self delegate:responseDelegate
																							 parameters:aParameters
																							 ] autorelease]];
}
- (LibreAccessService_1_2_0Soap11BindingResponse *)ValidateScreenNameUsingParameters:(tns1_ValidateScreenNameRequest *)aParameters 
{
	return [self performSynchronousOperation:[[(LibreAccessService_1_2_0Soap11Binding_ValidateScreenName*)[LibreAccessService_1_2_0Soap11Binding_ValidateScreenName alloc] initWithBinding:self delegate:self
																							parameters:aParameters
																							] autorelease]];
}
- (void)ValidateScreenNameAsyncUsingParameters:(tns1_ValidateScreenNameRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
{
	[self performAsynchronousOperation: [[(LibreAccessService_1_2_0Soap11Binding_ValidateScreenName*)[LibreAccessService_1_2_0Soap11Binding_ValidateScreenName alloc] initWithBinding:self delegate:responseDelegate
																							 parameters:aParameters
																							 ] autorelease]];
}
- (LibreAccessService_1_2_0Soap11BindingResponse *)SaveReadingStatisticsDetailedUsingParameters:(tns1_SaveReadingStatisticsDetailedRequest *)aParameters 
{
	return [self performSynchronousOperation:[[(LibreAccessService_1_2_0Soap11Binding_SaveReadingStatisticsDetailed*)[LibreAccessService_1_2_0Soap11Binding_SaveReadingStatisticsDetailed alloc] initWithBinding:self delegate:self
																							parameters:aParameters
																							] autorelease]];
}
- (void)SaveReadingStatisticsDetailedAsyncUsingParameters:(tns1_SaveReadingStatisticsDetailedRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
{
	[self performAsynchronousOperation: [[(LibreAccessService_1_2_0Soap11Binding_SaveReadingStatisticsDetailed*)[LibreAccessService_1_2_0Soap11Binding_SaveReadingStatisticsDetailed alloc] initWithBinding:self delegate:responseDelegate
																							 parameters:aParameters
																							 ] autorelease]];
}
- (LibreAccessService_1_2_0Soap11BindingResponse *)SetAccountPasswordRequiredUsingParameters:(tns1_SetAccountPasswordRequiredRequest *)aParameters 
{
	return [self performSynchronousOperation:[[(LibreAccessService_1_2_0Soap11Binding_SetAccountPasswordRequired*)[LibreAccessService_1_2_0Soap11Binding_SetAccountPasswordRequired alloc] initWithBinding:self delegate:self
																							parameters:aParameters
																							] autorelease]];
}
- (void)SetAccountPasswordRequiredAsyncUsingParameters:(tns1_SetAccountPasswordRequiredRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
{
	[self performAsynchronousOperation: [[(LibreAccessService_1_2_0Soap11Binding_SetAccountPasswordRequired*)[LibreAccessService_1_2_0Soap11Binding_SetAccountPasswordRequired alloc] initWithBinding:self delegate:responseDelegate
																							 parameters:aParameters
																							 ] autorelease]];
}
- (LibreAccessService_1_2_0Soap11BindingResponse *)ListTopRatingsUsingParameters:(tns1_ListTopRatingsRequest *)aParameters 
{
	return [self performSynchronousOperation:[[(LibreAccessService_1_2_0Soap11Binding_ListTopRatings*)[LibreAccessService_1_2_0Soap11Binding_ListTopRatings alloc] initWithBinding:self delegate:self
																							parameters:aParameters
																							] autorelease]];
}
- (void)ListTopRatingsAsyncUsingParameters:(tns1_ListTopRatingsRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
{
	[self performAsynchronousOperation: [[(LibreAccessService_1_2_0Soap11Binding_ListTopRatings*)[LibreAccessService_1_2_0Soap11Binding_ListTopRatings alloc] initWithBinding:self delegate:responseDelegate
																							 parameters:aParameters
																							 ] autorelease]];
}
- (LibreAccessService_1_2_0Soap11BindingResponse *)SaveContentProfileAssignmentUsingParameters:(tns1_SaveContentProfileAssignmentRequest *)aParameters 
{
	return [self performSynchronousOperation:[[(LibreAccessService_1_2_0Soap11Binding_SaveContentProfileAssignment*)[LibreAccessService_1_2_0Soap11Binding_SaveContentProfileAssignment alloc] initWithBinding:self delegate:self
																							parameters:aParameters
																							] autorelease]];
}
- (void)SaveContentProfileAssignmentAsyncUsingParameters:(tns1_SaveContentProfileAssignmentRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
{
	[self performAsynchronousOperation: [[(LibreAccessService_1_2_0Soap11Binding_SaveContentProfileAssignment*)[LibreAccessService_1_2_0Soap11Binding_SaveContentProfileAssignment alloc] initWithBinding:self delegate:responseDelegate
																							 parameters:aParameters
																							 ] autorelease]];
}
- (LibreAccessService_1_2_0Soap11BindingResponse *)ListReadingStatisticsAggregateByTitleUsingParameters:(tns1_ListReadingStatisticsAggregateByTitleRequest *)aParameters 
{
	return [self performSynchronousOperation:[[(LibreAccessService_1_2_0Soap11Binding_ListReadingStatisticsAggregateByTitle*)[LibreAccessService_1_2_0Soap11Binding_ListReadingStatisticsAggregateByTitle alloc] initWithBinding:self delegate:self
																							parameters:aParameters
																							] autorelease]];
}
- (void)ListReadingStatisticsAggregateByTitleAsyncUsingParameters:(tns1_ListReadingStatisticsAggregateByTitleRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
{
	[self performAsynchronousOperation: [[(LibreAccessService_1_2_0Soap11Binding_ListReadingStatisticsAggregateByTitle*)[LibreAccessService_1_2_0Soap11Binding_ListReadingStatisticsAggregateByTitle alloc] initWithBinding:self delegate:responseDelegate
																							 parameters:aParameters
																							 ] autorelease]];
}
- (LibreAccessService_1_2_0Soap11BindingResponse *)GetKeyIdUsingParameters:(tns1_GetKeyIdRequest *)aParameters 
{
	return [self performSynchronousOperation:[[(LibreAccessService_1_2_0Soap11Binding_GetKeyId*)[LibreAccessService_1_2_0Soap11Binding_GetKeyId alloc] initWithBinding:self delegate:self
																							parameters:aParameters
																							] autorelease]];
}
- (void)GetKeyIdAsyncUsingParameters:(tns1_GetKeyIdRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
{
	[self performAsynchronousOperation: [[(LibreAccessService_1_2_0Soap11Binding_GetKeyId*)[LibreAccessService_1_2_0Soap11Binding_GetKeyId alloc] initWithBinding:self delegate:responseDelegate
																							 parameters:aParameters
																							 ] autorelease]];
}
- (LibreAccessService_1_2_0Soap11BindingResponse *)ListReadingStatisticsAggregateUsingParameters:(tns1_ListReadingStatisticsAggregateRequest *)aParameters 
{
	return [self performSynchronousOperation:[[(LibreAccessService_1_2_0Soap11Binding_ListReadingStatisticsAggregate*)[LibreAccessService_1_2_0Soap11Binding_ListReadingStatisticsAggregate alloc] initWithBinding:self delegate:self
																							parameters:aParameters
																							] autorelease]];
}
- (void)ListReadingStatisticsAggregateAsyncUsingParameters:(tns1_ListReadingStatisticsAggregateRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
{
	[self performAsynchronousOperation: [[(LibreAccessService_1_2_0Soap11Binding_ListReadingStatisticsAggregate*)[LibreAccessService_1_2_0Soap11Binding_ListReadingStatisticsAggregate alloc] initWithBinding:self delegate:responseDelegate
																							 parameters:aParameters
																							 ] autorelease]];
}
- (LibreAccessService_1_2_0Soap11BindingResponse *)ListLastNWordsUsingParameters:(tns1_ListLastNWordsRequest *)aParameters 
{
	return [self performSynchronousOperation:[[(LibreAccessService_1_2_0Soap11Binding_ListLastNWords*)[LibreAccessService_1_2_0Soap11Binding_ListLastNWords alloc] initWithBinding:self delegate:self
																							parameters:aParameters
																							] autorelease]];
}
- (void)ListLastNWordsAsyncUsingParameters:(tns1_ListLastNWordsRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
{
	[self performAsynchronousOperation: [[(LibreAccessService_1_2_0Soap11Binding_ListLastNWords*)[LibreAccessService_1_2_0Soap11Binding_ListLastNWords alloc] initWithBinding:self delegate:responseDelegate
																							 parameters:aParameters
																							 ] autorelease]];
}
- (LibreAccessService_1_2_0Soap11BindingResponse *)IsEntitledToLicenseUsingParameters:(tns1_EntitledToLicenseRequest *)aParameters 
{
	return [self performSynchronousOperation:[[(LibreAccessService_1_2_0Soap11Binding_IsEntitledToLicense*)[LibreAccessService_1_2_0Soap11Binding_IsEntitledToLicense alloc] initWithBinding:self delegate:self
																							parameters:aParameters
																							] autorelease]];
}
- (void)IsEntitledToLicenseAsyncUsingParameters:(tns1_EntitledToLicenseRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
{
	[self performAsynchronousOperation: [[(LibreAccessService_1_2_0Soap11Binding_IsEntitledToLicense*)[LibreAccessService_1_2_0Soap11Binding_IsEntitledToLicense alloc] initWithBinding:self delegate:responseDelegate
																							 parameters:aParameters
																							 ] autorelease]];
}
- (LibreAccessService_1_2_0Soap11BindingResponse *)RemoveOrderUsingParameters:(tns1_RemoveOrderRequest *)aParameters 
{
	return [self performSynchronousOperation:[[(LibreAccessService_1_2_0Soap11Binding_RemoveOrder*)[LibreAccessService_1_2_0Soap11Binding_RemoveOrder alloc] initWithBinding:self delegate:self
																							parameters:aParameters
																							] autorelease]];
}
- (void)RemoveOrderAsyncUsingParameters:(tns1_RemoveOrderRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
{
	[self performAsynchronousOperation: [[(LibreAccessService_1_2_0Soap11Binding_RemoveOrder*)[LibreAccessService_1_2_0Soap11Binding_RemoveOrder alloc] initWithBinding:self delegate:responseDelegate
																							 parameters:aParameters
																							 ] autorelease]];
}
- (LibreAccessService_1_2_0Soap11BindingResponse *)ListFavoriteTypesUsingParameters:(tns1_ListFavoriteTypesRequest *)aParameters 
{
	return [self performSynchronousOperation:[[(LibreAccessService_1_2_0Soap11Binding_ListFavoriteTypes*)[LibreAccessService_1_2_0Soap11Binding_ListFavoriteTypes alloc] initWithBinding:self delegate:self
																							parameters:aParameters
																							] autorelease]];
}
- (void)ListFavoriteTypesAsyncUsingParameters:(tns1_ListFavoriteTypesRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
{
	[self performAsynchronousOperation: [[(LibreAccessService_1_2_0Soap11Binding_ListFavoriteTypes*)[LibreAccessService_1_2_0Soap11Binding_ListFavoriteTypes alloc] initWithBinding:self delegate:responseDelegate
																							 parameters:aParameters
																							 ] autorelease]];
}
- (LibreAccessService_1_2_0Soap11BindingResponse *)ListUserContentUsingBody:(tns1_ListUserContent *)aBody 
{
	return [self performSynchronousOperation:[[(LibreAccessService_1_2_0Soap11Binding_ListUserContent*)[LibreAccessService_1_2_0Soap11Binding_ListUserContent alloc] initWithBinding:self delegate:self
																							body:aBody
																							] autorelease]];
}
- (void)ListUserContentAsyncUsingBody:(tns1_ListUserContent *)aBody  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
{
	[self performAsynchronousOperation: [[(LibreAccessService_1_2_0Soap11Binding_ListUserContent*)[LibreAccessService_1_2_0Soap11Binding_ListUserContent alloc] initWithBinding:self delegate:responseDelegate
																							 body:aBody
																							 ] autorelease]];
}
- (LibreAccessService_1_2_0Soap11BindingResponse *)SaveDefaultBooksUsingParameters:(tns1_SaveDefaultBooksRequest *)aParameters 
{
	return [self performSynchronousOperation:[[(LibreAccessService_1_2_0Soap11Binding_SaveDefaultBooks*)[LibreAccessService_1_2_0Soap11Binding_SaveDefaultBooks alloc] initWithBinding:self delegate:self
																							parameters:aParameters
																							] autorelease]];
}
- (void)SaveDefaultBooksAsyncUsingParameters:(tns1_SaveDefaultBooksRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
{
	[self performAsynchronousOperation: [[(LibreAccessService_1_2_0Soap11Binding_SaveDefaultBooks*)[LibreAccessService_1_2_0Soap11Binding_SaveDefaultBooks alloc] initWithBinding:self delegate:responseDelegate
																							 parameters:aParameters
																							 ] autorelease]];
}
- (LibreAccessService_1_2_0Soap11BindingResponse *)ListLastNProfileReadBooksUsingParameters:(tns1_ListLastNProfileReadBooksRequest *)aParameters 
{
	return [self performSynchronousOperation:[[(LibreAccessService_1_2_0Soap11Binding_ListLastNProfileReadBooks*)[LibreAccessService_1_2_0Soap11Binding_ListLastNProfileReadBooks alloc] initWithBinding:self delegate:self
																							parameters:aParameters
																							] autorelease]];
}
- (void)ListLastNProfileReadBooksAsyncUsingParameters:(tns1_ListLastNProfileReadBooksRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
{
	[self performAsynchronousOperation: [[(LibreAccessService_1_2_0Soap11Binding_ListLastNProfileReadBooks*)[LibreAccessService_1_2_0Soap11Binding_ListLastNProfileReadBooks alloc] initWithBinding:self delegate:responseDelegate
																							 parameters:aParameters
																							 ] autorelease]];
}
- (LibreAccessService_1_2_0Soap11BindingResponse *)ListApplicationSettingsUsingParameters:(tns1_ListApplicationSettingsRequest *)aParameters 
{
	return [self performSynchronousOperation:[[(LibreAccessService_1_2_0Soap11Binding_ListApplicationSettings*)[LibreAccessService_1_2_0Soap11Binding_ListApplicationSettings alloc] initWithBinding:self delegate:self
																							parameters:aParameters
																							] autorelease]];
}
- (void)ListApplicationSettingsAsyncUsingParameters:(tns1_ListApplicationSettingsRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
{
	[self performAsynchronousOperation: [[(LibreAccessService_1_2_0Soap11Binding_ListApplicationSettings*)[LibreAccessService_1_2_0Soap11Binding_ListApplicationSettings alloc] initWithBinding:self delegate:responseDelegate
																							 parameters:aParameters
																							 ] autorelease]];
}
- (LibreAccessService_1_2_0Soap11BindingResponse *)SaveDeviceInfoUsingParameters:(tns1_SaveDeviceInfoRequest *)aParameters 
{
	return [self performSynchronousOperation:[[(LibreAccessService_1_2_0Soap11Binding_SaveDeviceInfo*)[LibreAccessService_1_2_0Soap11Binding_SaveDeviceInfo alloc] initWithBinding:self delegate:self
																							parameters:aParameters
																							] autorelease]];
}
- (void)SaveDeviceInfoAsyncUsingParameters:(tns1_SaveDeviceInfoRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
{
	[self performAsynchronousOperation: [[(LibreAccessService_1_2_0Soap11Binding_SaveDeviceInfo*)[LibreAccessService_1_2_0Soap11Binding_SaveDeviceInfo alloc] initWithBinding:self delegate:responseDelegate
																							 parameters:aParameters
																							 ] autorelease]];
}
- (LibreAccessService_1_2_0Soap11BindingResponse *)GetDeviceInfoUsingParameters:(tns1_GetDeviceInfoRequest *)aParameters 
{
	return [self performSynchronousOperation:[[(LibreAccessService_1_2_0Soap11Binding_GetDeviceInfo*)[LibreAccessService_1_2_0Soap11Binding_GetDeviceInfo alloc] initWithBinding:self delegate:self
																							parameters:aParameters
																							] autorelease]];
}
- (void)GetDeviceInfoAsyncUsingParameters:(tns1_GetDeviceInfoRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
{
	[self performAsynchronousOperation: [[(LibreAccessService_1_2_0Soap11Binding_GetDeviceInfo*)[LibreAccessService_1_2_0Soap11Binding_GetDeviceInfo alloc] initWithBinding:self delegate:responseDelegate
																							 parameters:aParameters
																							 ] autorelease]];
}
- (LibreAccessService_1_2_0Soap11BindingResponse *)SaveUserProfilesUsingParameters:(tns1_SaveUserProfilesRequest *)aParameters 
{
	return [self performSynchronousOperation:[[(LibreAccessService_1_2_0Soap11Binding_SaveUserProfiles*)[LibreAccessService_1_2_0Soap11Binding_SaveUserProfiles alloc] initWithBinding:self delegate:self
																							parameters:aParameters
																							] autorelease]];
}
- (void)SaveUserProfilesAsyncUsingParameters:(tns1_SaveUserProfilesRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
{
	[self performAsynchronousOperation: [[(LibreAccessService_1_2_0Soap11Binding_SaveUserProfiles*)[LibreAccessService_1_2_0Soap11Binding_SaveUserProfiles alloc] initWithBinding:self delegate:responseDelegate
																							 parameters:aParameters
																							 ] autorelease]];
}
- (LibreAccessService_1_2_0Soap11BindingResponse *)SaveUserSettingsUsingParameters:(tns1_SaveUserSettingsRequest *)aParameters 
{
	return [self performSynchronousOperation:[[(LibreAccessService_1_2_0Soap11Binding_SaveUserSettings*)[LibreAccessService_1_2_0Soap11Binding_SaveUserSettings alloc] initWithBinding:self delegate:self
																							parameters:aParameters
																							] autorelease]];
}
- (void)SaveUserSettingsAsyncUsingParameters:(tns1_SaveUserSettingsRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
{
	[self performAsynchronousOperation: [[(LibreAccessService_1_2_0Soap11Binding_SaveUserSettings*)[LibreAccessService_1_2_0Soap11Binding_SaveUserSettings alloc] initWithBinding:self delegate:responseDelegate
																							 parameters:aParameters
																							 ] autorelease]];
}
- (LibreAccessService_1_2_0Soap11BindingResponse *)DeleteBookShelfEntryUsingParameters:(tns1_DeleteBookShelfEntryRequest *)aParameters 
{
	return [self performSynchronousOperation:[[(LibreAccessService_1_2_0Soap11Binding_DeleteBookShelfEntry*)[LibreAccessService_1_2_0Soap11Binding_DeleteBookShelfEntry alloc] initWithBinding:self delegate:self
																							parameters:aParameters
																							] autorelease]];
}
- (void)DeleteBookShelfEntryAsyncUsingParameters:(tns1_DeleteBookShelfEntryRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
{
	[self performAsynchronousOperation: [[(LibreAccessService_1_2_0Soap11Binding_DeleteBookShelfEntry*)[LibreAccessService_1_2_0Soap11Binding_DeleteBookShelfEntry alloc] initWithBinding:self delegate:responseDelegate
																							 parameters:aParameters
																							 ] autorelease]];
}
- (LibreAccessService_1_2_0Soap11BindingResponse *)GetUserProfilesUsingParameters:(tns1_GetUserProfilesRequest *)aParameters 
{
	return [self performSynchronousOperation:[[(LibreAccessService_1_2_0Soap11Binding_GetUserProfiles*)[LibreAccessService_1_2_0Soap11Binding_GetUserProfiles alloc] initWithBinding:self delegate:self
																							parameters:aParameters
																							] autorelease]];
}
- (void)GetUserProfilesAsyncUsingParameters:(tns1_GetUserProfilesRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
{
	[self performAsynchronousOperation: [[(LibreAccessService_1_2_0Soap11Binding_GetUserProfiles*)[LibreAccessService_1_2_0Soap11Binding_GetUserProfiles alloc] initWithBinding:self delegate:responseDelegate
																							 parameters:aParameters
																							 ] autorelease]];
}
- (LibreAccessService_1_2_0Soap11BindingResponse *)DeviceCanJoinDomainUsingParameters:(tns1_DeviceCanJoinDomainRequest *)aParameters 
{
	return [self performSynchronousOperation:[[(LibreAccessService_1_2_0Soap11Binding_DeviceCanJoinDomain*)[LibreAccessService_1_2_0Soap11Binding_DeviceCanJoinDomain alloc] initWithBinding:self delegate:self
																							parameters:aParameters
																							] autorelease]];
}
- (void)DeviceCanJoinDomainAsyncUsingParameters:(tns1_DeviceCanJoinDomainRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
{
	[self performAsynchronousOperation: [[(LibreAccessService_1_2_0Soap11Binding_DeviceCanJoinDomain*)[LibreAccessService_1_2_0Soap11Binding_DeviceCanJoinDomain alloc] initWithBinding:self delegate:responseDelegate
																							 parameters:aParameters
																							 ] autorelease]];
}
- (LibreAccessService_1_2_0Soap11BindingResponse *)SaveNewDomainUsingParameters:(tns1_SaveNewDomainRequest *)aParameters 
{
	return [self performSynchronousOperation:[[(LibreAccessService_1_2_0Soap11Binding_SaveNewDomain*)[LibreAccessService_1_2_0Soap11Binding_SaveNewDomain alloc] initWithBinding:self delegate:self
																							parameters:aParameters
																							] autorelease]];
}
- (void)SaveNewDomainAsyncUsingParameters:(tns1_SaveNewDomainRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
{
	[self performAsynchronousOperation: [[(LibreAccessService_1_2_0Soap11Binding_SaveNewDomain*)[LibreAccessService_1_2_0Soap11Binding_SaveNewDomain alloc] initWithBinding:self delegate:responseDelegate
																							 parameters:aParameters
																							 ] autorelease]];
}
- (LibreAccessService_1_2_0Soap11BindingResponse *)SaveUserCSRNotesUsingParameters:(tns1_SaveUserCSRNotesRequest *)aParameters 
{
	return [self performSynchronousOperation:[[(LibreAccessService_1_2_0Soap11Binding_SaveUserCSRNotes*)[LibreAccessService_1_2_0Soap11Binding_SaveUserCSRNotes alloc] initWithBinding:self delegate:self
																							parameters:aParameters
																							] autorelease]];
}
- (void)SaveUserCSRNotesAsyncUsingParameters:(tns1_SaveUserCSRNotesRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
{
	[self performAsynchronousOperation: [[(LibreAccessService_1_2_0Soap11Binding_SaveUserCSRNotes*)[LibreAccessService_1_2_0Soap11Binding_SaveUserCSRNotes alloc] initWithBinding:self delegate:responseDelegate
																							 parameters:aParameters
																							 ] autorelease]];
}
- (LibreAccessService_1_2_0Soap11BindingResponse *)SaveProfileContentAnnotationsUsingParameters:(tns1_SaveProfileContentAnnotationsRequest *)aParameters 
{
	return [self performSynchronousOperation:[[(LibreAccessService_1_2_0Soap11Binding_SaveProfileContentAnnotations*)[LibreAccessService_1_2_0Soap11Binding_SaveProfileContentAnnotations alloc] initWithBinding:self delegate:self
																							parameters:aParameters
																							] autorelease]];
}
- (void)SaveProfileContentAnnotationsAsyncUsingParameters:(tns1_SaveProfileContentAnnotationsRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
{
	[self performAsynchronousOperation: [[(LibreAccessService_1_2_0Soap11Binding_SaveProfileContentAnnotations*)[LibreAccessService_1_2_0Soap11Binding_SaveProfileContentAnnotations alloc] initWithBinding:self delegate:responseDelegate
																							 parameters:aParameters
																							 ] autorelease]];
}
- (LibreAccessService_1_2_0Soap11BindingResponse *)RemoveDefaultBooksUsingParameters:(tns1_RemoveDefaultBooksRequest *)aParameters 
{
	return [self performSynchronousOperation:[[(LibreAccessService_1_2_0Soap11Binding_RemoveDefaultBooks*)[LibreAccessService_1_2_0Soap11Binding_RemoveDefaultBooks alloc] initWithBinding:self delegate:self
																							parameters:aParameters
																							] autorelease]];
}
- (void)RemoveDefaultBooksAsyncUsingParameters:(tns1_RemoveDefaultBooksRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
{
	[self performAsynchronousOperation: [[(LibreAccessService_1_2_0Soap11Binding_RemoveDefaultBooks*)[LibreAccessService_1_2_0Soap11Binding_RemoveDefaultBooks alloc] initWithBinding:self delegate:responseDelegate
																							 parameters:aParameters
																							 ] autorelease]];
}
- (LibreAccessService_1_2_0Soap11BindingResponse *)SetAccountAutoAssignUsingParameters:(tns1_SetAccountAutoAssignRequest *)aParameters 
{
	return [self performSynchronousOperation:[[(LibreAccessService_1_2_0Soap11Binding_SetAccountAutoAssign*)[LibreAccessService_1_2_0Soap11Binding_SetAccountAutoAssign alloc] initWithBinding:self delegate:self
																							parameters:aParameters
																							] autorelease]];
}
- (void)SetAccountAutoAssignAsyncUsingParameters:(tns1_SetAccountAutoAssignRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
{
	[self performAsynchronousOperation: [[(LibreAccessService_1_2_0Soap11Binding_SetAccountAutoAssign*)[LibreAccessService_1_2_0Soap11Binding_SetAccountAutoAssign alloc] initWithBinding:self delegate:responseDelegate
																							 parameters:aParameters
																							 ] autorelease]];
}
- (LibreAccessService_1_2_0Soap11BindingResponse *)TokenExchangeUsingBody:(tns1_TokenExchange *)aBody 
{
	return [self performSynchronousOperation:[[(LibreAccessService_1_2_0Soap11Binding_TokenExchange*)[LibreAccessService_1_2_0Soap11Binding_TokenExchange alloc] initWithBinding:self delegate:self
																							body:aBody
																							] autorelease]];
}
- (void)TokenExchangeAsyncUsingBody:(tns1_TokenExchange *)aBody  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
{
	[self performAsynchronousOperation: [[(LibreAccessService_1_2_0Soap11Binding_TokenExchange*)[LibreAccessService_1_2_0Soap11Binding_TokenExchange alloc] initWithBinding:self delegate:responseDelegate
																							 body:aBody
																							 ] autorelease]];
}
- (LibreAccessService_1_2_0Soap11BindingResponse *)RenewTokenUsingBody:(tns1_RenewTokenRequest *)aBody 
{
	return [self performSynchronousOperation:[[(LibreAccessService_1_2_0Soap11Binding_RenewToken*)[LibreAccessService_1_2_0Soap11Binding_RenewToken alloc] initWithBinding:self delegate:self
																							body:aBody
																							] autorelease]];
}
- (void)RenewTokenAsyncUsingBody:(tns1_RenewTokenRequest *)aBody  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
{
	[self performAsynchronousOperation: [[(LibreAccessService_1_2_0Soap11Binding_RenewToken*)[LibreAccessService_1_2_0Soap11Binding_RenewToken alloc] initWithBinding:self delegate:responseDelegate
																							 body:aBody
																							 ] autorelease]];
}
- (LibreAccessService_1_2_0Soap11BindingResponse *)ListRatingsUsingParameters:(tns1_ListRatingsRequest *)aParameters 
{
	return [self performSynchronousOperation:[[(LibreAccessService_1_2_0Soap11Binding_ListRatings*)[LibreAccessService_1_2_0Soap11Binding_ListRatings alloc] initWithBinding:self delegate:self
																							parameters:aParameters
																							] autorelease]];
}
- (void)ListRatingsAsyncUsingParameters:(tns1_ListRatingsRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
{
	[self performAsynchronousOperation: [[(LibreAccessService_1_2_0Soap11Binding_ListRatings*)[LibreAccessService_1_2_0Soap11Binding_ListRatings alloc] initWithBinding:self delegate:responseDelegate
																							 parameters:aParameters
																							 ] autorelease]];
}
- (LibreAccessService_1_2_0Soap11BindingResponse *)ListBooksAssignmentUsingBody:(tns1_ListBooksAssignmentRequest *)aBody 
{
	return [self performSynchronousOperation:[[(LibreAccessService_1_2_0Soap11Binding_ListBooksAssignment*)[LibreAccessService_1_2_0Soap11Binding_ListBooksAssignment alloc] initWithBinding:self delegate:self
																							body:aBody
																							] autorelease]];
}
- (void)ListBooksAssignmentAsyncUsingBody:(tns1_ListBooksAssignmentRequest *)aBody  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
{
	[self performAsynchronousOperation: [[(LibreAccessService_1_2_0Soap11Binding_ListBooksAssignment*)[LibreAccessService_1_2_0Soap11Binding_ListBooksAssignment alloc] initWithBinding:self delegate:responseDelegate
																							 body:aBody
																							 ] autorelease]];
}
- (LibreAccessService_1_2_0Soap11BindingResponse *)AcknowledgeLicenseUsingParameters:(tns1_AcknowledgeLicenseRequest *)aParameters 
{
	return [self performSynchronousOperation:[[(LibreAccessService_1_2_0Soap11Binding_AcknowledgeLicense*)[LibreAccessService_1_2_0Soap11Binding_AcknowledgeLicense alloc] initWithBinding:self delegate:self
																							parameters:aParameters
																							] autorelease]];
}
- (void)AcknowledgeLicenseAsyncUsingParameters:(tns1_AcknowledgeLicenseRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
{
	[self performAsynchronousOperation: [[(LibreAccessService_1_2_0Soap11Binding_AcknowledgeLicense*)[LibreAccessService_1_2_0Soap11Binding_AcknowledgeLicense alloc] initWithBinding:self delegate:responseDelegate
																							 parameters:aParameters
																							 ] autorelease]];
}
- (LibreAccessService_1_2_0Soap11BindingResponse *)SharedTokenExchangeUsingBody:(tns1_SharedTokenExchangeRequest *)aBody 
{
	return [self performSynchronousOperation:[[(LibreAccessService_1_2_0Soap11Binding_SharedTokenExchange*)[LibreAccessService_1_2_0Soap11Binding_SharedTokenExchange alloc] initWithBinding:self delegate:self
																							body:aBody
																							] autorelease]];
}
- (void)SharedTokenExchangeAsyncUsingBody:(tns1_SharedTokenExchangeRequest *)aBody  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
{
	[self performAsynchronousOperation: [[(LibreAccessService_1_2_0Soap11Binding_SharedTokenExchange*)[LibreAccessService_1_2_0Soap11Binding_SharedTokenExchange alloc] initWithBinding:self delegate:responseDelegate
																							 body:aBody
																							 ] autorelease]];
}
- (LibreAccessService_1_2_0Soap11BindingResponse *)DeviceLeftDomainUsingParameters:(tns1_DeviceLeftDomainRequest *)aParameters 
{
	return [self performSynchronousOperation:[[(LibreAccessService_1_2_0Soap11Binding_DeviceLeftDomain*)[LibreAccessService_1_2_0Soap11Binding_DeviceLeftDomain alloc] initWithBinding:self delegate:self
																							parameters:aParameters
																							] autorelease]];
}
- (void)DeviceLeftDomainAsyncUsingParameters:(tns1_DeviceLeftDomainRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
{
	[self performAsynchronousOperation: [[(LibreAccessService_1_2_0Soap11Binding_DeviceLeftDomain*)[LibreAccessService_1_2_0Soap11Binding_DeviceLeftDomain alloc] initWithBinding:self delegate:responseDelegate
																							 parameters:aParameters
																							 ] autorelease]];
}
- (LibreAccessService_1_2_0Soap11BindingResponse *)GetLicensableStatusUsingParameters:(tns1_GetLicensableStatusRequest *)aParameters 
{
	return [self performSynchronousOperation:[[(LibreAccessService_1_2_0Soap11Binding_GetLicensableStatus*)[LibreAccessService_1_2_0Soap11Binding_GetLicensableStatus alloc] initWithBinding:self delegate:self
																							parameters:aParameters
																							] autorelease]];
}
- (void)GetLicensableStatusAsyncUsingParameters:(tns1_GetLicensableStatusRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
{
	[self performAsynchronousOperation: [[(LibreAccessService_1_2_0Soap11Binding_GetLicensableStatus*)[LibreAccessService_1_2_0Soap11Binding_GetLicensableStatus alloc] initWithBinding:self delegate:responseDelegate
																							 parameters:aParameters
																							 ] autorelease]];
}
- (LibreAccessService_1_2_0Soap11BindingResponse *)ListReadingStatisticsMonthlyAverageUsingParameters:(tns1_ListReadingStatisticsMonthlyAverageRequest *)aParameters 
{
	return [self performSynchronousOperation:[[(LibreAccessService_1_2_0Soap11Binding_ListReadingStatisticsMonthlyAverage*)[LibreAccessService_1_2_0Soap11Binding_ListReadingStatisticsMonthlyAverage alloc] initWithBinding:self delegate:self
																							parameters:aParameters
																							] autorelease]];
}
- (void)ListReadingStatisticsMonthlyAverageAsyncUsingParameters:(tns1_ListReadingStatisticsMonthlyAverageRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
{
	[self performAsynchronousOperation: [[(LibreAccessService_1_2_0Soap11Binding_ListReadingStatisticsMonthlyAverage*)[LibreAccessService_1_2_0Soap11Binding_ListReadingStatisticsMonthlyAverage alloc] initWithBinding:self delegate:responseDelegate
																							 parameters:aParameters
																							 ] autorelease]];
}
- (LibreAccessService_1_2_0Soap11BindingResponse *)ListReadBooksUsingParameters:(tns1_ListReadBooksRequest *)aParameters 
{
	return [self performSynchronousOperation:[[(LibreAccessService_1_2_0Soap11Binding_ListReadBooks*)[LibreAccessService_1_2_0Soap11Binding_ListReadBooks alloc] initWithBinding:self delegate:self
																							parameters:aParameters
																							] autorelease]];
}
- (void)ListReadBooksAsyncUsingParameters:(tns1_ListReadBooksRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
{
	[self performAsynchronousOperation: [[(LibreAccessService_1_2_0Soap11Binding_ListReadBooks*)[LibreAccessService_1_2_0Soap11Binding_ListReadBooks alloc] initWithBinding:self delegate:responseDelegate
																							 parameters:aParameters
																							 ] autorelease]];
}
- (LibreAccessService_1_2_0Soap11BindingResponse *)ValidateUserKeyUsingParameters:(tns1_ValidateUserKeyRequest *)aParameters 
{
	return [self performSynchronousOperation:[[(LibreAccessService_1_2_0Soap11Binding_ValidateUserKey*)[LibreAccessService_1_2_0Soap11Binding_ValidateUserKey alloc] initWithBinding:self delegate:self
																							parameters:aParameters
																							] autorelease]];
}
- (void)ValidateUserKeyAsyncUsingParameters:(tns1_ValidateUserKeyRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
{
	[self performAsynchronousOperation: [[(LibreAccessService_1_2_0Soap11Binding_ValidateUserKey*)[LibreAccessService_1_2_0Soap11Binding_ValidateUserKey alloc] initWithBinding:self delegate:responseDelegate
																							 parameters:aParameters
																							 ] autorelease]];
}
- (LibreAccessService_1_2_0Soap11BindingResponse *)ListUserCSRNotesUsingParameters:(tns1_ListUserCSRNotesRequest *)aParameters 
{
	return [self performSynchronousOperation:[[(LibreAccessService_1_2_0Soap11Binding_ListUserCSRNotes*)[LibreAccessService_1_2_0Soap11Binding_ListUserCSRNotes alloc] initWithBinding:self delegate:self
																							parameters:aParameters
																							] autorelease]];
}
- (void)ListUserCSRNotesAsyncUsingParameters:(tns1_ListUserCSRNotesRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
{
	[self performAsynchronousOperation: [[(LibreAccessService_1_2_0Soap11Binding_ListUserCSRNotes*)[LibreAccessService_1_2_0Soap11Binding_ListUserCSRNotes alloc] initWithBinding:self delegate:responseDelegate
																							 parameters:aParameters
																							 ] autorelease]];
}
- (LibreAccessService_1_2_0Soap11BindingResponse *)SaveLastPageLocationUsingParameters:(tns1_SaveLastPageLocationRequest *)aParameters 
{
	return [self performSynchronousOperation:[[(LibreAccessService_1_2_0Soap11Binding_SaveLastPageLocation*)[LibreAccessService_1_2_0Soap11Binding_SaveLastPageLocation alloc] initWithBinding:self delegate:self
																							parameters:aParameters
																							] autorelease]];
}
- (void)SaveLastPageLocationAsyncUsingParameters:(tns1_SaveLastPageLocationRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
{
	[self performAsynchronousOperation: [[(LibreAccessService_1_2_0Soap11Binding_SaveLastPageLocation*)[LibreAccessService_1_2_0Soap11Binding_SaveLastPageLocation alloc] initWithBinding:self delegate:responseDelegate
																							 parameters:aParameters
																							 ] autorelease]];
}
- (LibreAccessService_1_2_0Soap11BindingResponse *)SaveRatingsUsingParameters:(tns1_SaveRatingsRequest *)aParameters 
{
	return [self performSynchronousOperation:[[(LibreAccessService_1_2_0Soap11Binding_SaveRatings*)[LibreAccessService_1_2_0Soap11Binding_SaveRatings alloc] initWithBinding:self delegate:self
																							parameters:aParameters
																							] autorelease]];
}
- (void)SaveRatingsAsyncUsingParameters:(tns1_SaveRatingsRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
{
	[self performAsynchronousOperation: [[(LibreAccessService_1_2_0Soap11Binding_SaveRatings*)[LibreAccessService_1_2_0Soap11Binding_SaveRatings alloc] initWithBinding:self delegate:responseDelegate
																							 parameters:aParameters
																							 ] autorelease]];
}
- (LibreAccessService_1_2_0Soap11BindingResponse *)ListUserSettingsUsingParameters:(tns1_ListUserSettingsRequest *)aParameters 
{
	return [self performSynchronousOperation:[[(LibreAccessService_1_2_0Soap11Binding_ListUserSettings*)[LibreAccessService_1_2_0Soap11Binding_ListUserSettings alloc] initWithBinding:self delegate:self
																							parameters:aParameters
																							] autorelease]];
}
- (void)ListUserSettingsAsyncUsingParameters:(tns1_ListUserSettingsRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
{
	[self performAsynchronousOperation: [[(LibreAccessService_1_2_0Soap11Binding_ListUserSettings*)[LibreAccessService_1_2_0Soap11Binding_ListUserSettings alloc] initWithBinding:self delegate:responseDelegate
																							 parameters:aParameters
																							 ] autorelease]];
}
- (LibreAccessService_1_2_0Soap11BindingResponse *)ListProfileContentAnnotationsUsingParameters:(tns1_ListProfileContentAnnotationsRequest *)aParameters 
{
	return [self performSynchronousOperation:[[(LibreAccessService_1_2_0Soap11Binding_ListProfileContentAnnotations*)[LibreAccessService_1_2_0Soap11Binding_ListProfileContentAnnotations alloc] initWithBinding:self delegate:self
																							parameters:aParameters
																							] autorelease]];
}
- (void)ListProfileContentAnnotationsAsyncUsingParameters:(tns1_ListProfileContentAnnotationsRequest *)aParameters  delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
{
	[self performAsynchronousOperation: [[(LibreAccessService_1_2_0Soap11Binding_ListProfileContentAnnotations*)[LibreAccessService_1_2_0Soap11Binding_ListProfileContentAnnotations alloc] initWithBinding:self delegate:responseDelegate
																							 parameters:aParameters
																							 ] autorelease]];
}
- (void)sendHTTPCallUsingBody:(NSString *)outputBody soapAction:(NSString *)soapAction forOperation:(LibreAccessService_1_2_0Soap11BindingOperation *)operation
{
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.address 
																												 cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
																										 timeoutInterval:self.timeout];
	NSData *bodyData = [outputBody dataUsingEncoding:NSUTF8StringEncoding];
	
	if(cookies != nil) {
		[request setAllHTTPHeaderFields:[NSHTTPCookie requestHeaderFieldsWithCookies:cookies]];
	}
	[request setValue:@"wsdl2objc" forHTTPHeaderField:@"User-Agent"];
	[request setValue:soapAction forHTTPHeaderField:@"SOAPAction"];
	[request setValue:[[self MIMEType] stringByAppendingString:@"; charset=utf-8"] forHTTPHeaderField:@"Content-Type"];
	[request setValue:[NSString stringWithFormat:@"%u", [bodyData length]] forHTTPHeaderField:@"Content-Length"];
	[request setValue:self.address.host forHTTPHeaderField:@"Host"];
	for (NSString *eachHeaderField in [self.customHeaders allKeys]) {
		[request setValue:[self.customHeaders objectForKey:eachHeaderField] forHTTPHeaderField:eachHeaderField];
	}
	[request setHTTPMethod: @"POST"];
	// set version 1.1 - how?
	[request setHTTPBody: bodyData];
		
	if(self.logXMLInOut) {
		NSLog(@"OutputHeaders:\n%@", [request allHTTPHeaderFields]);
		NSLog(@"OutputBody:\n%@", outputBody);
	}
	
	NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:operation];
	
	operation.urlConnection = connection;
	[connection release];
}
- (void) addPointerForOperation:(LibreAccessService_1_2_0Soap11BindingOperation *)operation
{
    NSValue *pointerValue = [NSValue valueWithNonretainedObject:operation];
    [self.operationPointers addObject:pointerValue];
}
- (void) removePointerForOperation:(LibreAccessService_1_2_0Soap11BindingOperation *)operation
{
    NSIndexSet *matches = [self.operationPointers indexesOfObjectsPassingTest:^BOOL (id el, NSUInteger i, BOOL *stop) {
                               LibreAccessService_1_2_0Soap11BindingOperation *op = [el nonretainedObjectValue];
                               return [op isEqual:operation];
                           }];
    [self.operationPointers removeObjectsAtIndexes:matches];
}
- (void) clearBindingOperations
{
    for (NSValue *pointerValue in self.operationPointers) {
        LibreAccessService_1_2_0Soap11BindingOperation *operation = [pointerValue nonretainedObjectValue];
        [operation clear];
    }
}
- (void) dealloc
{
    [self clearBindingOperations];
	[address release];
	[cookies release];
	[customHeaders release];
	[authUsername release];
	[authPassword release];
    [operationPointers release];
	[super dealloc];
}
@end
@implementation LibreAccessService_1_2_0Soap11BindingOperation
@synthesize binding;
@synthesize response;
@synthesize delegate;
@synthesize responseHeaders;
@synthesize responseData;
@synthesize serverDateDelta;
@synthesize urlConnection;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)aDelegate
{
	if ((self = [super init])) {
		self.binding = aBinding;
        [self.binding addPointerForOperation:self];
		response = nil;
		self.delegate = aDelegate;
		self.responseData = nil;
		self.urlConnection = nil;
	}
	
	return self;
}
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
	if ([challenge previousFailureCount] == 0) {
		NSURLCredential *newCredential;
		newCredential=[NSURLCredential credentialWithUser:self.binding.authUsername
												 password:self.binding.authPassword
											  persistence:NSURLCredentialPersistenceForSession];
		[[challenge sender] useCredential:newCredential
			   forAuthenticationChallenge:challenge];
	} else {
		[[challenge sender] cancelAuthenticationChallenge:challenge];
		NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Authentication Error" forKey:NSLocalizedDescriptionKey];
		NSError *authError = [NSError errorWithDomain:@"Connection Authentication" code:0 userInfo:userInfo];
		[self connection:connection didFailWithError:authError];
	}
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)urlResponse
{
	NSHTTPURLResponse *httpResponse;
	if ([urlResponse isKindOfClass:[NSHTTPURLResponse class]]) {
		httpResponse = (NSHTTPURLResponse *) urlResponse;
	} else {
		httpResponse = nil;
	}
	
	if(self.binding.logXMLInOut) {
		NSLog(@"ResponseStatus: %ld\n", (long)[httpResponse statusCode]);
		NSLog(@"ResponseHeaders:\n%@", [httpResponse allHeaderFields]);
	}
	self.responseHeaders = [httpResponse allHeaderFields];
	static NSDateFormatter *dateFormatter = nil;
	if (dateFormatter == nil) {
		dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease]];
		[dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss zzz"]; 
	}
	NSDate *serverDate = [dateFormatter dateFromString:[self.responseHeaders objectForKey:@"Date"]];
	self.serverDateDelta = (serverDate == nil ? 0.0 : [serverDate timeIntervalSinceNow]);
	
	if ([urlResponse.MIMEType rangeOfString:[self.binding MIMEType]].length == 0) {
		NSError *error = nil;
		[connection cancel];
		if ([httpResponse statusCode] >= 400) {
			NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSHTTPURLResponse localizedStringForStatusCode:[httpResponse statusCode]],NSLocalizedDescriptionKey,
                                                                          httpResponse.URL, NSURLErrorKey,nil];
				
			error = [NSError errorWithDomain:@"LibreAccessService_1_2_0Soap11BindingResponseHTTP" code:[httpResponse statusCode] userInfo:userInfo];
		} else {
			NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
	 												[NSString stringWithFormat: @"Unexpected response MIME type to SOAP call:%@", urlResponse.MIMEType],NSLocalizedDescriptionKey,
                                                                          httpResponse.URL, NSURLErrorKey,nil];
			error = [NSError errorWithDomain:@"LibreAccessService_1_2_0Soap11BindingResponseHTTP" code:1 userInfo:userInfo];
		}
				
		[self connection:connection didFailWithError:error];
	} else if ([httpResponse statusCode] >= 400) {
		NSError *error = nil;
		[connection cancel];	
		NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSHTTPURLResponse localizedStringForStatusCode:[httpResponse statusCode]],NSLocalizedDescriptionKey,
                                                                         httpResponse.URL, NSURLErrorKey, nil];
				
		error = [NSError errorWithDomain:@"LibreAccessService_1_2_0Soap11BindingResponseHTTP" code:[httpResponse statusCode] userInfo:userInfo];
		[self connection:connection didFailWithError:error];		
	}
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	if (responseData == nil) {
		responseData = [data mutableCopy];
	} else {
		[responseData appendData:data];
	}
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	if (binding.logXMLInOut) {
		NSLog(@"ResponseError:\n%@", error);
	}
	response.error = error;
	[delegate operation:self completedWithResponse:response];
}
- (void)dealloc
{
    [binding removePointerForOperation:self];
	[binding release];
	[response release];
	delegate = nil;
	[responseHeaders release];
	[responseData release];
	[urlConnection release];
	
	[super dealloc];
}
- (void)clear
{
    self.delegate = nil;
    [self.urlConnection cancel];
}
@end
@implementation LibreAccessService_1_2_0Soap11Binding_SetLoggingLevel
@synthesize parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
parameters:(tns1_SetLoggingLevelRequest *)aParameters
{
	if((self = [super initWithBinding:aBinding delegate:responseDelegate])) {
		self.parameters = aParameters;
	}
	
	return self;
}
- (void)dealloc
{
	if(parameters != nil) [parameters release];
	
	[super dealloc];
}
- (void)main
{
	[response autorelease];
	response = [LibreAccessService_1_2_0Soap11BindingResponse new];
	
	LibreAccessService_1_2_0Soap11Binding_envelope *envelope = [LibreAccessService_1_2_0Soap11Binding_envelope sharedInstance];
	
	NSMutableDictionary *headerElements = nil;
	headerElements = [NSMutableDictionary dictionary];
	
	NSMutableDictionary *bodyElements = nil;
	NSMutableArray *bodyKeys = nil;
	bodyElements = [NSMutableDictionary dictionary];
	bodyKeys = [NSMutableArray array];
	id obj;
	obj = nil;
	if(parameters != nil) obj = parameters;
	if(obj != nil) {
		[bodyElements setObject:obj forKey:@"SetLoggingLevelRequest"];
		[bodyKeys addObject:@"SetLoggingLevelRequest"];
	}
	
	NSString *operationXMLString = [envelope serializedFormUsingHeaderElements:headerElements bodyElements:bodyElements bodyKeys:bodyKeys];
	
	[binding sendHTTPCallUsingBody:operationXMLString soapAction:@"http://webservices.libredigital.com/libreaccess/SetLoggingLevel" forOperation:self];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (responseData != nil && delegate != nil)
	{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			xmlDocPtr doc;
			xmlNodePtr cur;
		
			if (binding.logXMLInOut) {
				NSLog(@"ResponseBody:\n%@", [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease]);
			}
		
#if !TARGET_OS_IPHONE && (!defined(MAC_OS_X_VERSION_10_6) || MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_6)
	// Not yet defined in 10.5 libxml
	#define XML_PARSE_COMPACT 0
#endif
			doc = xmlReadMemory([responseData bytes], [responseData length], NULL, NULL, XML_PARSE_COMPACT | XML_PARSE_NOBLANKS);
		
			if (doc == NULL) {
				NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Errors while parsing returned XML" forKey:NSLocalizedDescriptionKey];
			
				response.error = [NSError errorWithDomain:@"LibreAccessService_1_2_0Soap11BindingResponseXML" code:1 userInfo:userInfo];
			} else {
				cur = xmlDocGetRootElement(doc);
				cur = cur->children;
			
				for( ; cur != NULL ; cur = cur->next) {
					if(cur->type == XML_ELEMENT_NODE) {
					
						if(xmlStrEqual(cur->name, (const xmlChar *) "Body")) {
							NSMutableArray *responseBodyParts = [NSMutableArray array];
						
							xmlNodePtr bodyNode;
							for(bodyNode=cur->children ; bodyNode != NULL ; bodyNode = bodyNode->next) {
								if(cur->type == XML_ELEMENT_NODE) {
									if(xmlStrEqual(bodyNode->name, (const xmlChar *) "SetLoggingLevelResponse")) {
										tns1_SetLoggingLevelResponse *bodyObject = [tns1_SetLoggingLevelResponse deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
									if ((bodyNode->ns != nil && xmlStrEqual(bodyNode->ns->prefix, cur->ns->prefix)) && 
										xmlStrEqual(bodyNode->name, (const xmlChar *) "Fault")) {
										SOAPFault *bodyObject = [SOAPFault deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
								}
							}
						
							response.bodyParts = responseBodyParts;
						}
					}
				}
			
				xmlFreeDoc(doc);
			}
			if(delegate != nil && [delegate respondsToSelector:@selector(operation:completedWithResponse:)] == YES) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[delegate operation:self completedWithResponse:response];
				});
			}
		});
	}
}
@end
@implementation LibreAccessService_1_2_0Soap11Binding_ListDefaultBooks
@synthesize parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
parameters:(tns1_ListDefaultBooksRequest *)aParameters
{
	if((self = [super initWithBinding:aBinding delegate:responseDelegate])) {
		self.parameters = aParameters;
	}
	
	return self;
}
- (void)dealloc
{
	if(parameters != nil) [parameters release];
	
	[super dealloc];
}
- (void)main
{
	[response autorelease];
	response = [LibreAccessService_1_2_0Soap11BindingResponse new];
	
	LibreAccessService_1_2_0Soap11Binding_envelope *envelope = [LibreAccessService_1_2_0Soap11Binding_envelope sharedInstance];
	
	NSMutableDictionary *headerElements = nil;
	headerElements = [NSMutableDictionary dictionary];
	
	NSMutableDictionary *bodyElements = nil;
	NSMutableArray *bodyKeys = nil;
	bodyElements = [NSMutableDictionary dictionary];
	bodyKeys = [NSMutableArray array];
	id obj;
	obj = nil;
	if(parameters != nil) obj = parameters;
	if(obj != nil) {
		[bodyElements setObject:obj forKey:@"ListDefaultBooksRequest"];
		[bodyKeys addObject:@"ListDefaultBooksRequest"];
	}
	
	NSString *operationXMLString = [envelope serializedFormUsingHeaderElements:headerElements bodyElements:bodyElements bodyKeys:bodyKeys];
	
	[binding sendHTTPCallUsingBody:operationXMLString soapAction:@"http://webservices.libredigital.com/libreaccess/ListDefaultBooks" forOperation:self];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (responseData != nil && delegate != nil)
	{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			xmlDocPtr doc;
			xmlNodePtr cur;
		
			if (binding.logXMLInOut) {
				NSLog(@"ResponseBody:\n%@", [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease]);
			}
		
#if !TARGET_OS_IPHONE && (!defined(MAC_OS_X_VERSION_10_6) || MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_6)
	// Not yet defined in 10.5 libxml
	#define XML_PARSE_COMPACT 0
#endif
			doc = xmlReadMemory([responseData bytes], [responseData length], NULL, NULL, XML_PARSE_COMPACT | XML_PARSE_NOBLANKS);
		
			if (doc == NULL) {
				NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Errors while parsing returned XML" forKey:NSLocalizedDescriptionKey];
			
				response.error = [NSError errorWithDomain:@"LibreAccessService_1_2_0Soap11BindingResponseXML" code:1 userInfo:userInfo];
			} else {
				cur = xmlDocGetRootElement(doc);
				cur = cur->children;
			
				for( ; cur != NULL ; cur = cur->next) {
					if(cur->type == XML_ELEMENT_NODE) {
					
						if(xmlStrEqual(cur->name, (const xmlChar *) "Body")) {
							NSMutableArray *responseBodyParts = [NSMutableArray array];
						
							xmlNodePtr bodyNode;
							for(bodyNode=cur->children ; bodyNode != NULL ; bodyNode = bodyNode->next) {
								if(cur->type == XML_ELEMENT_NODE) {
									if(xmlStrEqual(bodyNode->name, (const xmlChar *) "ListDefaultBooksResponse")) {
										tns1_ListDefaultBooksResponse *bodyObject = [tns1_ListDefaultBooksResponse deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
									if ((bodyNode->ns != nil && xmlStrEqual(bodyNode->ns->prefix, cur->ns->prefix)) && 
										xmlStrEqual(bodyNode->name, (const xmlChar *) "Fault")) {
										SOAPFault *bodyObject = [SOAPFault deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
								}
							}
						
							response.bodyParts = responseBodyParts;
						}
					}
				}
			
				xmlFreeDoc(doc);
			}
			if(delegate != nil && [delegate respondsToSelector:@selector(operation:completedWithResponse:)] == YES) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[delegate operation:self completedWithResponse:response];
				});
			}
		});
	}
}
@end
@implementation LibreAccessService_1_2_0Soap11Binding_AuthenticateDevice
@synthesize body;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
body:(tns1_AuthenticateDeviceRequest *)aBody
{
	if((self = [super initWithBinding:aBinding delegate:responseDelegate])) {
		self.body = aBody;
	}
	
	return self;
}
- (void)dealloc
{
	if(body != nil) [body release];
	
	[super dealloc];
}
- (void)main
{
	[response autorelease];
	response = [LibreAccessService_1_2_0Soap11BindingResponse new];
	
	LibreAccessService_1_2_0Soap11Binding_envelope *envelope = [LibreAccessService_1_2_0Soap11Binding_envelope sharedInstance];
	
	NSMutableDictionary *headerElements = nil;
	headerElements = [NSMutableDictionary dictionary];
	
	NSMutableDictionary *bodyElements = nil;
	NSMutableArray *bodyKeys = nil;
	bodyElements = [NSMutableDictionary dictionary];
	bodyKeys = [NSMutableArray array];
	id obj;
	obj = nil;
	if(body != nil) obj = body;
	if(obj != nil) {
		[bodyElements setObject:obj forKey:@"AuthenticateDeviceRequest"];
		[bodyKeys addObject:@"AuthenticateDeviceRequest"];
	}
	
	NSString *operationXMLString = [envelope serializedFormUsingHeaderElements:headerElements bodyElements:bodyElements bodyKeys:bodyKeys];
	
	[binding sendHTTPCallUsingBody:operationXMLString soapAction:@"http://webservices.libredigital.com/libreaccess/AuthenticateDevice" forOperation:self];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (responseData != nil && delegate != nil)
	{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			xmlDocPtr doc;
			xmlNodePtr cur;
		
			if (binding.logXMLInOut) {
				NSLog(@"ResponseBody:\n%@", [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease]);
			}
		
#if !TARGET_OS_IPHONE && (!defined(MAC_OS_X_VERSION_10_6) || MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_6)
	// Not yet defined in 10.5 libxml
	#define XML_PARSE_COMPACT 0
#endif
			doc = xmlReadMemory([responseData bytes], [responseData length], NULL, NULL, XML_PARSE_COMPACT | XML_PARSE_NOBLANKS);
		
			if (doc == NULL) {
				NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Errors while parsing returned XML" forKey:NSLocalizedDescriptionKey];
			
				response.error = [NSError errorWithDomain:@"LibreAccessService_1_2_0Soap11BindingResponseXML" code:1 userInfo:userInfo];
			} else {
				cur = xmlDocGetRootElement(doc);
				cur = cur->children;
			
				for( ; cur != NULL ; cur = cur->next) {
					if(cur->type == XML_ELEMENT_NODE) {
					
						if(xmlStrEqual(cur->name, (const xmlChar *) "Body")) {
							NSMutableArray *responseBodyParts = [NSMutableArray array];
						
							xmlNodePtr bodyNode;
							for(bodyNode=cur->children ; bodyNode != NULL ; bodyNode = bodyNode->next) {
								if(cur->type == XML_ELEMENT_NODE) {
									if(xmlStrEqual(bodyNode->name, (const xmlChar *) "AuthenticateDeviceResponse")) {
										tns1_AuthenticateDeviceResponse *bodyObject = [tns1_AuthenticateDeviceResponse deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
									if ((bodyNode->ns != nil && xmlStrEqual(bodyNode->ns->prefix, cur->ns->prefix)) && 
										xmlStrEqual(bodyNode->name, (const xmlChar *) "Fault")) {
										SOAPFault *bodyObject = [SOAPFault deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
								}
							}
						
							response.bodyParts = responseBodyParts;
						}
					}
				}
			
				xmlFreeDoc(doc);
			}
			if(delegate != nil && [delegate respondsToSelector:@selector(operation:completedWithResponse:)] == YES) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[delegate operation:self completedWithResponse:response];
				});
			}
		});
	}
}
@end
@implementation LibreAccessService_1_2_0Soap11Binding_ListReadingStatisticsDetailed
@synthesize parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
parameters:(tns1_ListReadingStatisticsDetailedRequest *)aParameters
{
	if((self = [super initWithBinding:aBinding delegate:responseDelegate])) {
		self.parameters = aParameters;
	}
	
	return self;
}
- (void)dealloc
{
	if(parameters != nil) [parameters release];
	
	[super dealloc];
}
- (void)main
{
	[response autorelease];
	response = [LibreAccessService_1_2_0Soap11BindingResponse new];
	
	LibreAccessService_1_2_0Soap11Binding_envelope *envelope = [LibreAccessService_1_2_0Soap11Binding_envelope sharedInstance];
	
	NSMutableDictionary *headerElements = nil;
	headerElements = [NSMutableDictionary dictionary];
	
	NSMutableDictionary *bodyElements = nil;
	NSMutableArray *bodyKeys = nil;
	bodyElements = [NSMutableDictionary dictionary];
	bodyKeys = [NSMutableArray array];
	id obj;
	obj = nil;
	if(parameters != nil) obj = parameters;
	if(obj != nil) {
		[bodyElements setObject:obj forKey:@"ListReadingStatisticsDetailedRequest"];
		[bodyKeys addObject:@"ListReadingStatisticsDetailedRequest"];
	}
	
	NSString *operationXMLString = [envelope serializedFormUsingHeaderElements:headerElements bodyElements:bodyElements bodyKeys:bodyKeys];
	
	[binding sendHTTPCallUsingBody:operationXMLString soapAction:@"http://webservices.libredigital.com/libreaccess/ListReadingStatisticsDetailed" forOperation:self];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (responseData != nil && delegate != nil)
	{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			xmlDocPtr doc;
			xmlNodePtr cur;
		
			if (binding.logXMLInOut) {
				NSLog(@"ResponseBody:\n%@", [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease]);
			}
		
#if !TARGET_OS_IPHONE && (!defined(MAC_OS_X_VERSION_10_6) || MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_6)
	// Not yet defined in 10.5 libxml
	#define XML_PARSE_COMPACT 0
#endif
			doc = xmlReadMemory([responseData bytes], [responseData length], NULL, NULL, XML_PARSE_COMPACT | XML_PARSE_NOBLANKS);
		
			if (doc == NULL) {
				NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Errors while parsing returned XML" forKey:NSLocalizedDescriptionKey];
			
				response.error = [NSError errorWithDomain:@"LibreAccessService_1_2_0Soap11BindingResponseXML" code:1 userInfo:userInfo];
			} else {
				cur = xmlDocGetRootElement(doc);
				cur = cur->children;
			
				for( ; cur != NULL ; cur = cur->next) {
					if(cur->type == XML_ELEMENT_NODE) {
					
						if(xmlStrEqual(cur->name, (const xmlChar *) "Body")) {
							NSMutableArray *responseBodyParts = [NSMutableArray array];
						
							xmlNodePtr bodyNode;
							for(bodyNode=cur->children ; bodyNode != NULL ; bodyNode = bodyNode->next) {
								if(cur->type == XML_ELEMENT_NODE) {
									if(xmlStrEqual(bodyNode->name, (const xmlChar *) "ListReadingStatisticsDetailedResponse")) {
										tns1_ListReadingStatisticsDetailedResponse *bodyObject = [tns1_ListReadingStatisticsDetailedResponse deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
									if ((bodyNode->ns != nil && xmlStrEqual(bodyNode->ns->prefix, cur->ns->prefix)) && 
										xmlStrEqual(bodyNode->name, (const xmlChar *) "Fault")) {
										SOAPFault *bodyObject = [SOAPFault deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
								}
							}
						
							response.bodyParts = responseBodyParts;
						}
					}
				}
			
				xmlFreeDoc(doc);
			}
			if(delegate != nil && [delegate respondsToSelector:@selector(operation:completedWithResponse:)] == YES) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[delegate operation:self completedWithResponse:response];
				});
			}
		});
	}
}
@end
@implementation LibreAccessService_1_2_0Soap11Binding_ListContentMetadata
@synthesize body;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
body:(tns1_ListContentMetadata *)aBody
{
	if((self = [super initWithBinding:aBinding delegate:responseDelegate])) {
		self.body = aBody;
	}
	
	return self;
}
- (void)dealloc
{
	if(body != nil) [body release];
	
	[super dealloc];
}
- (void)main
{
	[response autorelease];
	response = [LibreAccessService_1_2_0Soap11BindingResponse new];
	
	LibreAccessService_1_2_0Soap11Binding_envelope *envelope = [LibreAccessService_1_2_0Soap11Binding_envelope sharedInstance];
	
	NSMutableDictionary *headerElements = nil;
	headerElements = [NSMutableDictionary dictionary];
	
	NSMutableDictionary *bodyElements = nil;
	NSMutableArray *bodyKeys = nil;
	bodyElements = [NSMutableDictionary dictionary];
	bodyKeys = [NSMutableArray array];
	id obj;
	obj = nil;
	if(body != nil) obj = body;
	if(obj != nil) {
		[bodyElements setObject:obj forKey:@"ListContentMetadata"];
		[bodyKeys addObject:@"ListContentMetadata"];
	}
	
	NSString *operationXMLString = [envelope serializedFormUsingHeaderElements:headerElements bodyElements:bodyElements bodyKeys:bodyKeys];
	
	[binding sendHTTPCallUsingBody:operationXMLString soapAction:@"http://webservices.libredigital.com/libreaccess/ListContentMetadata" forOperation:self];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (responseData != nil && delegate != nil)
	{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			xmlDocPtr doc;
			xmlNodePtr cur;
		
			if (binding.logXMLInOut) {
				NSLog(@"ResponseBody:\n%@", [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease]);
			}
		
#if !TARGET_OS_IPHONE && (!defined(MAC_OS_X_VERSION_10_6) || MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_6)
	// Not yet defined in 10.5 libxml
	#define XML_PARSE_COMPACT 0
#endif
			doc = xmlReadMemory([responseData bytes], [responseData length], NULL, NULL, XML_PARSE_COMPACT | XML_PARSE_NOBLANKS);
		
			if (doc == NULL) {
				NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Errors while parsing returned XML" forKey:NSLocalizedDescriptionKey];
			
				response.error = [NSError errorWithDomain:@"LibreAccessService_1_2_0Soap11BindingResponseXML" code:1 userInfo:userInfo];
			} else {
				cur = xmlDocGetRootElement(doc);
				cur = cur->children;
			
				for( ; cur != NULL ; cur = cur->next) {
					if(cur->type == XML_ELEMENT_NODE) {
					
						if(xmlStrEqual(cur->name, (const xmlChar *) "Body")) {
							NSMutableArray *responseBodyParts = [NSMutableArray array];
						
							xmlNodePtr bodyNode;
							for(bodyNode=cur->children ; bodyNode != NULL ; bodyNode = bodyNode->next) {
								if(cur->type == XML_ELEMENT_NODE) {
									if(xmlStrEqual(bodyNode->name, (const xmlChar *) "ListContentMetadataResponse")) {
										tns1_ListContentMetadataResponse *bodyObject = [tns1_ListContentMetadataResponse deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
									if ((bodyNode->ns != nil && xmlStrEqual(bodyNode->ns->prefix, cur->ns->prefix)) && 
										xmlStrEqual(bodyNode->name, (const xmlChar *) "Fault")) {
										SOAPFault *bodyObject = [SOAPFault deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
								}
							}
						
							response.bodyParts = responseBodyParts;
						}
					}
				}
			
				xmlFreeDoc(doc);
			}
			if(delegate != nil && [delegate respondsToSelector:@selector(operation:completedWithResponse:)] == YES) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[delegate operation:self completedWithResponse:response];
				});
			}
		});
	}
}
@end
@implementation LibreAccessService_1_2_0Soap11Binding_GetVersion
@synthesize parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
parameters:(tns1_GetVersionRequest *)aParameters
{
	if((self = [super initWithBinding:aBinding delegate:responseDelegate])) {
		self.parameters = aParameters;
	}
	
	return self;
}
- (void)dealloc
{
	if(parameters != nil) [parameters release];
	
	[super dealloc];
}
- (void)main
{
	[response autorelease];
	response = [LibreAccessService_1_2_0Soap11BindingResponse new];
	
	LibreAccessService_1_2_0Soap11Binding_envelope *envelope = [LibreAccessService_1_2_0Soap11Binding_envelope sharedInstance];
	
	NSMutableDictionary *headerElements = nil;
	headerElements = [NSMutableDictionary dictionary];
	
	NSMutableDictionary *bodyElements = nil;
	NSMutableArray *bodyKeys = nil;
	bodyElements = [NSMutableDictionary dictionary];
	bodyKeys = [NSMutableArray array];
	id obj;
	obj = nil;
	if(parameters != nil) obj = parameters;
	if(obj != nil) {
		[bodyElements setObject:obj forKey:@"GetVersionRequest"];
		[bodyKeys addObject:@"GetVersionRequest"];
	}
	
	NSString *operationXMLString = [envelope serializedFormUsingHeaderElements:headerElements bodyElements:bodyElements bodyKeys:bodyKeys];
	
	[binding sendHTTPCallUsingBody:operationXMLString soapAction:@"http://webservices.libredigital.com/libreaccess/GetVersion" forOperation:self];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (responseData != nil && delegate != nil)
	{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			xmlDocPtr doc;
			xmlNodePtr cur;
		
			if (binding.logXMLInOut) {
				NSLog(@"ResponseBody:\n%@", [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease]);
			}
		
#if !TARGET_OS_IPHONE && (!defined(MAC_OS_X_VERSION_10_6) || MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_6)
	// Not yet defined in 10.5 libxml
	#define XML_PARSE_COMPACT 0
#endif
			doc = xmlReadMemory([responseData bytes], [responseData length], NULL, NULL, XML_PARSE_COMPACT | XML_PARSE_NOBLANKS);
		
			if (doc == NULL) {
				NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Errors while parsing returned XML" forKey:NSLocalizedDescriptionKey];
			
				response.error = [NSError errorWithDomain:@"LibreAccessService_1_2_0Soap11BindingResponseXML" code:1 userInfo:userInfo];
			} else {
				cur = xmlDocGetRootElement(doc);
				cur = cur->children;
			
				for( ; cur != NULL ; cur = cur->next) {
					if(cur->type == XML_ELEMENT_NODE) {
					
						if(xmlStrEqual(cur->name, (const xmlChar *) "Body")) {
							NSMutableArray *responseBodyParts = [NSMutableArray array];
						
							xmlNodePtr bodyNode;
							for(bodyNode=cur->children ; bodyNode != NULL ; bodyNode = bodyNode->next) {
								if(cur->type == XML_ELEMENT_NODE) {
									if(xmlStrEqual(bodyNode->name, (const xmlChar *) "GetVersionResponse")) {
										tns1_GetVersionResponse *bodyObject = [tns1_GetVersionResponse deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
									if ((bodyNode->ns != nil && xmlStrEqual(bodyNode->ns->prefix, cur->ns->prefix)) && 
										xmlStrEqual(bodyNode->name, (const xmlChar *) "Fault")) {
										SOAPFault *bodyObject = [SOAPFault deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
								}
							}
						
							response.bodyParts = responseBodyParts;
						}
					}
				}
			
				xmlFreeDoc(doc);
			}
			if(delegate != nil && [delegate respondsToSelector:@selector(operation:completedWithResponse:)] == YES) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[delegate operation:self completedWithResponse:response];
				});
			}
		});
	}
}
@end
@implementation LibreAccessService_1_2_0Soap11Binding_AssignBooksToAllUsers
@synthesize parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
parameters:(tns1_AssignBooksToAllUsersRequest *)aParameters
{
	if((self = [super initWithBinding:aBinding delegate:responseDelegate])) {
		self.parameters = aParameters;
	}
	
	return self;
}
- (void)dealloc
{
	if(parameters != nil) [parameters release];
	
	[super dealloc];
}
- (void)main
{
	[response autorelease];
	response = [LibreAccessService_1_2_0Soap11BindingResponse new];
	
	LibreAccessService_1_2_0Soap11Binding_envelope *envelope = [LibreAccessService_1_2_0Soap11Binding_envelope sharedInstance];
	
	NSMutableDictionary *headerElements = nil;
	headerElements = [NSMutableDictionary dictionary];
	
	NSMutableDictionary *bodyElements = nil;
	NSMutableArray *bodyKeys = nil;
	bodyElements = [NSMutableDictionary dictionary];
	bodyKeys = [NSMutableArray array];
	id obj;
	obj = nil;
	if(parameters != nil) obj = parameters;
	if(obj != nil) {
		[bodyElements setObject:obj forKey:@"AssignBooksToAllUsersRequest"];
		[bodyKeys addObject:@"AssignBooksToAllUsersRequest"];
	}
	
	NSString *operationXMLString = [envelope serializedFormUsingHeaderElements:headerElements bodyElements:bodyElements bodyKeys:bodyKeys];
	
	[binding sendHTTPCallUsingBody:operationXMLString soapAction:@"http://webservices.libredigital.com/libreaccess/AssignBooksToAllUsers" forOperation:self];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (responseData != nil && delegate != nil)
	{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			xmlDocPtr doc;
			xmlNodePtr cur;
		
			if (binding.logXMLInOut) {
				NSLog(@"ResponseBody:\n%@", [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease]);
			}
		
#if !TARGET_OS_IPHONE && (!defined(MAC_OS_X_VERSION_10_6) || MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_6)
	// Not yet defined in 10.5 libxml
	#define XML_PARSE_COMPACT 0
#endif
			doc = xmlReadMemory([responseData bytes], [responseData length], NULL, NULL, XML_PARSE_COMPACT | XML_PARSE_NOBLANKS);
		
			if (doc == NULL) {
				NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Errors while parsing returned XML" forKey:NSLocalizedDescriptionKey];
			
				response.error = [NSError errorWithDomain:@"LibreAccessService_1_2_0Soap11BindingResponseXML" code:1 userInfo:userInfo];
			} else {
				cur = xmlDocGetRootElement(doc);
				cur = cur->children;
			
				for( ; cur != NULL ; cur = cur->next) {
					if(cur->type == XML_ELEMENT_NODE) {
					
						if(xmlStrEqual(cur->name, (const xmlChar *) "Body")) {
							NSMutableArray *responseBodyParts = [NSMutableArray array];
						
							xmlNodePtr bodyNode;
							for(bodyNode=cur->children ; bodyNode != NULL ; bodyNode = bodyNode->next) {
								if(cur->type == XML_ELEMENT_NODE) {
									if(xmlStrEqual(bodyNode->name, (const xmlChar *) "AssignBooksToAllUsersResponse")) {
										tns1_AssignBooksToAllUsersResponse *bodyObject = [tns1_AssignBooksToAllUsersResponse deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
									if ((bodyNode->ns != nil && xmlStrEqual(bodyNode->ns->prefix, cur->ns->prefix)) && 
										xmlStrEqual(bodyNode->name, (const xmlChar *) "Fault")) {
										SOAPFault *bodyObject = [SOAPFault deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
								}
							}
						
							response.bodyParts = responseBodyParts;
						}
					}
				}
			
				xmlFreeDoc(doc);
			}
			if(delegate != nil && [delegate respondsToSelector:@selector(operation:completedWithResponse:)] == YES) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[delegate operation:self completedWithResponse:response];
				});
			}
		});
	}
}
@end
@implementation LibreAccessService_1_2_0Soap11Binding_DeregisterAllDevices
@synthesize parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
parameters:(tns1_DeregisterAllDevicesRequest *)aParameters
{
	if((self = [super initWithBinding:aBinding delegate:responseDelegate])) {
		self.parameters = aParameters;
	}
	
	return self;
}
- (void)dealloc
{
	if(parameters != nil) [parameters release];
	
	[super dealloc];
}
- (void)main
{
	[response autorelease];
	response = [LibreAccessService_1_2_0Soap11BindingResponse new];
	
	LibreAccessService_1_2_0Soap11Binding_envelope *envelope = [LibreAccessService_1_2_0Soap11Binding_envelope sharedInstance];
	
	NSMutableDictionary *headerElements = nil;
	headerElements = [NSMutableDictionary dictionary];
	
	NSMutableDictionary *bodyElements = nil;
	NSMutableArray *bodyKeys = nil;
	bodyElements = [NSMutableDictionary dictionary];
	bodyKeys = [NSMutableArray array];
	id obj;
	obj = nil;
	if(parameters != nil) obj = parameters;
	if(obj != nil) {
		[bodyElements setObject:obj forKey:@"DeregisterAllDevicesRequest"];
		[bodyKeys addObject:@"DeregisterAllDevicesRequest"];
	}
	
	NSString *operationXMLString = [envelope serializedFormUsingHeaderElements:headerElements bodyElements:bodyElements bodyKeys:bodyKeys];
	
	[binding sendHTTPCallUsingBody:operationXMLString soapAction:@"http://webservices.libredigital.com/libreaccess/DeregisterAllDevices" forOperation:self];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (responseData != nil && delegate != nil)
	{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			xmlDocPtr doc;
			xmlNodePtr cur;
		
			if (binding.logXMLInOut) {
				NSLog(@"ResponseBody:\n%@", [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease]);
			}
		
#if !TARGET_OS_IPHONE && (!defined(MAC_OS_X_VERSION_10_6) || MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_6)
	// Not yet defined in 10.5 libxml
	#define XML_PARSE_COMPACT 0
#endif
			doc = xmlReadMemory([responseData bytes], [responseData length], NULL, NULL, XML_PARSE_COMPACT | XML_PARSE_NOBLANKS);
		
			if (doc == NULL) {
				NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Errors while parsing returned XML" forKey:NSLocalizedDescriptionKey];
			
				response.error = [NSError errorWithDomain:@"LibreAccessService_1_2_0Soap11BindingResponseXML" code:1 userInfo:userInfo];
			} else {
				cur = xmlDocGetRootElement(doc);
				cur = cur->children;
			
				for( ; cur != NULL ; cur = cur->next) {
					if(cur->type == XML_ELEMENT_NODE) {
					
						if(xmlStrEqual(cur->name, (const xmlChar *) "Body")) {
							NSMutableArray *responseBodyParts = [NSMutableArray array];
						
							xmlNodePtr bodyNode;
							for(bodyNode=cur->children ; bodyNode != NULL ; bodyNode = bodyNode->next) {
								if(cur->type == XML_ELEMENT_NODE) {
									if(xmlStrEqual(bodyNode->name, (const xmlChar *) "DeregisterAllDevicesResponse")) {
										tns1_DeregisterAllDevicesResponse *bodyObject = [tns1_DeregisterAllDevicesResponse deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
									if ((bodyNode->ns != nil && xmlStrEqual(bodyNode->ns->prefix, cur->ns->prefix)) && 
										xmlStrEqual(bodyNode->name, (const xmlChar *) "Fault")) {
										SOAPFault *bodyObject = [SOAPFault deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
								}
							}
						
							response.bodyParts = responseBodyParts;
						}
					}
				}
			
				xmlFreeDoc(doc);
			}
			if(delegate != nil && [delegate respondsToSelector:@selector(operation:completedWithResponse:)] == YES) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[delegate operation:self completedWithResponse:response];
				});
			}
		});
	}
}
@end
@implementation LibreAccessService_1_2_0Soap11Binding_HealthCheck
@synthesize parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
parameters:(tns1_HealthCheckRequest *)aParameters
{
	if((self = [super initWithBinding:aBinding delegate:responseDelegate])) {
		self.parameters = aParameters;
	}
	
	return self;
}
- (void)dealloc
{
	if(parameters != nil) [parameters release];
	
	[super dealloc];
}
- (void)main
{
	[response autorelease];
	response = [LibreAccessService_1_2_0Soap11BindingResponse new];
	
	LibreAccessService_1_2_0Soap11Binding_envelope *envelope = [LibreAccessService_1_2_0Soap11Binding_envelope sharedInstance];
	
	NSMutableDictionary *headerElements = nil;
	headerElements = [NSMutableDictionary dictionary];
	
	NSMutableDictionary *bodyElements = nil;
	NSMutableArray *bodyKeys = nil;
	bodyElements = [NSMutableDictionary dictionary];
	bodyKeys = [NSMutableArray array];
	id obj;
	obj = nil;
	if(parameters != nil) obj = parameters;
	if(obj != nil) {
		[bodyElements setObject:obj forKey:@"HealthCheckRequest"];
		[bodyKeys addObject:@"HealthCheckRequest"];
	}
	
	NSString *operationXMLString = [envelope serializedFormUsingHeaderElements:headerElements bodyElements:bodyElements bodyKeys:bodyKeys];
	
	[binding sendHTTPCallUsingBody:operationXMLString soapAction:@"http://webservices.libredigital.com/libreaccess/HealthCheck" forOperation:self];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (responseData != nil && delegate != nil)
	{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			xmlDocPtr doc;
			xmlNodePtr cur;
		
			if (binding.logXMLInOut) {
				NSLog(@"ResponseBody:\n%@", [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease]);
			}
		
#if !TARGET_OS_IPHONE && (!defined(MAC_OS_X_VERSION_10_6) || MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_6)
	// Not yet defined in 10.5 libxml
	#define XML_PARSE_COMPACT 0
#endif
			doc = xmlReadMemory([responseData bytes], [responseData length], NULL, NULL, XML_PARSE_COMPACT | XML_PARSE_NOBLANKS);
		
			if (doc == NULL) {
				NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Errors while parsing returned XML" forKey:NSLocalizedDescriptionKey];
			
				response.error = [NSError errorWithDomain:@"LibreAccessService_1_2_0Soap11BindingResponseXML" code:1 userInfo:userInfo];
			} else {
				cur = xmlDocGetRootElement(doc);
				cur = cur->children;
			
				for( ; cur != NULL ; cur = cur->next) {
					if(cur->type == XML_ELEMENT_NODE) {
					
						if(xmlStrEqual(cur->name, (const xmlChar *) "Body")) {
							NSMutableArray *responseBodyParts = [NSMutableArray array];
						
							xmlNodePtr bodyNode;
							for(bodyNode=cur->children ; bodyNode != NULL ; bodyNode = bodyNode->next) {
								if(cur->type == XML_ELEMENT_NODE) {
									if(xmlStrEqual(bodyNode->name, (const xmlChar *) "HealthCheckResponse")) {
										tns1_HealthCheckResponse *bodyObject = [tns1_HealthCheckResponse deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
									if ((bodyNode->ns != nil && xmlStrEqual(bodyNode->ns->prefix, cur->ns->prefix)) && 
										xmlStrEqual(bodyNode->name, (const xmlChar *) "Fault")) {
										SOAPFault *bodyObject = [SOAPFault deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
								}
							}
						
							response.bodyParts = responseBodyParts;
						}
					}
				}
			
				xmlFreeDoc(doc);
			}
			if(delegate != nil && [delegate respondsToSelector:@selector(operation:completedWithResponse:)] == YES) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[delegate operation:self completedWithResponse:response];
				});
			}
		});
	}
}
@end
@implementation LibreAccessService_1_2_0Soap11Binding_ListReadingStatisticsDailyAggregateByTitle
@synthesize parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
parameters:(tns1_ListReadingStatisticsDailyAggregateByTitleRequest *)aParameters
{
	if((self = [super initWithBinding:aBinding delegate:responseDelegate])) {
		self.parameters = aParameters;
	}
	
	return self;
}
- (void)dealloc
{
	if(parameters != nil) [parameters release];
	
	[super dealloc];
}
- (void)main
{
	[response autorelease];
	response = [LibreAccessService_1_2_0Soap11BindingResponse new];
	
	LibreAccessService_1_2_0Soap11Binding_envelope *envelope = [LibreAccessService_1_2_0Soap11Binding_envelope sharedInstance];
	
	NSMutableDictionary *headerElements = nil;
	headerElements = [NSMutableDictionary dictionary];
	
	NSMutableDictionary *bodyElements = nil;
	NSMutableArray *bodyKeys = nil;
	bodyElements = [NSMutableDictionary dictionary];
	bodyKeys = [NSMutableArray array];
	id obj;
	obj = nil;
	if(parameters != nil) obj = parameters;
	if(obj != nil) {
		[bodyElements setObject:obj forKey:@"ListReadingStatisticsDailyAggregateByTitleRequest"];
		[bodyKeys addObject:@"ListReadingStatisticsDailyAggregateByTitleRequest"];
	}
	
	NSString *operationXMLString = [envelope serializedFormUsingHeaderElements:headerElements bodyElements:bodyElements bodyKeys:bodyKeys];
	
	[binding sendHTTPCallUsingBody:operationXMLString soapAction:@"http://webservices.libredigital.com/libreaccess/ListReadingStatisticsDailyAggregateByTitle" forOperation:self];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (responseData != nil && delegate != nil)
	{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			xmlDocPtr doc;
			xmlNodePtr cur;
		
			if (binding.logXMLInOut) {
				NSLog(@"ResponseBody:\n%@", [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease]);
			}
		
#if !TARGET_OS_IPHONE && (!defined(MAC_OS_X_VERSION_10_6) || MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_6)
	// Not yet defined in 10.5 libxml
	#define XML_PARSE_COMPACT 0
#endif
			doc = xmlReadMemory([responseData bytes], [responseData length], NULL, NULL, XML_PARSE_COMPACT | XML_PARSE_NOBLANKS);
		
			if (doc == NULL) {
				NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Errors while parsing returned XML" forKey:NSLocalizedDescriptionKey];
			
				response.error = [NSError errorWithDomain:@"LibreAccessService_1_2_0Soap11BindingResponseXML" code:1 userInfo:userInfo];
			} else {
				cur = xmlDocGetRootElement(doc);
				cur = cur->children;
			
				for( ; cur != NULL ; cur = cur->next) {
					if(cur->type == XML_ELEMENT_NODE) {
					
						if(xmlStrEqual(cur->name, (const xmlChar *) "Body")) {
							NSMutableArray *responseBodyParts = [NSMutableArray array];
						
							xmlNodePtr bodyNode;
							for(bodyNode=cur->children ; bodyNode != NULL ; bodyNode = bodyNode->next) {
								if(cur->type == XML_ELEMENT_NODE) {
									if(xmlStrEqual(bodyNode->name, (const xmlChar *) "ListReadingStatisticsDailyAggregateByTitleResponse")) {
										tns1_ListReadingStatisticsDailyAggregateByTitleResponse *bodyObject = [tns1_ListReadingStatisticsDailyAggregateByTitleResponse deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
									if ((bodyNode->ns != nil && xmlStrEqual(bodyNode->ns->prefix, cur->ns->prefix)) && 
										xmlStrEqual(bodyNode->name, (const xmlChar *) "Fault")) {
										SOAPFault *bodyObject = [SOAPFault deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
								}
							}
						
							response.bodyParts = responseBodyParts;
						}
					}
				}
			
				xmlFreeDoc(doc);
			}
			if(delegate != nil && [delegate respondsToSelector:@selector(operation:completedWithResponse:)] == YES) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[delegate operation:self completedWithResponse:response];
				});
			}
		});
	}
}
@end
@implementation LibreAccessService_1_2_0Soap11Binding_GetLastPageLocation
@synthesize parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
parameters:(tns1_GetLastPageLocationRequest *)aParameters
{
	if((self = [super initWithBinding:aBinding delegate:responseDelegate])) {
		self.parameters = aParameters;
	}
	
	return self;
}
- (void)dealloc
{
	if(parameters != nil) [parameters release];
	
	[super dealloc];
}
- (void)main
{
	[response autorelease];
	response = [LibreAccessService_1_2_0Soap11BindingResponse new];
	
	LibreAccessService_1_2_0Soap11Binding_envelope *envelope = [LibreAccessService_1_2_0Soap11Binding_envelope sharedInstance];
	
	NSMutableDictionary *headerElements = nil;
	headerElements = [NSMutableDictionary dictionary];
	
	NSMutableDictionary *bodyElements = nil;
	NSMutableArray *bodyKeys = nil;
	bodyElements = [NSMutableDictionary dictionary];
	bodyKeys = [NSMutableArray array];
	id obj;
	obj = nil;
	if(parameters != nil) obj = parameters;
	if(obj != nil) {
		[bodyElements setObject:obj forKey:@"GetLastPageLocationRequest"];
		[bodyKeys addObject:@"GetLastPageLocationRequest"];
	}
	
	NSString *operationXMLString = [envelope serializedFormUsingHeaderElements:headerElements bodyElements:bodyElements bodyKeys:bodyKeys];
	
	[binding sendHTTPCallUsingBody:operationXMLString soapAction:@"http://webservices.libredigital.com/libreaccess/GetLastPageLocation" forOperation:self];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (responseData != nil && delegate != nil)
	{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			xmlDocPtr doc;
			xmlNodePtr cur;
		
			if (binding.logXMLInOut) {
				NSLog(@"ResponseBody:\n%@", [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease]);
			}
		
#if !TARGET_OS_IPHONE && (!defined(MAC_OS_X_VERSION_10_6) || MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_6)
	// Not yet defined in 10.5 libxml
	#define XML_PARSE_COMPACT 0
#endif
			doc = xmlReadMemory([responseData bytes], [responseData length], NULL, NULL, XML_PARSE_COMPACT | XML_PARSE_NOBLANKS);
		
			if (doc == NULL) {
				NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Errors while parsing returned XML" forKey:NSLocalizedDescriptionKey];
			
				response.error = [NSError errorWithDomain:@"LibreAccessService_1_2_0Soap11BindingResponseXML" code:1 userInfo:userInfo];
			} else {
				cur = xmlDocGetRootElement(doc);
				cur = cur->children;
			
				for( ; cur != NULL ; cur = cur->next) {
					if(cur->type == XML_ELEMENT_NODE) {
					
						if(xmlStrEqual(cur->name, (const xmlChar *) "Body")) {
							NSMutableArray *responseBodyParts = [NSMutableArray array];
						
							xmlNodePtr bodyNode;
							for(bodyNode=cur->children ; bodyNode != NULL ; bodyNode = bodyNode->next) {
								if(cur->type == XML_ELEMENT_NODE) {
									if(xmlStrEqual(bodyNode->name, (const xmlChar *) "GetLastPageLocationResponse")) {
										tns1_GetLastPageLocationResponse *bodyObject = [tns1_GetLastPageLocationResponse deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
									if ((bodyNode->ns != nil && xmlStrEqual(bodyNode->ns->prefix, cur->ns->prefix)) && 
										xmlStrEqual(bodyNode->name, (const xmlChar *) "Fault")) {
										SOAPFault *bodyObject = [SOAPFault deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
								}
							}
						
							response.bodyParts = responseBodyParts;
						}
					}
				}
			
				xmlFreeDoc(doc);
			}
			if(delegate != nil && [delegate respondsToSelector:@selector(operation:completedWithResponse:)] == YES) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[delegate operation:self completedWithResponse:response];
				});
			}
		});
	}
}
@end
@implementation LibreAccessService_1_2_0Soap11Binding_ValidateScreenName
@synthesize parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
parameters:(tns1_ValidateScreenNameRequest *)aParameters
{
	if((self = [super initWithBinding:aBinding delegate:responseDelegate])) {
		self.parameters = aParameters;
	}
	
	return self;
}
- (void)dealloc
{
	if(parameters != nil) [parameters release];
	
	[super dealloc];
}
- (void)main
{
	[response autorelease];
	response = [LibreAccessService_1_2_0Soap11BindingResponse new];
	
	LibreAccessService_1_2_0Soap11Binding_envelope *envelope = [LibreAccessService_1_2_0Soap11Binding_envelope sharedInstance];
	
	NSMutableDictionary *headerElements = nil;
	headerElements = [NSMutableDictionary dictionary];
	
	NSMutableDictionary *bodyElements = nil;
	NSMutableArray *bodyKeys = nil;
	bodyElements = [NSMutableDictionary dictionary];
	bodyKeys = [NSMutableArray array];
	id obj;
	obj = nil;
	if(parameters != nil) obj = parameters;
	if(obj != nil) {
		[bodyElements setObject:obj forKey:@"ValidateScreenNameRequest"];
		[bodyKeys addObject:@"ValidateScreenNameRequest"];
	}
	
	NSString *operationXMLString = [envelope serializedFormUsingHeaderElements:headerElements bodyElements:bodyElements bodyKeys:bodyKeys];
	
	[binding sendHTTPCallUsingBody:operationXMLString soapAction:@"http://webservices.libredigital.com/libreaccess/ValidateScreenName" forOperation:self];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (responseData != nil && delegate != nil)
	{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			xmlDocPtr doc;
			xmlNodePtr cur;
		
			if (binding.logXMLInOut) {
				NSLog(@"ResponseBody:\n%@", [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease]);
			}
		
#if !TARGET_OS_IPHONE && (!defined(MAC_OS_X_VERSION_10_6) || MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_6)
	// Not yet defined in 10.5 libxml
	#define XML_PARSE_COMPACT 0
#endif
			doc = xmlReadMemory([responseData bytes], [responseData length], NULL, NULL, XML_PARSE_COMPACT | XML_PARSE_NOBLANKS);
		
			if (doc == NULL) {
				NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Errors while parsing returned XML" forKey:NSLocalizedDescriptionKey];
			
				response.error = [NSError errorWithDomain:@"LibreAccessService_1_2_0Soap11BindingResponseXML" code:1 userInfo:userInfo];
			} else {
				cur = xmlDocGetRootElement(doc);
				cur = cur->children;
			
				for( ; cur != NULL ; cur = cur->next) {
					if(cur->type == XML_ELEMENT_NODE) {
					
						if(xmlStrEqual(cur->name, (const xmlChar *) "Body")) {
							NSMutableArray *responseBodyParts = [NSMutableArray array];
						
							xmlNodePtr bodyNode;
							for(bodyNode=cur->children ; bodyNode != NULL ; bodyNode = bodyNode->next) {
								if(cur->type == XML_ELEMENT_NODE) {
									if(xmlStrEqual(bodyNode->name, (const xmlChar *) "ValidateScreenNameResponse")) {
										tns1_ValidateScreenNameResponse *bodyObject = [tns1_ValidateScreenNameResponse deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
									if ((bodyNode->ns != nil && xmlStrEqual(bodyNode->ns->prefix, cur->ns->prefix)) && 
										xmlStrEqual(bodyNode->name, (const xmlChar *) "Fault")) {
										SOAPFault *bodyObject = [SOAPFault deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
								}
							}
						
							response.bodyParts = responseBodyParts;
						}
					}
				}
			
				xmlFreeDoc(doc);
			}
			if(delegate != nil && [delegate respondsToSelector:@selector(operation:completedWithResponse:)] == YES) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[delegate operation:self completedWithResponse:response];
				});
			}
		});
	}
}
@end
@implementation LibreAccessService_1_2_0Soap11Binding_SaveReadingStatisticsDetailed
@synthesize parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
parameters:(tns1_SaveReadingStatisticsDetailedRequest *)aParameters
{
	if((self = [super initWithBinding:aBinding delegate:responseDelegate])) {
		self.parameters = aParameters;
	}
	
	return self;
}
- (void)dealloc
{
	if(parameters != nil) [parameters release];
	
	[super dealloc];
}
- (void)main
{
	[response autorelease];
	response = [LibreAccessService_1_2_0Soap11BindingResponse new];
	
	LibreAccessService_1_2_0Soap11Binding_envelope *envelope = [LibreAccessService_1_2_0Soap11Binding_envelope sharedInstance];
	
	NSMutableDictionary *headerElements = nil;
	headerElements = [NSMutableDictionary dictionary];
	
	NSMutableDictionary *bodyElements = nil;
	NSMutableArray *bodyKeys = nil;
	bodyElements = [NSMutableDictionary dictionary];
	bodyKeys = [NSMutableArray array];
	id obj;
	obj = nil;
	if(parameters != nil) obj = parameters;
	if(obj != nil) {
		[bodyElements setObject:obj forKey:@"SaveReadingStatisticsDetailedRequest"];
		[bodyKeys addObject:@"SaveReadingStatisticsDetailedRequest"];
	}
	
	NSString *operationXMLString = [envelope serializedFormUsingHeaderElements:headerElements bodyElements:bodyElements bodyKeys:bodyKeys];
	
	[binding sendHTTPCallUsingBody:operationXMLString soapAction:@"http://webservices.libredigital.com/libreaccess/SaveReadingStatisticsDetailed" forOperation:self];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (responseData != nil && delegate != nil)
	{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			xmlDocPtr doc;
			xmlNodePtr cur;
		
			if (binding.logXMLInOut) {
				NSLog(@"ResponseBody:\n%@", [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease]);
			}
		
#if !TARGET_OS_IPHONE && (!defined(MAC_OS_X_VERSION_10_6) || MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_6)
	// Not yet defined in 10.5 libxml
	#define XML_PARSE_COMPACT 0
#endif
			doc = xmlReadMemory([responseData bytes], [responseData length], NULL, NULL, XML_PARSE_COMPACT | XML_PARSE_NOBLANKS);
		
			if (doc == NULL) {
				NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Errors while parsing returned XML" forKey:NSLocalizedDescriptionKey];
			
				response.error = [NSError errorWithDomain:@"LibreAccessService_1_2_0Soap11BindingResponseXML" code:1 userInfo:userInfo];
			} else {
				cur = xmlDocGetRootElement(doc);
				cur = cur->children;
			
				for( ; cur != NULL ; cur = cur->next) {
					if(cur->type == XML_ELEMENT_NODE) {
					
						if(xmlStrEqual(cur->name, (const xmlChar *) "Body")) {
							NSMutableArray *responseBodyParts = [NSMutableArray array];
						
							xmlNodePtr bodyNode;
							for(bodyNode=cur->children ; bodyNode != NULL ; bodyNode = bodyNode->next) {
								if(cur->type == XML_ELEMENT_NODE) {
									if(xmlStrEqual(bodyNode->name, (const xmlChar *) "SaveReadingStatisticsDetailedResponse")) {
										tns1_SaveReadingStatisticsDetailedResponse *bodyObject = [tns1_SaveReadingStatisticsDetailedResponse deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
									if ((bodyNode->ns != nil && xmlStrEqual(bodyNode->ns->prefix, cur->ns->prefix)) && 
										xmlStrEqual(bodyNode->name, (const xmlChar *) "Fault")) {
										SOAPFault *bodyObject = [SOAPFault deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
								}
							}
						
							response.bodyParts = responseBodyParts;
						}
					}
				}
			
				xmlFreeDoc(doc);
			}
			if(delegate != nil && [delegate respondsToSelector:@selector(operation:completedWithResponse:)] == YES) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[delegate operation:self completedWithResponse:response];
				});
			}
		});
	}
}
@end
@implementation LibreAccessService_1_2_0Soap11Binding_SetAccountPasswordRequired
@synthesize parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
parameters:(tns1_SetAccountPasswordRequiredRequest *)aParameters
{
	if((self = [super initWithBinding:aBinding delegate:responseDelegate])) {
		self.parameters = aParameters;
	}
	
	return self;
}
- (void)dealloc
{
	if(parameters != nil) [parameters release];
	
	[super dealloc];
}
- (void)main
{
	[response autorelease];
	response = [LibreAccessService_1_2_0Soap11BindingResponse new];
	
	LibreAccessService_1_2_0Soap11Binding_envelope *envelope = [LibreAccessService_1_2_0Soap11Binding_envelope sharedInstance];
	
	NSMutableDictionary *headerElements = nil;
	headerElements = [NSMutableDictionary dictionary];
	
	NSMutableDictionary *bodyElements = nil;
	NSMutableArray *bodyKeys = nil;
	bodyElements = [NSMutableDictionary dictionary];
	bodyKeys = [NSMutableArray array];
	id obj;
	obj = nil;
	if(parameters != nil) obj = parameters;
	if(obj != nil) {
		[bodyElements setObject:obj forKey:@"SetAccountPasswordRequiredRequest"];
		[bodyKeys addObject:@"SetAccountPasswordRequiredRequest"];
	}
	
	NSString *operationXMLString = [envelope serializedFormUsingHeaderElements:headerElements bodyElements:bodyElements bodyKeys:bodyKeys];
	
	[binding sendHTTPCallUsingBody:operationXMLString soapAction:@"http://webservices.libredigital.com/libreaccess/SetAccountPasswordRequired" forOperation:self];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (responseData != nil && delegate != nil)
	{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			xmlDocPtr doc;
			xmlNodePtr cur;
		
			if (binding.logXMLInOut) {
				NSLog(@"ResponseBody:\n%@", [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease]);
			}
		
#if !TARGET_OS_IPHONE && (!defined(MAC_OS_X_VERSION_10_6) || MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_6)
	// Not yet defined in 10.5 libxml
	#define XML_PARSE_COMPACT 0
#endif
			doc = xmlReadMemory([responseData bytes], [responseData length], NULL, NULL, XML_PARSE_COMPACT | XML_PARSE_NOBLANKS);
		
			if (doc == NULL) {
				NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Errors while parsing returned XML" forKey:NSLocalizedDescriptionKey];
			
				response.error = [NSError errorWithDomain:@"LibreAccessService_1_2_0Soap11BindingResponseXML" code:1 userInfo:userInfo];
			} else {
				cur = xmlDocGetRootElement(doc);
				cur = cur->children;
			
				for( ; cur != NULL ; cur = cur->next) {
					if(cur->type == XML_ELEMENT_NODE) {
					
						if(xmlStrEqual(cur->name, (const xmlChar *) "Body")) {
							NSMutableArray *responseBodyParts = [NSMutableArray array];
						
							xmlNodePtr bodyNode;
							for(bodyNode=cur->children ; bodyNode != NULL ; bodyNode = bodyNode->next) {
								if(cur->type == XML_ELEMENT_NODE) {
									if(xmlStrEqual(bodyNode->name, (const xmlChar *) "SetAccountPasswordRequiredResponse")) {
										tns1_SetAccountPasswordRequiredResponse *bodyObject = [tns1_SetAccountPasswordRequiredResponse deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
									if ((bodyNode->ns != nil && xmlStrEqual(bodyNode->ns->prefix, cur->ns->prefix)) && 
										xmlStrEqual(bodyNode->name, (const xmlChar *) "Fault")) {
										SOAPFault *bodyObject = [SOAPFault deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
								}
							}
						
							response.bodyParts = responseBodyParts;
						}
					}
				}
			
				xmlFreeDoc(doc);
			}
			if(delegate != nil && [delegate respondsToSelector:@selector(operation:completedWithResponse:)] == YES) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[delegate operation:self completedWithResponse:response];
				});
			}
		});
	}
}
@end
@implementation LibreAccessService_1_2_0Soap11Binding_ListTopRatings
@synthesize parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
parameters:(tns1_ListTopRatingsRequest *)aParameters
{
	if((self = [super initWithBinding:aBinding delegate:responseDelegate])) {
		self.parameters = aParameters;
	}
	
	return self;
}
- (void)dealloc
{
	if(parameters != nil) [parameters release];
	
	[super dealloc];
}
- (void)main
{
	[response autorelease];
	response = [LibreAccessService_1_2_0Soap11BindingResponse new];
	
	LibreAccessService_1_2_0Soap11Binding_envelope *envelope = [LibreAccessService_1_2_0Soap11Binding_envelope sharedInstance];
	
	NSMutableDictionary *headerElements = nil;
	headerElements = [NSMutableDictionary dictionary];
	
	NSMutableDictionary *bodyElements = nil;
	NSMutableArray *bodyKeys = nil;
	bodyElements = [NSMutableDictionary dictionary];
	bodyKeys = [NSMutableArray array];
	id obj;
	obj = nil;
	if(parameters != nil) obj = parameters;
	if(obj != nil) {
		[bodyElements setObject:obj forKey:@"ListTopRatingsRequest"];
		[bodyKeys addObject:@"ListTopRatingsRequest"];
	}
	
	NSString *operationXMLString = [envelope serializedFormUsingHeaderElements:headerElements bodyElements:bodyElements bodyKeys:bodyKeys];
	
	[binding sendHTTPCallUsingBody:operationXMLString soapAction:@"http://webservices.libredigital.com/libreaccess/ListTopRatings" forOperation:self];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (responseData != nil && delegate != nil)
	{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			xmlDocPtr doc;
			xmlNodePtr cur;
		
			if (binding.logXMLInOut) {
				NSLog(@"ResponseBody:\n%@", [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease]);
			}
		
#if !TARGET_OS_IPHONE && (!defined(MAC_OS_X_VERSION_10_6) || MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_6)
	// Not yet defined in 10.5 libxml
	#define XML_PARSE_COMPACT 0
#endif
			doc = xmlReadMemory([responseData bytes], [responseData length], NULL, NULL, XML_PARSE_COMPACT | XML_PARSE_NOBLANKS);
		
			if (doc == NULL) {
				NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Errors while parsing returned XML" forKey:NSLocalizedDescriptionKey];
			
				response.error = [NSError errorWithDomain:@"LibreAccessService_1_2_0Soap11BindingResponseXML" code:1 userInfo:userInfo];
			} else {
				cur = xmlDocGetRootElement(doc);
				cur = cur->children;
			
				for( ; cur != NULL ; cur = cur->next) {
					if(cur->type == XML_ELEMENT_NODE) {
					
						if(xmlStrEqual(cur->name, (const xmlChar *) "Body")) {
							NSMutableArray *responseBodyParts = [NSMutableArray array];
						
							xmlNodePtr bodyNode;
							for(bodyNode=cur->children ; bodyNode != NULL ; bodyNode = bodyNode->next) {
								if(cur->type == XML_ELEMENT_NODE) {
									if(xmlStrEqual(bodyNode->name, (const xmlChar *) "ListTopRatingsResponse")) {
										tns1_ListTopRatingsResponse *bodyObject = [tns1_ListTopRatingsResponse deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
									if ((bodyNode->ns != nil && xmlStrEqual(bodyNode->ns->prefix, cur->ns->prefix)) && 
										xmlStrEqual(bodyNode->name, (const xmlChar *) "Fault")) {
										SOAPFault *bodyObject = [SOAPFault deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
								}
							}
						
							response.bodyParts = responseBodyParts;
						}
					}
				}
			
				xmlFreeDoc(doc);
			}
			if(delegate != nil && [delegate respondsToSelector:@selector(operation:completedWithResponse:)] == YES) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[delegate operation:self completedWithResponse:response];
				});
			}
		});
	}
}
@end
@implementation LibreAccessService_1_2_0Soap11Binding_SaveContentProfileAssignment
@synthesize parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
parameters:(tns1_SaveContentProfileAssignmentRequest *)aParameters
{
	if((self = [super initWithBinding:aBinding delegate:responseDelegate])) {
		self.parameters = aParameters;
	}
	
	return self;
}
- (void)dealloc
{
	if(parameters != nil) [parameters release];
	
	[super dealloc];
}
- (void)main
{
	[response autorelease];
	response = [LibreAccessService_1_2_0Soap11BindingResponse new];
	
	LibreAccessService_1_2_0Soap11Binding_envelope *envelope = [LibreAccessService_1_2_0Soap11Binding_envelope sharedInstance];
	
	NSMutableDictionary *headerElements = nil;
	headerElements = [NSMutableDictionary dictionary];
	
	NSMutableDictionary *bodyElements = nil;
	NSMutableArray *bodyKeys = nil;
	bodyElements = [NSMutableDictionary dictionary];
	bodyKeys = [NSMutableArray array];
	id obj;
	obj = nil;
	if(parameters != nil) obj = parameters;
	if(obj != nil) {
		[bodyElements setObject:obj forKey:@"SaveContentProfileAssignmentRequest"];
		[bodyKeys addObject:@"SaveContentProfileAssignmentRequest"];
	}
	
	NSString *operationXMLString = [envelope serializedFormUsingHeaderElements:headerElements bodyElements:bodyElements bodyKeys:bodyKeys];
	
	[binding sendHTTPCallUsingBody:operationXMLString soapAction:@"http://webservices.libredigital.com/libreaccess/SaveContentProfileAssignment" forOperation:self];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (responseData != nil && delegate != nil)
	{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			xmlDocPtr doc;
			xmlNodePtr cur;
		
			if (binding.logXMLInOut) {
				NSLog(@"ResponseBody:\n%@", [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease]);
			}
		
#if !TARGET_OS_IPHONE && (!defined(MAC_OS_X_VERSION_10_6) || MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_6)
	// Not yet defined in 10.5 libxml
	#define XML_PARSE_COMPACT 0
#endif
			doc = xmlReadMemory([responseData bytes], [responseData length], NULL, NULL, XML_PARSE_COMPACT | XML_PARSE_NOBLANKS);
		
			if (doc == NULL) {
				NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Errors while parsing returned XML" forKey:NSLocalizedDescriptionKey];
			
				response.error = [NSError errorWithDomain:@"LibreAccessService_1_2_0Soap11BindingResponseXML" code:1 userInfo:userInfo];
			} else {
				cur = xmlDocGetRootElement(doc);
				cur = cur->children;
			
				for( ; cur != NULL ; cur = cur->next) {
					if(cur->type == XML_ELEMENT_NODE) {
					
						if(xmlStrEqual(cur->name, (const xmlChar *) "Body")) {
							NSMutableArray *responseBodyParts = [NSMutableArray array];
						
							xmlNodePtr bodyNode;
							for(bodyNode=cur->children ; bodyNode != NULL ; bodyNode = bodyNode->next) {
								if(cur->type == XML_ELEMENT_NODE) {
									if(xmlStrEqual(bodyNode->name, (const xmlChar *) "SaveContentProfileAssignmentResponse")) {
										tns1_SaveContentProfileAssignmentResponse *bodyObject = [tns1_SaveContentProfileAssignmentResponse deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
									if ((bodyNode->ns != nil && xmlStrEqual(bodyNode->ns->prefix, cur->ns->prefix)) && 
										xmlStrEqual(bodyNode->name, (const xmlChar *) "Fault")) {
										SOAPFault *bodyObject = [SOAPFault deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
								}
							}
						
							response.bodyParts = responseBodyParts;
						}
					}
				}
			
				xmlFreeDoc(doc);
			}
			if(delegate != nil && [delegate respondsToSelector:@selector(operation:completedWithResponse:)] == YES) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[delegate operation:self completedWithResponse:response];
				});
			}
		});
	}
}
@end
@implementation LibreAccessService_1_2_0Soap11Binding_ListReadingStatisticsAggregateByTitle
@synthesize parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
parameters:(tns1_ListReadingStatisticsAggregateByTitleRequest *)aParameters
{
	if((self = [super initWithBinding:aBinding delegate:responseDelegate])) {
		self.parameters = aParameters;
	}
	
	return self;
}
- (void)dealloc
{
	if(parameters != nil) [parameters release];
	
	[super dealloc];
}
- (void)main
{
	[response autorelease];
	response = [LibreAccessService_1_2_0Soap11BindingResponse new];
	
	LibreAccessService_1_2_0Soap11Binding_envelope *envelope = [LibreAccessService_1_2_0Soap11Binding_envelope sharedInstance];
	
	NSMutableDictionary *headerElements = nil;
	headerElements = [NSMutableDictionary dictionary];
	
	NSMutableDictionary *bodyElements = nil;
	NSMutableArray *bodyKeys = nil;
	bodyElements = [NSMutableDictionary dictionary];
	bodyKeys = [NSMutableArray array];
	id obj;
	obj = nil;
	if(parameters != nil) obj = parameters;
	if(obj != nil) {
		[bodyElements setObject:obj forKey:@"ListReadingStatisticsAggregateByTitleRequest"];
		[bodyKeys addObject:@"ListReadingStatisticsAggregateByTitleRequest"];
	}
	
	NSString *operationXMLString = [envelope serializedFormUsingHeaderElements:headerElements bodyElements:bodyElements bodyKeys:bodyKeys];
	
	[binding sendHTTPCallUsingBody:operationXMLString soapAction:@"http://webservices.libredigital.com/libreaccess/ListReadingStatisticsAggregateByTitle" forOperation:self];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (responseData != nil && delegate != nil)
	{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			xmlDocPtr doc;
			xmlNodePtr cur;
		
			if (binding.logXMLInOut) {
				NSLog(@"ResponseBody:\n%@", [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease]);
			}
		
#if !TARGET_OS_IPHONE && (!defined(MAC_OS_X_VERSION_10_6) || MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_6)
	// Not yet defined in 10.5 libxml
	#define XML_PARSE_COMPACT 0
#endif
			doc = xmlReadMemory([responseData bytes], [responseData length], NULL, NULL, XML_PARSE_COMPACT | XML_PARSE_NOBLANKS);
		
			if (doc == NULL) {
				NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Errors while parsing returned XML" forKey:NSLocalizedDescriptionKey];
			
				response.error = [NSError errorWithDomain:@"LibreAccessService_1_2_0Soap11BindingResponseXML" code:1 userInfo:userInfo];
			} else {
				cur = xmlDocGetRootElement(doc);
				cur = cur->children;
			
				for( ; cur != NULL ; cur = cur->next) {
					if(cur->type == XML_ELEMENT_NODE) {
					
						if(xmlStrEqual(cur->name, (const xmlChar *) "Body")) {
							NSMutableArray *responseBodyParts = [NSMutableArray array];
						
							xmlNodePtr bodyNode;
							for(bodyNode=cur->children ; bodyNode != NULL ; bodyNode = bodyNode->next) {
								if(cur->type == XML_ELEMENT_NODE) {
									if(xmlStrEqual(bodyNode->name, (const xmlChar *) "ListReadingStatisticsAggregateByTitleResponse")) {
										tns1_ListReadingStatisticsAggregateByTitleResponse *bodyObject = [tns1_ListReadingStatisticsAggregateByTitleResponse deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
									if ((bodyNode->ns != nil && xmlStrEqual(bodyNode->ns->prefix, cur->ns->prefix)) && 
										xmlStrEqual(bodyNode->name, (const xmlChar *) "Fault")) {
										SOAPFault *bodyObject = [SOAPFault deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
								}
							}
						
							response.bodyParts = responseBodyParts;
						}
					}
				}
			
				xmlFreeDoc(doc);
			}
			if(delegate != nil && [delegate respondsToSelector:@selector(operation:completedWithResponse:)] == YES) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[delegate operation:self completedWithResponse:response];
				});
			}
		});
	}
}
@end
@implementation LibreAccessService_1_2_0Soap11Binding_GetKeyId
@synthesize parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
parameters:(tns1_GetKeyIdRequest *)aParameters
{
	if((self = [super initWithBinding:aBinding delegate:responseDelegate])) {
		self.parameters = aParameters;
	}
	
	return self;
}
- (void)dealloc
{
	if(parameters != nil) [parameters release];
	
	[super dealloc];
}
- (void)main
{
	[response autorelease];
	response = [LibreAccessService_1_2_0Soap11BindingResponse new];
	
	LibreAccessService_1_2_0Soap11Binding_envelope *envelope = [LibreAccessService_1_2_0Soap11Binding_envelope sharedInstance];
	
	NSMutableDictionary *headerElements = nil;
	headerElements = [NSMutableDictionary dictionary];
	
	NSMutableDictionary *bodyElements = nil;
	NSMutableArray *bodyKeys = nil;
	bodyElements = [NSMutableDictionary dictionary];
	bodyKeys = [NSMutableArray array];
	id obj;
	obj = nil;
	if(parameters != nil) obj = parameters;
	if(obj != nil) {
		[bodyElements setObject:obj forKey:@"GetKeyIdRequest"];
		[bodyKeys addObject:@"GetKeyIdRequest"];
	}
	
	NSString *operationXMLString = [envelope serializedFormUsingHeaderElements:headerElements bodyElements:bodyElements bodyKeys:bodyKeys];
	
	[binding sendHTTPCallUsingBody:operationXMLString soapAction:@"http://webservices.libredigital.com/libreaccess/GetKeyId" forOperation:self];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (responseData != nil && delegate != nil)
	{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			xmlDocPtr doc;
			xmlNodePtr cur;
		
			if (binding.logXMLInOut) {
				NSLog(@"ResponseBody:\n%@", [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease]);
			}
		
#if !TARGET_OS_IPHONE && (!defined(MAC_OS_X_VERSION_10_6) || MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_6)
	// Not yet defined in 10.5 libxml
	#define XML_PARSE_COMPACT 0
#endif
			doc = xmlReadMemory([responseData bytes], [responseData length], NULL, NULL, XML_PARSE_COMPACT | XML_PARSE_NOBLANKS);
		
			if (doc == NULL) {
				NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Errors while parsing returned XML" forKey:NSLocalizedDescriptionKey];
			
				response.error = [NSError errorWithDomain:@"LibreAccessService_1_2_0Soap11BindingResponseXML" code:1 userInfo:userInfo];
			} else {
				cur = xmlDocGetRootElement(doc);
				cur = cur->children;
			
				for( ; cur != NULL ; cur = cur->next) {
					if(cur->type == XML_ELEMENT_NODE) {
					
						if(xmlStrEqual(cur->name, (const xmlChar *) "Body")) {
							NSMutableArray *responseBodyParts = [NSMutableArray array];
						
							xmlNodePtr bodyNode;
							for(bodyNode=cur->children ; bodyNode != NULL ; bodyNode = bodyNode->next) {
								if(cur->type == XML_ELEMENT_NODE) {
									if(xmlStrEqual(bodyNode->name, (const xmlChar *) "GetKeyIdResponse")) {
										tns1_GetKeyIdResponse *bodyObject = [tns1_GetKeyIdResponse deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
									if ((bodyNode->ns != nil && xmlStrEqual(bodyNode->ns->prefix, cur->ns->prefix)) && 
										xmlStrEqual(bodyNode->name, (const xmlChar *) "Fault")) {
										SOAPFault *bodyObject = [SOAPFault deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
								}
							}
						
							response.bodyParts = responseBodyParts;
						}
					}
				}
			
				xmlFreeDoc(doc);
			}
			if(delegate != nil && [delegate respondsToSelector:@selector(operation:completedWithResponse:)] == YES) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[delegate operation:self completedWithResponse:response];
				});
			}
		});
	}
}
@end
@implementation LibreAccessService_1_2_0Soap11Binding_ListReadingStatisticsAggregate
@synthesize parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
parameters:(tns1_ListReadingStatisticsAggregateRequest *)aParameters
{
	if((self = [super initWithBinding:aBinding delegate:responseDelegate])) {
		self.parameters = aParameters;
	}
	
	return self;
}
- (void)dealloc
{
	if(parameters != nil) [parameters release];
	
	[super dealloc];
}
- (void)main
{
	[response autorelease];
	response = [LibreAccessService_1_2_0Soap11BindingResponse new];
	
	LibreAccessService_1_2_0Soap11Binding_envelope *envelope = [LibreAccessService_1_2_0Soap11Binding_envelope sharedInstance];
	
	NSMutableDictionary *headerElements = nil;
	headerElements = [NSMutableDictionary dictionary];
	
	NSMutableDictionary *bodyElements = nil;
	NSMutableArray *bodyKeys = nil;
	bodyElements = [NSMutableDictionary dictionary];
	bodyKeys = [NSMutableArray array];
	id obj;
	obj = nil;
	if(parameters != nil) obj = parameters;
	if(obj != nil) {
		[bodyElements setObject:obj forKey:@"ListReadingStatisticsAggregateRequest"];
		[bodyKeys addObject:@"ListReadingStatisticsAggregateRequest"];
	}
	
	NSString *operationXMLString = [envelope serializedFormUsingHeaderElements:headerElements bodyElements:bodyElements bodyKeys:bodyKeys];
	
	[binding sendHTTPCallUsingBody:operationXMLString soapAction:@"http://webservices.libredigital.com/libreaccess/ListReadingStatisticsAggregate" forOperation:self];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (responseData != nil && delegate != nil)
	{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			xmlDocPtr doc;
			xmlNodePtr cur;
		
			if (binding.logXMLInOut) {
				NSLog(@"ResponseBody:\n%@", [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease]);
			}
		
#if !TARGET_OS_IPHONE && (!defined(MAC_OS_X_VERSION_10_6) || MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_6)
	// Not yet defined in 10.5 libxml
	#define XML_PARSE_COMPACT 0
#endif
			doc = xmlReadMemory([responseData bytes], [responseData length], NULL, NULL, XML_PARSE_COMPACT | XML_PARSE_NOBLANKS);
		
			if (doc == NULL) {
				NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Errors while parsing returned XML" forKey:NSLocalizedDescriptionKey];
			
				response.error = [NSError errorWithDomain:@"LibreAccessService_1_2_0Soap11BindingResponseXML" code:1 userInfo:userInfo];
			} else {
				cur = xmlDocGetRootElement(doc);
				cur = cur->children;
			
				for( ; cur != NULL ; cur = cur->next) {
					if(cur->type == XML_ELEMENT_NODE) {
					
						if(xmlStrEqual(cur->name, (const xmlChar *) "Body")) {
							NSMutableArray *responseBodyParts = [NSMutableArray array];
						
							xmlNodePtr bodyNode;
							for(bodyNode=cur->children ; bodyNode != NULL ; bodyNode = bodyNode->next) {
								if(cur->type == XML_ELEMENT_NODE) {
									if(xmlStrEqual(bodyNode->name, (const xmlChar *) "ListReadingStatisticsAggregateResponse")) {
										tns1_ListReadingStatisticsAggregateResponse *bodyObject = [tns1_ListReadingStatisticsAggregateResponse deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
									if ((bodyNode->ns != nil && xmlStrEqual(bodyNode->ns->prefix, cur->ns->prefix)) && 
										xmlStrEqual(bodyNode->name, (const xmlChar *) "Fault")) {
										SOAPFault *bodyObject = [SOAPFault deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
								}
							}
						
							response.bodyParts = responseBodyParts;
						}
					}
				}
			
				xmlFreeDoc(doc);
			}
			if(delegate != nil && [delegate respondsToSelector:@selector(operation:completedWithResponse:)] == YES) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[delegate operation:self completedWithResponse:response];
				});
			}
		});
	}
}
@end
@implementation LibreAccessService_1_2_0Soap11Binding_ListLastNWords
@synthesize parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
parameters:(tns1_ListLastNWordsRequest *)aParameters
{
	if((self = [super initWithBinding:aBinding delegate:responseDelegate])) {
		self.parameters = aParameters;
	}
	
	return self;
}
- (void)dealloc
{
	if(parameters != nil) [parameters release];
	
	[super dealloc];
}
- (void)main
{
	[response autorelease];
	response = [LibreAccessService_1_2_0Soap11BindingResponse new];
	
	LibreAccessService_1_2_0Soap11Binding_envelope *envelope = [LibreAccessService_1_2_0Soap11Binding_envelope sharedInstance];
	
	NSMutableDictionary *headerElements = nil;
	headerElements = [NSMutableDictionary dictionary];
	
	NSMutableDictionary *bodyElements = nil;
	NSMutableArray *bodyKeys = nil;
	bodyElements = [NSMutableDictionary dictionary];
	bodyKeys = [NSMutableArray array];
	id obj;
	obj = nil;
	if(parameters != nil) obj = parameters;
	if(obj != nil) {
		[bodyElements setObject:obj forKey:@"ListLastNWordsRequest"];
		[bodyKeys addObject:@"ListLastNWordsRequest"];
	}
	
	NSString *operationXMLString = [envelope serializedFormUsingHeaderElements:headerElements bodyElements:bodyElements bodyKeys:bodyKeys];
	
	[binding sendHTTPCallUsingBody:operationXMLString soapAction:@"http://webservices.libredigital.com/libreaccess/ListLastNWords" forOperation:self];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (responseData != nil && delegate != nil)
	{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			xmlDocPtr doc;
			xmlNodePtr cur;
		
			if (binding.logXMLInOut) {
				NSLog(@"ResponseBody:\n%@", [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease]);
			}
		
#if !TARGET_OS_IPHONE && (!defined(MAC_OS_X_VERSION_10_6) || MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_6)
	// Not yet defined in 10.5 libxml
	#define XML_PARSE_COMPACT 0
#endif
			doc = xmlReadMemory([responseData bytes], [responseData length], NULL, NULL, XML_PARSE_COMPACT | XML_PARSE_NOBLANKS);
		
			if (doc == NULL) {
				NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Errors while parsing returned XML" forKey:NSLocalizedDescriptionKey];
			
				response.error = [NSError errorWithDomain:@"LibreAccessService_1_2_0Soap11BindingResponseXML" code:1 userInfo:userInfo];
			} else {
				cur = xmlDocGetRootElement(doc);
				cur = cur->children;
			
				for( ; cur != NULL ; cur = cur->next) {
					if(cur->type == XML_ELEMENT_NODE) {
					
						if(xmlStrEqual(cur->name, (const xmlChar *) "Body")) {
							NSMutableArray *responseBodyParts = [NSMutableArray array];
						
							xmlNodePtr bodyNode;
							for(bodyNode=cur->children ; bodyNode != NULL ; bodyNode = bodyNode->next) {
								if(cur->type == XML_ELEMENT_NODE) {
									if(xmlStrEqual(bodyNode->name, (const xmlChar *) "ListLastNWordsResponse")) {
										tns1_ListLastNWordsResponse *bodyObject = [tns1_ListLastNWordsResponse deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
									if ((bodyNode->ns != nil && xmlStrEqual(bodyNode->ns->prefix, cur->ns->prefix)) && 
										xmlStrEqual(bodyNode->name, (const xmlChar *) "Fault")) {
										SOAPFault *bodyObject = [SOAPFault deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
								}
							}
						
							response.bodyParts = responseBodyParts;
						}
					}
				}
			
				xmlFreeDoc(doc);
			}
			if(delegate != nil && [delegate respondsToSelector:@selector(operation:completedWithResponse:)] == YES) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[delegate operation:self completedWithResponse:response];
				});
			}
		});
	}
}
@end
@implementation LibreAccessService_1_2_0Soap11Binding_IsEntitledToLicense
@synthesize parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
parameters:(tns1_EntitledToLicenseRequest *)aParameters
{
	if((self = [super initWithBinding:aBinding delegate:responseDelegate])) {
		self.parameters = aParameters;
	}
	
	return self;
}
- (void)dealloc
{
	if(parameters != nil) [parameters release];
	
	[super dealloc];
}
- (void)main
{
	[response autorelease];
	response = [LibreAccessService_1_2_0Soap11BindingResponse new];
	
	LibreAccessService_1_2_0Soap11Binding_envelope *envelope = [LibreAccessService_1_2_0Soap11Binding_envelope sharedInstance];
	
	NSMutableDictionary *headerElements = nil;
	headerElements = [NSMutableDictionary dictionary];
	
	NSMutableDictionary *bodyElements = nil;
	NSMutableArray *bodyKeys = nil;
	bodyElements = [NSMutableDictionary dictionary];
	bodyKeys = [NSMutableArray array];
	id obj;
	obj = nil;
	if(parameters != nil) obj = parameters;
	if(obj != nil) {
		[bodyElements setObject:obj forKey:@"EntitledToLicenseRequest"];
		[bodyKeys addObject:@"EntitledToLicenseRequest"];
	}
	
	NSString *operationXMLString = [envelope serializedFormUsingHeaderElements:headerElements bodyElements:bodyElements bodyKeys:bodyKeys];
	
	[binding sendHTTPCallUsingBody:operationXMLString soapAction:@"http://webservices.libredigital.com/libreaccess/IsEntitledToLicense" forOperation:self];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (responseData != nil && delegate != nil)
	{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			xmlDocPtr doc;
			xmlNodePtr cur;
		
			if (binding.logXMLInOut) {
				NSLog(@"ResponseBody:\n%@", [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease]);
			}
		
#if !TARGET_OS_IPHONE && (!defined(MAC_OS_X_VERSION_10_6) || MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_6)
	// Not yet defined in 10.5 libxml
	#define XML_PARSE_COMPACT 0
#endif
			doc = xmlReadMemory([responseData bytes], [responseData length], NULL, NULL, XML_PARSE_COMPACT | XML_PARSE_NOBLANKS);
		
			if (doc == NULL) {
				NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Errors while parsing returned XML" forKey:NSLocalizedDescriptionKey];
			
				response.error = [NSError errorWithDomain:@"LibreAccessService_1_2_0Soap11BindingResponseXML" code:1 userInfo:userInfo];
			} else {
				cur = xmlDocGetRootElement(doc);
				cur = cur->children;
			
				for( ; cur != NULL ; cur = cur->next) {
					if(cur->type == XML_ELEMENT_NODE) {
					
						if(xmlStrEqual(cur->name, (const xmlChar *) "Body")) {
							NSMutableArray *responseBodyParts = [NSMutableArray array];
						
							xmlNodePtr bodyNode;
							for(bodyNode=cur->children ; bodyNode != NULL ; bodyNode = bodyNode->next) {
								if(cur->type == XML_ELEMENT_NODE) {
									if(xmlStrEqual(bodyNode->name, (const xmlChar *) "IsEntitledToLicenseResponse")) {
										tns1_IsEntitledToLicenseResponse *bodyObject = [tns1_IsEntitledToLicenseResponse deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
									if ((bodyNode->ns != nil && xmlStrEqual(bodyNode->ns->prefix, cur->ns->prefix)) && 
										xmlStrEqual(bodyNode->name, (const xmlChar *) "Fault")) {
										SOAPFault *bodyObject = [SOAPFault deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
								}
							}
						
							response.bodyParts = responseBodyParts;
						}
					}
				}
			
				xmlFreeDoc(doc);
			}
			if(delegate != nil && [delegate respondsToSelector:@selector(operation:completedWithResponse:)] == YES) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[delegate operation:self completedWithResponse:response];
				});
			}
		});
	}
}
@end
@implementation LibreAccessService_1_2_0Soap11Binding_RemoveOrder
@synthesize parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
parameters:(tns1_RemoveOrderRequest *)aParameters
{
	if((self = [super initWithBinding:aBinding delegate:responseDelegate])) {
		self.parameters = aParameters;
	}
	
	return self;
}
- (void)dealloc
{
	if(parameters != nil) [parameters release];
	
	[super dealloc];
}
- (void)main
{
	[response autorelease];
	response = [LibreAccessService_1_2_0Soap11BindingResponse new];
	
	LibreAccessService_1_2_0Soap11Binding_envelope *envelope = [LibreAccessService_1_2_0Soap11Binding_envelope sharedInstance];
	
	NSMutableDictionary *headerElements = nil;
	headerElements = [NSMutableDictionary dictionary];
	
	NSMutableDictionary *bodyElements = nil;
	NSMutableArray *bodyKeys = nil;
	bodyElements = [NSMutableDictionary dictionary];
	bodyKeys = [NSMutableArray array];
	id obj;
	obj = nil;
	if(parameters != nil) obj = parameters;
	if(obj != nil) {
		[bodyElements setObject:obj forKey:@"RemoveOrderRequest"];
		[bodyKeys addObject:@"RemoveOrderRequest"];
	}
	
	NSString *operationXMLString = [envelope serializedFormUsingHeaderElements:headerElements bodyElements:bodyElements bodyKeys:bodyKeys];
	
	[binding sendHTTPCallUsingBody:operationXMLString soapAction:@"http://webservices.libredigital.com/libreaccess/RemoveOrder" forOperation:self];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (responseData != nil && delegate != nil)
	{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			xmlDocPtr doc;
			xmlNodePtr cur;
		
			if (binding.logXMLInOut) {
				NSLog(@"ResponseBody:\n%@", [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease]);
			}
		
#if !TARGET_OS_IPHONE && (!defined(MAC_OS_X_VERSION_10_6) || MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_6)
	// Not yet defined in 10.5 libxml
	#define XML_PARSE_COMPACT 0
#endif
			doc = xmlReadMemory([responseData bytes], [responseData length], NULL, NULL, XML_PARSE_COMPACT | XML_PARSE_NOBLANKS);
		
			if (doc == NULL) {
				NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Errors while parsing returned XML" forKey:NSLocalizedDescriptionKey];
			
				response.error = [NSError errorWithDomain:@"LibreAccessService_1_2_0Soap11BindingResponseXML" code:1 userInfo:userInfo];
			} else {
				cur = xmlDocGetRootElement(doc);
				cur = cur->children;
			
				for( ; cur != NULL ; cur = cur->next) {
					if(cur->type == XML_ELEMENT_NODE) {
					
						if(xmlStrEqual(cur->name, (const xmlChar *) "Body")) {
							NSMutableArray *responseBodyParts = [NSMutableArray array];
						
							xmlNodePtr bodyNode;
							for(bodyNode=cur->children ; bodyNode != NULL ; bodyNode = bodyNode->next) {
								if(cur->type == XML_ELEMENT_NODE) {
									if(xmlStrEqual(bodyNode->name, (const xmlChar *) "RemoveOrderResponse")) {
										tns1_RemoveOrderResponse *bodyObject = [tns1_RemoveOrderResponse deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
									if ((bodyNode->ns != nil && xmlStrEqual(bodyNode->ns->prefix, cur->ns->prefix)) && 
										xmlStrEqual(bodyNode->name, (const xmlChar *) "Fault")) {
										SOAPFault *bodyObject = [SOAPFault deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
								}
							}
						
							response.bodyParts = responseBodyParts;
						}
					}
				}
			
				xmlFreeDoc(doc);
			}
			if(delegate != nil && [delegate respondsToSelector:@selector(operation:completedWithResponse:)] == YES) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[delegate operation:self completedWithResponse:response];
				});
			}
		});
	}
}
@end
@implementation LibreAccessService_1_2_0Soap11Binding_ListFavoriteTypes
@synthesize parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
parameters:(tns1_ListFavoriteTypesRequest *)aParameters
{
	if((self = [super initWithBinding:aBinding delegate:responseDelegate])) {
		self.parameters = aParameters;
	}
	
	return self;
}
- (void)dealloc
{
	if(parameters != nil) [parameters release];
	
	[super dealloc];
}
- (void)main
{
	[response autorelease];
	response = [LibreAccessService_1_2_0Soap11BindingResponse new];
	
	LibreAccessService_1_2_0Soap11Binding_envelope *envelope = [LibreAccessService_1_2_0Soap11Binding_envelope sharedInstance];
	
	NSMutableDictionary *headerElements = nil;
	headerElements = [NSMutableDictionary dictionary];
	
	NSMutableDictionary *bodyElements = nil;
	NSMutableArray *bodyKeys = nil;
	bodyElements = [NSMutableDictionary dictionary];
	bodyKeys = [NSMutableArray array];
	id obj;
	obj = nil;
	if(parameters != nil) obj = parameters;
	if(obj != nil) {
		[bodyElements setObject:obj forKey:@"ListFavoriteTypesRequest"];
		[bodyKeys addObject:@"ListFavoriteTypesRequest"];
	}
	
	NSString *operationXMLString = [envelope serializedFormUsingHeaderElements:headerElements bodyElements:bodyElements bodyKeys:bodyKeys];
	
	[binding sendHTTPCallUsingBody:operationXMLString soapAction:@"http://webservices.libredigital.com/libreaccess/ListFavoriteTypes" forOperation:self];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (responseData != nil && delegate != nil)
	{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			xmlDocPtr doc;
			xmlNodePtr cur;
		
			if (binding.logXMLInOut) {
				NSLog(@"ResponseBody:\n%@", [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease]);
			}
		
#if !TARGET_OS_IPHONE && (!defined(MAC_OS_X_VERSION_10_6) || MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_6)
	// Not yet defined in 10.5 libxml
	#define XML_PARSE_COMPACT 0
#endif
			doc = xmlReadMemory([responseData bytes], [responseData length], NULL, NULL, XML_PARSE_COMPACT | XML_PARSE_NOBLANKS);
		
			if (doc == NULL) {
				NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Errors while parsing returned XML" forKey:NSLocalizedDescriptionKey];
			
				response.error = [NSError errorWithDomain:@"LibreAccessService_1_2_0Soap11BindingResponseXML" code:1 userInfo:userInfo];
			} else {
				cur = xmlDocGetRootElement(doc);
				cur = cur->children;
			
				for( ; cur != NULL ; cur = cur->next) {
					if(cur->type == XML_ELEMENT_NODE) {
					
						if(xmlStrEqual(cur->name, (const xmlChar *) "Body")) {
							NSMutableArray *responseBodyParts = [NSMutableArray array];
						
							xmlNodePtr bodyNode;
							for(bodyNode=cur->children ; bodyNode != NULL ; bodyNode = bodyNode->next) {
								if(cur->type == XML_ELEMENT_NODE) {
									if(xmlStrEqual(bodyNode->name, (const xmlChar *) "ListFavoriteTypesResponse")) {
										tns1_ListFavoriteTypesResponse *bodyObject = [tns1_ListFavoriteTypesResponse deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
									if ((bodyNode->ns != nil && xmlStrEqual(bodyNode->ns->prefix, cur->ns->prefix)) && 
										xmlStrEqual(bodyNode->name, (const xmlChar *) "Fault")) {
										SOAPFault *bodyObject = [SOAPFault deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
								}
							}
						
							response.bodyParts = responseBodyParts;
						}
					}
				}
			
				xmlFreeDoc(doc);
			}
			if(delegate != nil && [delegate respondsToSelector:@selector(operation:completedWithResponse:)] == YES) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[delegate operation:self completedWithResponse:response];
				});
			}
		});
	}
}
@end
@implementation LibreAccessService_1_2_0Soap11Binding_ListUserContent
@synthesize body;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
body:(tns1_ListUserContent *)aBody
{
	if((self = [super initWithBinding:aBinding delegate:responseDelegate])) {
		self.body = aBody;
	}
	
	return self;
}
- (void)dealloc
{
	if(body != nil) [body release];
	
	[super dealloc];
}
- (void)main
{
	[response autorelease];
	response = [LibreAccessService_1_2_0Soap11BindingResponse new];
	
	LibreAccessService_1_2_0Soap11Binding_envelope *envelope = [LibreAccessService_1_2_0Soap11Binding_envelope sharedInstance];
	
	NSMutableDictionary *headerElements = nil;
	headerElements = [NSMutableDictionary dictionary];
	
	NSMutableDictionary *bodyElements = nil;
	NSMutableArray *bodyKeys = nil;
	bodyElements = [NSMutableDictionary dictionary];
	bodyKeys = [NSMutableArray array];
	id obj;
	obj = nil;
	if(body != nil) obj = body;
	if(obj != nil) {
		[bodyElements setObject:obj forKey:@"ListUserContent"];
		[bodyKeys addObject:@"ListUserContent"];
	}
	
	NSString *operationXMLString = [envelope serializedFormUsingHeaderElements:headerElements bodyElements:bodyElements bodyKeys:bodyKeys];
	
	[binding sendHTTPCallUsingBody:operationXMLString soapAction:@"http://webservices.libredigital.com/libreaccess/ListUserContent" forOperation:self];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (responseData != nil && delegate != nil)
	{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			xmlDocPtr doc;
			xmlNodePtr cur;
		
			if (binding.logXMLInOut) {
				NSLog(@"ResponseBody:\n%@", [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease]);
			}
		
#if !TARGET_OS_IPHONE && (!defined(MAC_OS_X_VERSION_10_6) || MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_6)
	// Not yet defined in 10.5 libxml
	#define XML_PARSE_COMPACT 0
#endif
			doc = xmlReadMemory([responseData bytes], [responseData length], NULL, NULL, XML_PARSE_COMPACT | XML_PARSE_NOBLANKS);
		
			if (doc == NULL) {
				NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Errors while parsing returned XML" forKey:NSLocalizedDescriptionKey];
			
				response.error = [NSError errorWithDomain:@"LibreAccessService_1_2_0Soap11BindingResponseXML" code:1 userInfo:userInfo];
			} else {
				cur = xmlDocGetRootElement(doc);
				cur = cur->children;
			
				for( ; cur != NULL ; cur = cur->next) {
					if(cur->type == XML_ELEMENT_NODE) {
					
						if(xmlStrEqual(cur->name, (const xmlChar *) "Body")) {
							NSMutableArray *responseBodyParts = [NSMutableArray array];
						
							xmlNodePtr bodyNode;
							for(bodyNode=cur->children ; bodyNode != NULL ; bodyNode = bodyNode->next) {
								if(cur->type == XML_ELEMENT_NODE) {
									if(xmlStrEqual(bodyNode->name, (const xmlChar *) "ListUserContentResponse")) {
										tns1_ListUserContentResponse *bodyObject = [tns1_ListUserContentResponse deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
									if ((bodyNode->ns != nil && xmlStrEqual(bodyNode->ns->prefix, cur->ns->prefix)) && 
										xmlStrEqual(bodyNode->name, (const xmlChar *) "Fault")) {
										SOAPFault *bodyObject = [SOAPFault deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
								}
							}
						
							response.bodyParts = responseBodyParts;
						}
					}
				}
			
				xmlFreeDoc(doc);
			}
			if(delegate != nil && [delegate respondsToSelector:@selector(operation:completedWithResponse:)] == YES) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[delegate operation:self completedWithResponse:response];
				});
			}
		});
	}
}
@end
@implementation LibreAccessService_1_2_0Soap11Binding_SaveDefaultBooks
@synthesize parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
parameters:(tns1_SaveDefaultBooksRequest *)aParameters
{
	if((self = [super initWithBinding:aBinding delegate:responseDelegate])) {
		self.parameters = aParameters;
	}
	
	return self;
}
- (void)dealloc
{
	if(parameters != nil) [parameters release];
	
	[super dealloc];
}
- (void)main
{
	[response autorelease];
	response = [LibreAccessService_1_2_0Soap11BindingResponse new];
	
	LibreAccessService_1_2_0Soap11Binding_envelope *envelope = [LibreAccessService_1_2_0Soap11Binding_envelope sharedInstance];
	
	NSMutableDictionary *headerElements = nil;
	headerElements = [NSMutableDictionary dictionary];
	
	NSMutableDictionary *bodyElements = nil;
	NSMutableArray *bodyKeys = nil;
	bodyElements = [NSMutableDictionary dictionary];
	bodyKeys = [NSMutableArray array];
	id obj;
	obj = nil;
	if(parameters != nil) obj = parameters;
	if(obj != nil) {
		[bodyElements setObject:obj forKey:@"SaveDefaultBooksRequest"];
		[bodyKeys addObject:@"SaveDefaultBooksRequest"];
	}
	
	NSString *operationXMLString = [envelope serializedFormUsingHeaderElements:headerElements bodyElements:bodyElements bodyKeys:bodyKeys];
	
	[binding sendHTTPCallUsingBody:operationXMLString soapAction:@"http://webservices.libredigital.com/libreaccess/SaveDefaultBooks" forOperation:self];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (responseData != nil && delegate != nil)
	{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			xmlDocPtr doc;
			xmlNodePtr cur;
		
			if (binding.logXMLInOut) {
				NSLog(@"ResponseBody:\n%@", [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease]);
			}
		
#if !TARGET_OS_IPHONE && (!defined(MAC_OS_X_VERSION_10_6) || MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_6)
	// Not yet defined in 10.5 libxml
	#define XML_PARSE_COMPACT 0
#endif
			doc = xmlReadMemory([responseData bytes], [responseData length], NULL, NULL, XML_PARSE_COMPACT | XML_PARSE_NOBLANKS);
		
			if (doc == NULL) {
				NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Errors while parsing returned XML" forKey:NSLocalizedDescriptionKey];
			
				response.error = [NSError errorWithDomain:@"LibreAccessService_1_2_0Soap11BindingResponseXML" code:1 userInfo:userInfo];
			} else {
				cur = xmlDocGetRootElement(doc);
				cur = cur->children;
			
				for( ; cur != NULL ; cur = cur->next) {
					if(cur->type == XML_ELEMENT_NODE) {
					
						if(xmlStrEqual(cur->name, (const xmlChar *) "Body")) {
							NSMutableArray *responseBodyParts = [NSMutableArray array];
						
							xmlNodePtr bodyNode;
							for(bodyNode=cur->children ; bodyNode != NULL ; bodyNode = bodyNode->next) {
								if(cur->type == XML_ELEMENT_NODE) {
									if(xmlStrEqual(bodyNode->name, (const xmlChar *) "SaveDefaultBooksResponse")) {
										tns1_SaveDefaultBooksResponse *bodyObject = [tns1_SaveDefaultBooksResponse deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
									if ((bodyNode->ns != nil && xmlStrEqual(bodyNode->ns->prefix, cur->ns->prefix)) && 
										xmlStrEqual(bodyNode->name, (const xmlChar *) "Fault")) {
										SOAPFault *bodyObject = [SOAPFault deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
								}
							}
						
							response.bodyParts = responseBodyParts;
						}
					}
				}
			
				xmlFreeDoc(doc);
			}
			if(delegate != nil && [delegate respondsToSelector:@selector(operation:completedWithResponse:)] == YES) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[delegate operation:self completedWithResponse:response];
				});
			}
		});
	}
}
@end
@implementation LibreAccessService_1_2_0Soap11Binding_ListLastNProfileReadBooks
@synthesize parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
parameters:(tns1_ListLastNProfileReadBooksRequest *)aParameters
{
	if((self = [super initWithBinding:aBinding delegate:responseDelegate])) {
		self.parameters = aParameters;
	}
	
	return self;
}
- (void)dealloc
{
	if(parameters != nil) [parameters release];
	
	[super dealloc];
}
- (void)main
{
	[response autorelease];
	response = [LibreAccessService_1_2_0Soap11BindingResponse new];
	
	LibreAccessService_1_2_0Soap11Binding_envelope *envelope = [LibreAccessService_1_2_0Soap11Binding_envelope sharedInstance];
	
	NSMutableDictionary *headerElements = nil;
	headerElements = [NSMutableDictionary dictionary];
	
	NSMutableDictionary *bodyElements = nil;
	NSMutableArray *bodyKeys = nil;
	bodyElements = [NSMutableDictionary dictionary];
	bodyKeys = [NSMutableArray array];
	id obj;
	obj = nil;
	if(parameters != nil) obj = parameters;
	if(obj != nil) {
		[bodyElements setObject:obj forKey:@"ListLastNProfileReadBooksRequest"];
		[bodyKeys addObject:@"ListLastNProfileReadBooksRequest"];
	}
	
	NSString *operationXMLString = [envelope serializedFormUsingHeaderElements:headerElements bodyElements:bodyElements bodyKeys:bodyKeys];
	
	[binding sendHTTPCallUsingBody:operationXMLString soapAction:@"http://webservices.libredigital.com/libreaccess/ListLastNProfileReadBooks" forOperation:self];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (responseData != nil && delegate != nil)
	{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			xmlDocPtr doc;
			xmlNodePtr cur;
		
			if (binding.logXMLInOut) {
				NSLog(@"ResponseBody:\n%@", [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease]);
			}
		
#if !TARGET_OS_IPHONE && (!defined(MAC_OS_X_VERSION_10_6) || MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_6)
	// Not yet defined in 10.5 libxml
	#define XML_PARSE_COMPACT 0
#endif
			doc = xmlReadMemory([responseData bytes], [responseData length], NULL, NULL, XML_PARSE_COMPACT | XML_PARSE_NOBLANKS);
		
			if (doc == NULL) {
				NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Errors while parsing returned XML" forKey:NSLocalizedDescriptionKey];
			
				response.error = [NSError errorWithDomain:@"LibreAccessService_1_2_0Soap11BindingResponseXML" code:1 userInfo:userInfo];
			} else {
				cur = xmlDocGetRootElement(doc);
				cur = cur->children;
			
				for( ; cur != NULL ; cur = cur->next) {
					if(cur->type == XML_ELEMENT_NODE) {
					
						if(xmlStrEqual(cur->name, (const xmlChar *) "Body")) {
							NSMutableArray *responseBodyParts = [NSMutableArray array];
						
							xmlNodePtr bodyNode;
							for(bodyNode=cur->children ; bodyNode != NULL ; bodyNode = bodyNode->next) {
								if(cur->type == XML_ELEMENT_NODE) {
									if(xmlStrEqual(bodyNode->name, (const xmlChar *) "ListLastNProfileReadBooksResponse")) {
										tns1_ListLastNProfileReadBooksResponse *bodyObject = [tns1_ListLastNProfileReadBooksResponse deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
									if ((bodyNode->ns != nil && xmlStrEqual(bodyNode->ns->prefix, cur->ns->prefix)) && 
										xmlStrEqual(bodyNode->name, (const xmlChar *) "Fault")) {
										SOAPFault *bodyObject = [SOAPFault deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
								}
							}
						
							response.bodyParts = responseBodyParts;
						}
					}
				}
			
				xmlFreeDoc(doc);
			}
			if(delegate != nil && [delegate respondsToSelector:@selector(operation:completedWithResponse:)] == YES) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[delegate operation:self completedWithResponse:response];
				});
			}
		});
	}
}
@end
@implementation LibreAccessService_1_2_0Soap11Binding_ListApplicationSettings
@synthesize parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
parameters:(tns1_ListApplicationSettingsRequest *)aParameters
{
	if((self = [super initWithBinding:aBinding delegate:responseDelegate])) {
		self.parameters = aParameters;
	}
	
	return self;
}
- (void)dealloc
{
	if(parameters != nil) [parameters release];
	
	[super dealloc];
}
- (void)main
{
	[response autorelease];
	response = [LibreAccessService_1_2_0Soap11BindingResponse new];
	
	LibreAccessService_1_2_0Soap11Binding_envelope *envelope = [LibreAccessService_1_2_0Soap11Binding_envelope sharedInstance];
	
	NSMutableDictionary *headerElements = nil;
	headerElements = [NSMutableDictionary dictionary];
	
	NSMutableDictionary *bodyElements = nil;
	NSMutableArray *bodyKeys = nil;
	bodyElements = [NSMutableDictionary dictionary];
	bodyKeys = [NSMutableArray array];
	id obj;
	obj = nil;
	if(parameters != nil) obj = parameters;
	if(obj != nil) {
		[bodyElements setObject:obj forKey:@"ListApplicationSettingsRequest"];
		[bodyKeys addObject:@"ListApplicationSettingsRequest"];
	}
	
	NSString *operationXMLString = [envelope serializedFormUsingHeaderElements:headerElements bodyElements:bodyElements bodyKeys:bodyKeys];
	
	[binding sendHTTPCallUsingBody:operationXMLString soapAction:@"http://webservices.libredigital.com/libreaccess/ListApplicationSettings" forOperation:self];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (responseData != nil && delegate != nil)
	{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			xmlDocPtr doc;
			xmlNodePtr cur;
		
			if (binding.logXMLInOut) {
				NSLog(@"ResponseBody:\n%@", [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease]);
			}
		
#if !TARGET_OS_IPHONE && (!defined(MAC_OS_X_VERSION_10_6) || MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_6)
	// Not yet defined in 10.5 libxml
	#define XML_PARSE_COMPACT 0
#endif
			doc = xmlReadMemory([responseData bytes], [responseData length], NULL, NULL, XML_PARSE_COMPACT | XML_PARSE_NOBLANKS);
		
			if (doc == NULL) {
				NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Errors while parsing returned XML" forKey:NSLocalizedDescriptionKey];
			
				response.error = [NSError errorWithDomain:@"LibreAccessService_1_2_0Soap11BindingResponseXML" code:1 userInfo:userInfo];
			} else {
				cur = xmlDocGetRootElement(doc);
				cur = cur->children;
			
				for( ; cur != NULL ; cur = cur->next) {
					if(cur->type == XML_ELEMENT_NODE) {
					
						if(xmlStrEqual(cur->name, (const xmlChar *) "Body")) {
							NSMutableArray *responseBodyParts = [NSMutableArray array];
						
							xmlNodePtr bodyNode;
							for(bodyNode=cur->children ; bodyNode != NULL ; bodyNode = bodyNode->next) {
								if(cur->type == XML_ELEMENT_NODE) {
									if(xmlStrEqual(bodyNode->name, (const xmlChar *) "ListApplicationSettingsResponse")) {
										tns1_ListApplicationSettingsResponse *bodyObject = [tns1_ListApplicationSettingsResponse deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
									if ((bodyNode->ns != nil && xmlStrEqual(bodyNode->ns->prefix, cur->ns->prefix)) && 
										xmlStrEqual(bodyNode->name, (const xmlChar *) "Fault")) {
										SOAPFault *bodyObject = [SOAPFault deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
								}
							}
						
							response.bodyParts = responseBodyParts;
						}
					}
				}
			
				xmlFreeDoc(doc);
			}
			if(delegate != nil && [delegate respondsToSelector:@selector(operation:completedWithResponse:)] == YES) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[delegate operation:self completedWithResponse:response];
				});
			}
		});
	}
}
@end
@implementation LibreAccessService_1_2_0Soap11Binding_SaveDeviceInfo
@synthesize parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
parameters:(tns1_SaveDeviceInfoRequest *)aParameters
{
	if((self = [super initWithBinding:aBinding delegate:responseDelegate])) {
		self.parameters = aParameters;
	}
	
	return self;
}
- (void)dealloc
{
	if(parameters != nil) [parameters release];
	
	[super dealloc];
}
- (void)main
{
	[response autorelease];
	response = [LibreAccessService_1_2_0Soap11BindingResponse new];
	
	LibreAccessService_1_2_0Soap11Binding_envelope *envelope = [LibreAccessService_1_2_0Soap11Binding_envelope sharedInstance];
	
	NSMutableDictionary *headerElements = nil;
	headerElements = [NSMutableDictionary dictionary];
	
	NSMutableDictionary *bodyElements = nil;
	NSMutableArray *bodyKeys = nil;
	bodyElements = [NSMutableDictionary dictionary];
	bodyKeys = [NSMutableArray array];
	id obj;
	obj = nil;
	if(parameters != nil) obj = parameters;
	if(obj != nil) {
		[bodyElements setObject:obj forKey:@"SaveDeviceInfoRequest"];
		[bodyKeys addObject:@"SaveDeviceInfoRequest"];
	}
	
	NSString *operationXMLString = [envelope serializedFormUsingHeaderElements:headerElements bodyElements:bodyElements bodyKeys:bodyKeys];
	
	[binding sendHTTPCallUsingBody:operationXMLString soapAction:@"http://webservices.libredigital.com/libreaccess/SaveDeviceInfo" forOperation:self];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (responseData != nil && delegate != nil)
	{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			xmlDocPtr doc;
			xmlNodePtr cur;
		
			if (binding.logXMLInOut) {
				NSLog(@"ResponseBody:\n%@", [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease]);
			}
		
#if !TARGET_OS_IPHONE && (!defined(MAC_OS_X_VERSION_10_6) || MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_6)
	// Not yet defined in 10.5 libxml
	#define XML_PARSE_COMPACT 0
#endif
			doc = xmlReadMemory([responseData bytes], [responseData length], NULL, NULL, XML_PARSE_COMPACT | XML_PARSE_NOBLANKS);
		
			if (doc == NULL) {
				NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Errors while parsing returned XML" forKey:NSLocalizedDescriptionKey];
			
				response.error = [NSError errorWithDomain:@"LibreAccessService_1_2_0Soap11BindingResponseXML" code:1 userInfo:userInfo];
			} else {
				cur = xmlDocGetRootElement(doc);
				cur = cur->children;
			
				for( ; cur != NULL ; cur = cur->next) {
					if(cur->type == XML_ELEMENT_NODE) {
					
						if(xmlStrEqual(cur->name, (const xmlChar *) "Body")) {
							NSMutableArray *responseBodyParts = [NSMutableArray array];
						
							xmlNodePtr bodyNode;
							for(bodyNode=cur->children ; bodyNode != NULL ; bodyNode = bodyNode->next) {
								if(cur->type == XML_ELEMENT_NODE) {
									if(xmlStrEqual(bodyNode->name, (const xmlChar *) "SaveDeviceInfoResponse")) {
										tns1_SaveDeviceInfoResponse *bodyObject = [tns1_SaveDeviceInfoResponse deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
									if ((bodyNode->ns != nil && xmlStrEqual(bodyNode->ns->prefix, cur->ns->prefix)) && 
										xmlStrEqual(bodyNode->name, (const xmlChar *) "Fault")) {
										SOAPFault *bodyObject = [SOAPFault deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
								}
							}
						
							response.bodyParts = responseBodyParts;
						}
					}
				}
			
				xmlFreeDoc(doc);
			}
			if(delegate != nil && [delegate respondsToSelector:@selector(operation:completedWithResponse:)] == YES) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[delegate operation:self completedWithResponse:response];
				});
			}
		});
	}
}
@end
@implementation LibreAccessService_1_2_0Soap11Binding_GetDeviceInfo
@synthesize parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
parameters:(tns1_GetDeviceInfoRequest *)aParameters
{
	if((self = [super initWithBinding:aBinding delegate:responseDelegate])) {
		self.parameters = aParameters;
	}
	
	return self;
}
- (void)dealloc
{
	if(parameters != nil) [parameters release];
	
	[super dealloc];
}
- (void)main
{
	[response autorelease];
	response = [LibreAccessService_1_2_0Soap11BindingResponse new];
	
	LibreAccessService_1_2_0Soap11Binding_envelope *envelope = [LibreAccessService_1_2_0Soap11Binding_envelope sharedInstance];
	
	NSMutableDictionary *headerElements = nil;
	headerElements = [NSMutableDictionary dictionary];
	
	NSMutableDictionary *bodyElements = nil;
	NSMutableArray *bodyKeys = nil;
	bodyElements = [NSMutableDictionary dictionary];
	bodyKeys = [NSMutableArray array];
	id obj;
	obj = nil;
	if(parameters != nil) obj = parameters;
	if(obj != nil) {
		[bodyElements setObject:obj forKey:@"GetDeviceInfoRequest"];
		[bodyKeys addObject:@"GetDeviceInfoRequest"];
	}
	
	NSString *operationXMLString = [envelope serializedFormUsingHeaderElements:headerElements bodyElements:bodyElements bodyKeys:bodyKeys];
	
	[binding sendHTTPCallUsingBody:operationXMLString soapAction:@"http://webservices.libredigital.com/libreaccess/GetDeviceInfo" forOperation:self];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (responseData != nil && delegate != nil)
	{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			xmlDocPtr doc;
			xmlNodePtr cur;
		
			if (binding.logXMLInOut) {
				NSLog(@"ResponseBody:\n%@", [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease]);
			}
		
#if !TARGET_OS_IPHONE && (!defined(MAC_OS_X_VERSION_10_6) || MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_6)
	// Not yet defined in 10.5 libxml
	#define XML_PARSE_COMPACT 0
#endif
			doc = xmlReadMemory([responseData bytes], [responseData length], NULL, NULL, XML_PARSE_COMPACT | XML_PARSE_NOBLANKS);
		
			if (doc == NULL) {
				NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Errors while parsing returned XML" forKey:NSLocalizedDescriptionKey];
			
				response.error = [NSError errorWithDomain:@"LibreAccessService_1_2_0Soap11BindingResponseXML" code:1 userInfo:userInfo];
			} else {
				cur = xmlDocGetRootElement(doc);
				cur = cur->children;
			
				for( ; cur != NULL ; cur = cur->next) {
					if(cur->type == XML_ELEMENT_NODE) {
					
						if(xmlStrEqual(cur->name, (const xmlChar *) "Body")) {
							NSMutableArray *responseBodyParts = [NSMutableArray array];
						
							xmlNodePtr bodyNode;
							for(bodyNode=cur->children ; bodyNode != NULL ; bodyNode = bodyNode->next) {
								if(cur->type == XML_ELEMENT_NODE) {
									if(xmlStrEqual(bodyNode->name, (const xmlChar *) "GetDeviceInfoResponse")) {
										tns1_GetDeviceInfoResponse *bodyObject = [tns1_GetDeviceInfoResponse deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
									if ((bodyNode->ns != nil && xmlStrEqual(bodyNode->ns->prefix, cur->ns->prefix)) && 
										xmlStrEqual(bodyNode->name, (const xmlChar *) "Fault")) {
										SOAPFault *bodyObject = [SOAPFault deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
								}
							}
						
							response.bodyParts = responseBodyParts;
						}
					}
				}
			
				xmlFreeDoc(doc);
			}
			if(delegate != nil && [delegate respondsToSelector:@selector(operation:completedWithResponse:)] == YES) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[delegate operation:self completedWithResponse:response];
				});
			}
		});
	}
}
@end
@implementation LibreAccessService_1_2_0Soap11Binding_SaveUserProfiles
@synthesize parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
parameters:(tns1_SaveUserProfilesRequest *)aParameters
{
	if((self = [super initWithBinding:aBinding delegate:responseDelegate])) {
		self.parameters = aParameters;
	}
	
	return self;
}
- (void)dealloc
{
	if(parameters != nil) [parameters release];
	
	[super dealloc];
}
- (void)main
{
	[response autorelease];
	response = [LibreAccessService_1_2_0Soap11BindingResponse new];
	
	LibreAccessService_1_2_0Soap11Binding_envelope *envelope = [LibreAccessService_1_2_0Soap11Binding_envelope sharedInstance];
	
	NSMutableDictionary *headerElements = nil;
	headerElements = [NSMutableDictionary dictionary];
	
	NSMutableDictionary *bodyElements = nil;
	NSMutableArray *bodyKeys = nil;
	bodyElements = [NSMutableDictionary dictionary];
	bodyKeys = [NSMutableArray array];
	id obj;
	obj = nil;
	if(parameters != nil) obj = parameters;
	if(obj != nil) {
		[bodyElements setObject:obj forKey:@"SaveUserProfilesRequest"];
		[bodyKeys addObject:@"SaveUserProfilesRequest"];
	}
	
	NSString *operationXMLString = [envelope serializedFormUsingHeaderElements:headerElements bodyElements:bodyElements bodyKeys:bodyKeys];
	
	[binding sendHTTPCallUsingBody:operationXMLString soapAction:@"http://webservices.libredigital.com/libreaccess/SaveUserProfiles" forOperation:self];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (responseData != nil && delegate != nil)
	{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			xmlDocPtr doc;
			xmlNodePtr cur;
		
			if (binding.logXMLInOut) {
				NSLog(@"ResponseBody:\n%@", [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease]);
			}
		
#if !TARGET_OS_IPHONE && (!defined(MAC_OS_X_VERSION_10_6) || MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_6)
	// Not yet defined in 10.5 libxml
	#define XML_PARSE_COMPACT 0
#endif
			doc = xmlReadMemory([responseData bytes], [responseData length], NULL, NULL, XML_PARSE_COMPACT | XML_PARSE_NOBLANKS);
		
			if (doc == NULL) {
				NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Errors while parsing returned XML" forKey:NSLocalizedDescriptionKey];
			
				response.error = [NSError errorWithDomain:@"LibreAccessService_1_2_0Soap11BindingResponseXML" code:1 userInfo:userInfo];
			} else {
				cur = xmlDocGetRootElement(doc);
				cur = cur->children;
			
				for( ; cur != NULL ; cur = cur->next) {
					if(cur->type == XML_ELEMENT_NODE) {
					
						if(xmlStrEqual(cur->name, (const xmlChar *) "Body")) {
							NSMutableArray *responseBodyParts = [NSMutableArray array];
						
							xmlNodePtr bodyNode;
							for(bodyNode=cur->children ; bodyNode != NULL ; bodyNode = bodyNode->next) {
								if(cur->type == XML_ELEMENT_NODE) {
									if(xmlStrEqual(bodyNode->name, (const xmlChar *) "SaveUserProfilesResponse")) {
										tns1_SaveUserProfilesResponse *bodyObject = [tns1_SaveUserProfilesResponse deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
									if ((bodyNode->ns != nil && xmlStrEqual(bodyNode->ns->prefix, cur->ns->prefix)) && 
										xmlStrEqual(bodyNode->name, (const xmlChar *) "Fault")) {
										SOAPFault *bodyObject = [SOAPFault deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
								}
							}
						
							response.bodyParts = responseBodyParts;
						}
					}
				}
			
				xmlFreeDoc(doc);
			}
			if(delegate != nil && [delegate respondsToSelector:@selector(operation:completedWithResponse:)] == YES) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[delegate operation:self completedWithResponse:response];
				});
			}
		});
	}
}
@end
@implementation LibreAccessService_1_2_0Soap11Binding_SaveUserSettings
@synthesize parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
parameters:(tns1_SaveUserSettingsRequest *)aParameters
{
	if((self = [super initWithBinding:aBinding delegate:responseDelegate])) {
		self.parameters = aParameters;
	}
	
	return self;
}
- (void)dealloc
{
	if(parameters != nil) [parameters release];
	
	[super dealloc];
}
- (void)main
{
	[response autorelease];
	response = [LibreAccessService_1_2_0Soap11BindingResponse new];
	
	LibreAccessService_1_2_0Soap11Binding_envelope *envelope = [LibreAccessService_1_2_0Soap11Binding_envelope sharedInstance];
	
	NSMutableDictionary *headerElements = nil;
	headerElements = [NSMutableDictionary dictionary];
	
	NSMutableDictionary *bodyElements = nil;
	NSMutableArray *bodyKeys = nil;
	bodyElements = [NSMutableDictionary dictionary];
	bodyKeys = [NSMutableArray array];
	id obj;
	obj = nil;
	if(parameters != nil) obj = parameters;
	if(obj != nil) {
		[bodyElements setObject:obj forKey:@"SaveUserSettingsRequest"];
		[bodyKeys addObject:@"SaveUserSettingsRequest"];
	}
	
	NSString *operationXMLString = [envelope serializedFormUsingHeaderElements:headerElements bodyElements:bodyElements bodyKeys:bodyKeys];
	
	[binding sendHTTPCallUsingBody:operationXMLString soapAction:@"http://webservices.libredigital.com/libreaccess/SaveUserSettings" forOperation:self];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (responseData != nil && delegate != nil)
	{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			xmlDocPtr doc;
			xmlNodePtr cur;
		
			if (binding.logXMLInOut) {
				NSLog(@"ResponseBody:\n%@", [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease]);
			}
		
#if !TARGET_OS_IPHONE && (!defined(MAC_OS_X_VERSION_10_6) || MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_6)
	// Not yet defined in 10.5 libxml
	#define XML_PARSE_COMPACT 0
#endif
			doc = xmlReadMemory([responseData bytes], [responseData length], NULL, NULL, XML_PARSE_COMPACT | XML_PARSE_NOBLANKS);
		
			if (doc == NULL) {
				NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Errors while parsing returned XML" forKey:NSLocalizedDescriptionKey];
			
				response.error = [NSError errorWithDomain:@"LibreAccessService_1_2_0Soap11BindingResponseXML" code:1 userInfo:userInfo];
			} else {
				cur = xmlDocGetRootElement(doc);
				cur = cur->children;
			
				for( ; cur != NULL ; cur = cur->next) {
					if(cur->type == XML_ELEMENT_NODE) {
					
						if(xmlStrEqual(cur->name, (const xmlChar *) "Body")) {
							NSMutableArray *responseBodyParts = [NSMutableArray array];
						
							xmlNodePtr bodyNode;
							for(bodyNode=cur->children ; bodyNode != NULL ; bodyNode = bodyNode->next) {
								if(cur->type == XML_ELEMENT_NODE) {
									if(xmlStrEqual(bodyNode->name, (const xmlChar *) "SaveUserSettingsResponse")) {
										tns1_SaveUserSettingsResponse *bodyObject = [tns1_SaveUserSettingsResponse deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
									if ((bodyNode->ns != nil && xmlStrEqual(bodyNode->ns->prefix, cur->ns->prefix)) && 
										xmlStrEqual(bodyNode->name, (const xmlChar *) "Fault")) {
										SOAPFault *bodyObject = [SOAPFault deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
								}
							}
						
							response.bodyParts = responseBodyParts;
						}
					}
				}
			
				xmlFreeDoc(doc);
			}
			if(delegate != nil && [delegate respondsToSelector:@selector(operation:completedWithResponse:)] == YES) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[delegate operation:self completedWithResponse:response];
				});
			}
		});
	}
}
@end
@implementation LibreAccessService_1_2_0Soap11Binding_DeleteBookShelfEntry
@synthesize parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
parameters:(tns1_DeleteBookShelfEntryRequest *)aParameters
{
	if((self = [super initWithBinding:aBinding delegate:responseDelegate])) {
		self.parameters = aParameters;
	}
	
	return self;
}
- (void)dealloc
{
	if(parameters != nil) [parameters release];
	
	[super dealloc];
}
- (void)main
{
	[response autorelease];
	response = [LibreAccessService_1_2_0Soap11BindingResponse new];
	
	LibreAccessService_1_2_0Soap11Binding_envelope *envelope = [LibreAccessService_1_2_0Soap11Binding_envelope sharedInstance];
	
	NSMutableDictionary *headerElements = nil;
	headerElements = [NSMutableDictionary dictionary];
	
	NSMutableDictionary *bodyElements = nil;
	NSMutableArray *bodyKeys = nil;
	bodyElements = [NSMutableDictionary dictionary];
	bodyKeys = [NSMutableArray array];
	id obj;
	obj = nil;
	if(parameters != nil) obj = parameters;
	if(obj != nil) {
		[bodyElements setObject:obj forKey:@"DeleteBookShelfEntryRequest"];
		[bodyKeys addObject:@"DeleteBookShelfEntryRequest"];
	}
	
	NSString *operationXMLString = [envelope serializedFormUsingHeaderElements:headerElements bodyElements:bodyElements bodyKeys:bodyKeys];
	
	[binding sendHTTPCallUsingBody:operationXMLString soapAction:@"http://webservices.libredigital.com/libreaccess/DeleteBookShelfEntry" forOperation:self];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (responseData != nil && delegate != nil)
	{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			xmlDocPtr doc;
			xmlNodePtr cur;
		
			if (binding.logXMLInOut) {
				NSLog(@"ResponseBody:\n%@", [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease]);
			}
		
#if !TARGET_OS_IPHONE && (!defined(MAC_OS_X_VERSION_10_6) || MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_6)
	// Not yet defined in 10.5 libxml
	#define XML_PARSE_COMPACT 0
#endif
			doc = xmlReadMemory([responseData bytes], [responseData length], NULL, NULL, XML_PARSE_COMPACT | XML_PARSE_NOBLANKS);
		
			if (doc == NULL) {
				NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Errors while parsing returned XML" forKey:NSLocalizedDescriptionKey];
			
				response.error = [NSError errorWithDomain:@"LibreAccessService_1_2_0Soap11BindingResponseXML" code:1 userInfo:userInfo];
			} else {
				cur = xmlDocGetRootElement(doc);
				cur = cur->children;
			
				for( ; cur != NULL ; cur = cur->next) {
					if(cur->type == XML_ELEMENT_NODE) {
					
						if(xmlStrEqual(cur->name, (const xmlChar *) "Body")) {
							NSMutableArray *responseBodyParts = [NSMutableArray array];
						
							xmlNodePtr bodyNode;
							for(bodyNode=cur->children ; bodyNode != NULL ; bodyNode = bodyNode->next) {
								if(cur->type == XML_ELEMENT_NODE) {
									if(xmlStrEqual(bodyNode->name, (const xmlChar *) "DeleteBookShelfEntryResponse")) {
										tns1_DeleteBookShelfEntryResponse *bodyObject = [tns1_DeleteBookShelfEntryResponse deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
									if ((bodyNode->ns != nil && xmlStrEqual(bodyNode->ns->prefix, cur->ns->prefix)) && 
										xmlStrEqual(bodyNode->name, (const xmlChar *) "Fault")) {
										SOAPFault *bodyObject = [SOAPFault deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
								}
							}
						
							response.bodyParts = responseBodyParts;
						}
					}
				}
			
				xmlFreeDoc(doc);
			}
			if(delegate != nil && [delegate respondsToSelector:@selector(operation:completedWithResponse:)] == YES) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[delegate operation:self completedWithResponse:response];
				});
			}
		});
	}
}
@end
@implementation LibreAccessService_1_2_0Soap11Binding_GetUserProfiles
@synthesize parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
parameters:(tns1_GetUserProfilesRequest *)aParameters
{
	if((self = [super initWithBinding:aBinding delegate:responseDelegate])) {
		self.parameters = aParameters;
	}
	
	return self;
}
- (void)dealloc
{
	if(parameters != nil) [parameters release];
	
	[super dealloc];
}
- (void)main
{
	[response autorelease];
	response = [LibreAccessService_1_2_0Soap11BindingResponse new];
	
	LibreAccessService_1_2_0Soap11Binding_envelope *envelope = [LibreAccessService_1_2_0Soap11Binding_envelope sharedInstance];
	
	NSMutableDictionary *headerElements = nil;
	headerElements = [NSMutableDictionary dictionary];
	
	NSMutableDictionary *bodyElements = nil;
	NSMutableArray *bodyKeys = nil;
	bodyElements = [NSMutableDictionary dictionary];
	bodyKeys = [NSMutableArray array];
	id obj;
	obj = nil;
	if(parameters != nil) obj = parameters;
	if(obj != nil) {
		[bodyElements setObject:obj forKey:@"GetUserProfilesRequest"];
		[bodyKeys addObject:@"GetUserProfilesRequest"];
	}
	
	NSString *operationXMLString = [envelope serializedFormUsingHeaderElements:headerElements bodyElements:bodyElements bodyKeys:bodyKeys];
	
	[binding sendHTTPCallUsingBody:operationXMLString soapAction:@"http://webservices.libredigital.com/libreaccess/GetUserProfiles" forOperation:self];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (responseData != nil && delegate != nil)
	{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			xmlDocPtr doc;
			xmlNodePtr cur;
		
			if (binding.logXMLInOut) {
				NSLog(@"ResponseBody:\n%@", [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease]);
			}
		
#if !TARGET_OS_IPHONE && (!defined(MAC_OS_X_VERSION_10_6) || MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_6)
	// Not yet defined in 10.5 libxml
	#define XML_PARSE_COMPACT 0
#endif
			doc = xmlReadMemory([responseData bytes], [responseData length], NULL, NULL, XML_PARSE_COMPACT | XML_PARSE_NOBLANKS);
		
			if (doc == NULL) {
				NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Errors while parsing returned XML" forKey:NSLocalizedDescriptionKey];
			
				response.error = [NSError errorWithDomain:@"LibreAccessService_1_2_0Soap11BindingResponseXML" code:1 userInfo:userInfo];
			} else {
				cur = xmlDocGetRootElement(doc);
				cur = cur->children;
			
				for( ; cur != NULL ; cur = cur->next) {
					if(cur->type == XML_ELEMENT_NODE) {
					
						if(xmlStrEqual(cur->name, (const xmlChar *) "Body")) {
							NSMutableArray *responseBodyParts = [NSMutableArray array];
						
							xmlNodePtr bodyNode;
							for(bodyNode=cur->children ; bodyNode != NULL ; bodyNode = bodyNode->next) {
								if(cur->type == XML_ELEMENT_NODE) {
									if(xmlStrEqual(bodyNode->name, (const xmlChar *) "GetUserProfilesResponse")) {
										tns1_GetUserProfilesResponse *bodyObject = [tns1_GetUserProfilesResponse deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
									if ((bodyNode->ns != nil && xmlStrEqual(bodyNode->ns->prefix, cur->ns->prefix)) && 
										xmlStrEqual(bodyNode->name, (const xmlChar *) "Fault")) {
										SOAPFault *bodyObject = [SOAPFault deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
								}
							}
						
							response.bodyParts = responseBodyParts;
						}
					}
				}
			
				xmlFreeDoc(doc);
			}
			if(delegate != nil && [delegate respondsToSelector:@selector(operation:completedWithResponse:)] == YES) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[delegate operation:self completedWithResponse:response];
				});
			}
		});
	}
}
@end
@implementation LibreAccessService_1_2_0Soap11Binding_DeviceCanJoinDomain
@synthesize parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
parameters:(tns1_DeviceCanJoinDomainRequest *)aParameters
{
	if((self = [super initWithBinding:aBinding delegate:responseDelegate])) {
		self.parameters = aParameters;
	}
	
	return self;
}
- (void)dealloc
{
	if(parameters != nil) [parameters release];
	
	[super dealloc];
}
- (void)main
{
	[response autorelease];
	response = [LibreAccessService_1_2_0Soap11BindingResponse new];
	
	LibreAccessService_1_2_0Soap11Binding_envelope *envelope = [LibreAccessService_1_2_0Soap11Binding_envelope sharedInstance];
	
	NSMutableDictionary *headerElements = nil;
	headerElements = [NSMutableDictionary dictionary];
	
	NSMutableDictionary *bodyElements = nil;
	NSMutableArray *bodyKeys = nil;
	bodyElements = [NSMutableDictionary dictionary];
	bodyKeys = [NSMutableArray array];
	id obj;
	obj = nil;
	if(parameters != nil) obj = parameters;
	if(obj != nil) {
		[bodyElements setObject:obj forKey:@"DeviceCanJoinDomainRequest"];
		[bodyKeys addObject:@"DeviceCanJoinDomainRequest"];
	}
	
	NSString *operationXMLString = [envelope serializedFormUsingHeaderElements:headerElements bodyElements:bodyElements bodyKeys:bodyKeys];
	
	[binding sendHTTPCallUsingBody:operationXMLString soapAction:@"http://webservices.libredigital.com/libreaccess/DeviceCanJoinDomain" forOperation:self];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (responseData != nil && delegate != nil)
	{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			xmlDocPtr doc;
			xmlNodePtr cur;
		
			if (binding.logXMLInOut) {
				NSLog(@"ResponseBody:\n%@", [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease]);
			}
		
#if !TARGET_OS_IPHONE && (!defined(MAC_OS_X_VERSION_10_6) || MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_6)
	// Not yet defined in 10.5 libxml
	#define XML_PARSE_COMPACT 0
#endif
			doc = xmlReadMemory([responseData bytes], [responseData length], NULL, NULL, XML_PARSE_COMPACT | XML_PARSE_NOBLANKS);
		
			if (doc == NULL) {
				NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Errors while parsing returned XML" forKey:NSLocalizedDescriptionKey];
			
				response.error = [NSError errorWithDomain:@"LibreAccessService_1_2_0Soap11BindingResponseXML" code:1 userInfo:userInfo];
			} else {
				cur = xmlDocGetRootElement(doc);
				cur = cur->children;
			
				for( ; cur != NULL ; cur = cur->next) {
					if(cur->type == XML_ELEMENT_NODE) {
					
						if(xmlStrEqual(cur->name, (const xmlChar *) "Body")) {
							NSMutableArray *responseBodyParts = [NSMutableArray array];
						
							xmlNodePtr bodyNode;
							for(bodyNode=cur->children ; bodyNode != NULL ; bodyNode = bodyNode->next) {
								if(cur->type == XML_ELEMENT_NODE) {
									if(xmlStrEqual(bodyNode->name, (const xmlChar *) "DeviceCanJoinDomainResponse")) {
										tns1_DeviceCanJoinDomainResponse *bodyObject = [tns1_DeviceCanJoinDomainResponse deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
									if ((bodyNode->ns != nil && xmlStrEqual(bodyNode->ns->prefix, cur->ns->prefix)) && 
										xmlStrEqual(bodyNode->name, (const xmlChar *) "Fault")) {
										SOAPFault *bodyObject = [SOAPFault deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
								}
							}
						
							response.bodyParts = responseBodyParts;
						}
					}
				}
			
				xmlFreeDoc(doc);
			}
			if(delegate != nil && [delegate respondsToSelector:@selector(operation:completedWithResponse:)] == YES) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[delegate operation:self completedWithResponse:response];
				});
			}
		});
	}
}
@end
@implementation LibreAccessService_1_2_0Soap11Binding_SaveNewDomain
@synthesize parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
parameters:(tns1_SaveNewDomainRequest *)aParameters
{
	if((self = [super initWithBinding:aBinding delegate:responseDelegate])) {
		self.parameters = aParameters;
	}
	
	return self;
}
- (void)dealloc
{
	if(parameters != nil) [parameters release];
	
	[super dealloc];
}
- (void)main
{
	[response autorelease];
	response = [LibreAccessService_1_2_0Soap11BindingResponse new];
	
	LibreAccessService_1_2_0Soap11Binding_envelope *envelope = [LibreAccessService_1_2_0Soap11Binding_envelope sharedInstance];
	
	NSMutableDictionary *headerElements = nil;
	headerElements = [NSMutableDictionary dictionary];
	
	NSMutableDictionary *bodyElements = nil;
	NSMutableArray *bodyKeys = nil;
	bodyElements = [NSMutableDictionary dictionary];
	bodyKeys = [NSMutableArray array];
	id obj;
	obj = nil;
	if(parameters != nil) obj = parameters;
	if(obj != nil) {
		[bodyElements setObject:obj forKey:@"SaveNewDomainRequest"];
		[bodyKeys addObject:@"SaveNewDomainRequest"];
	}
	
	NSString *operationXMLString = [envelope serializedFormUsingHeaderElements:headerElements bodyElements:bodyElements bodyKeys:bodyKeys];
	
	[binding sendHTTPCallUsingBody:operationXMLString soapAction:@"http://webservices.libredigital.com/libreaccess/SaveNewDomain" forOperation:self];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (responseData != nil && delegate != nil)
	{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			xmlDocPtr doc;
			xmlNodePtr cur;
		
			if (binding.logXMLInOut) {
				NSLog(@"ResponseBody:\n%@", [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease]);
			}
		
#if !TARGET_OS_IPHONE && (!defined(MAC_OS_X_VERSION_10_6) || MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_6)
	// Not yet defined in 10.5 libxml
	#define XML_PARSE_COMPACT 0
#endif
			doc = xmlReadMemory([responseData bytes], [responseData length], NULL, NULL, XML_PARSE_COMPACT | XML_PARSE_NOBLANKS);
		
			if (doc == NULL) {
				NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Errors while parsing returned XML" forKey:NSLocalizedDescriptionKey];
			
				response.error = [NSError errorWithDomain:@"LibreAccessService_1_2_0Soap11BindingResponseXML" code:1 userInfo:userInfo];
			} else {
				cur = xmlDocGetRootElement(doc);
				cur = cur->children;
			
				for( ; cur != NULL ; cur = cur->next) {
					if(cur->type == XML_ELEMENT_NODE) {
					
						if(xmlStrEqual(cur->name, (const xmlChar *) "Body")) {
							NSMutableArray *responseBodyParts = [NSMutableArray array];
						
							xmlNodePtr bodyNode;
							for(bodyNode=cur->children ; bodyNode != NULL ; bodyNode = bodyNode->next) {
								if(cur->type == XML_ELEMENT_NODE) {
									if(xmlStrEqual(bodyNode->name, (const xmlChar *) "SaveNewDomainResponse")) {
										tns1_SaveNewDomainResponse *bodyObject = [tns1_SaveNewDomainResponse deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
									if ((bodyNode->ns != nil && xmlStrEqual(bodyNode->ns->prefix, cur->ns->prefix)) && 
										xmlStrEqual(bodyNode->name, (const xmlChar *) "Fault")) {
										SOAPFault *bodyObject = [SOAPFault deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
								}
							}
						
							response.bodyParts = responseBodyParts;
						}
					}
				}
			
				xmlFreeDoc(doc);
			}
			if(delegate != nil && [delegate respondsToSelector:@selector(operation:completedWithResponse:)] == YES) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[delegate operation:self completedWithResponse:response];
				});
			}
		});
	}
}
@end
@implementation LibreAccessService_1_2_0Soap11Binding_SaveUserCSRNotes
@synthesize parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
parameters:(tns1_SaveUserCSRNotesRequest *)aParameters
{
	if((self = [super initWithBinding:aBinding delegate:responseDelegate])) {
		self.parameters = aParameters;
	}
	
	return self;
}
- (void)dealloc
{
	if(parameters != nil) [parameters release];
	
	[super dealloc];
}
- (void)main
{
	[response autorelease];
	response = [LibreAccessService_1_2_0Soap11BindingResponse new];
	
	LibreAccessService_1_2_0Soap11Binding_envelope *envelope = [LibreAccessService_1_2_0Soap11Binding_envelope sharedInstance];
	
	NSMutableDictionary *headerElements = nil;
	headerElements = [NSMutableDictionary dictionary];
	
	NSMutableDictionary *bodyElements = nil;
	NSMutableArray *bodyKeys = nil;
	bodyElements = [NSMutableDictionary dictionary];
	bodyKeys = [NSMutableArray array];
	id obj;
	obj = nil;
	if(parameters != nil) obj = parameters;
	if(obj != nil) {
		[bodyElements setObject:obj forKey:@"SaveUserCSRNotesRequest"];
		[bodyKeys addObject:@"SaveUserCSRNotesRequest"];
	}
	
	NSString *operationXMLString = [envelope serializedFormUsingHeaderElements:headerElements bodyElements:bodyElements bodyKeys:bodyKeys];
	
	[binding sendHTTPCallUsingBody:operationXMLString soapAction:@"http://webservices.libredigital.com/libreaccess/SaveUserCSRNotes" forOperation:self];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (responseData != nil && delegate != nil)
	{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			xmlDocPtr doc;
			xmlNodePtr cur;
		
			if (binding.logXMLInOut) {
				NSLog(@"ResponseBody:\n%@", [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease]);
			}
		
#if !TARGET_OS_IPHONE && (!defined(MAC_OS_X_VERSION_10_6) || MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_6)
	// Not yet defined in 10.5 libxml
	#define XML_PARSE_COMPACT 0
#endif
			doc = xmlReadMemory([responseData bytes], [responseData length], NULL, NULL, XML_PARSE_COMPACT | XML_PARSE_NOBLANKS);
		
			if (doc == NULL) {
				NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Errors while parsing returned XML" forKey:NSLocalizedDescriptionKey];
			
				response.error = [NSError errorWithDomain:@"LibreAccessService_1_2_0Soap11BindingResponseXML" code:1 userInfo:userInfo];
			} else {
				cur = xmlDocGetRootElement(doc);
				cur = cur->children;
			
				for( ; cur != NULL ; cur = cur->next) {
					if(cur->type == XML_ELEMENT_NODE) {
					
						if(xmlStrEqual(cur->name, (const xmlChar *) "Body")) {
							NSMutableArray *responseBodyParts = [NSMutableArray array];
						
							xmlNodePtr bodyNode;
							for(bodyNode=cur->children ; bodyNode != NULL ; bodyNode = bodyNode->next) {
								if(cur->type == XML_ELEMENT_NODE) {
									if(xmlStrEqual(bodyNode->name, (const xmlChar *) "SaveUserCSRNotesResponse")) {
										tns1_SaveUserCSRNotesResponse *bodyObject = [tns1_SaveUserCSRNotesResponse deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
									if ((bodyNode->ns != nil && xmlStrEqual(bodyNode->ns->prefix, cur->ns->prefix)) && 
										xmlStrEqual(bodyNode->name, (const xmlChar *) "Fault")) {
										SOAPFault *bodyObject = [SOAPFault deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
								}
							}
						
							response.bodyParts = responseBodyParts;
						}
					}
				}
			
				xmlFreeDoc(doc);
			}
			if(delegate != nil && [delegate respondsToSelector:@selector(operation:completedWithResponse:)] == YES) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[delegate operation:self completedWithResponse:response];
				});
			}
		});
	}
}
@end
@implementation LibreAccessService_1_2_0Soap11Binding_SaveProfileContentAnnotations
@synthesize parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
parameters:(tns1_SaveProfileContentAnnotationsRequest *)aParameters
{
	if((self = [super initWithBinding:aBinding delegate:responseDelegate])) {
		self.parameters = aParameters;
	}
	
	return self;
}
- (void)dealloc
{
	if(parameters != nil) [parameters release];
	
	[super dealloc];
}
- (void)main
{
	[response autorelease];
	response = [LibreAccessService_1_2_0Soap11BindingResponse new];
	
	LibreAccessService_1_2_0Soap11Binding_envelope *envelope = [LibreAccessService_1_2_0Soap11Binding_envelope sharedInstance];
	
	NSMutableDictionary *headerElements = nil;
	headerElements = [NSMutableDictionary dictionary];
	
	NSMutableDictionary *bodyElements = nil;
	NSMutableArray *bodyKeys = nil;
	bodyElements = [NSMutableDictionary dictionary];
	bodyKeys = [NSMutableArray array];
	id obj;
	obj = nil;
	if(parameters != nil) obj = parameters;
	if(obj != nil) {
		[bodyElements setObject:obj forKey:@"SaveProfileContentAnnotationsRequest"];
		[bodyKeys addObject:@"SaveProfileContentAnnotationsRequest"];
	}
	
	NSString *operationXMLString = [envelope serializedFormUsingHeaderElements:headerElements bodyElements:bodyElements bodyKeys:bodyKeys];
	
	[binding sendHTTPCallUsingBody:operationXMLString soapAction:@"http://webservices.libredigital.com/libreaccess/SaveProfileContentAnnotations" forOperation:self];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (responseData != nil && delegate != nil)
	{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			xmlDocPtr doc;
			xmlNodePtr cur;
		
			if (binding.logXMLInOut) {
				NSLog(@"ResponseBody:\n%@", [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease]);
			}
		
#if !TARGET_OS_IPHONE && (!defined(MAC_OS_X_VERSION_10_6) || MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_6)
	// Not yet defined in 10.5 libxml
	#define XML_PARSE_COMPACT 0
#endif
			doc = xmlReadMemory([responseData bytes], [responseData length], NULL, NULL, XML_PARSE_COMPACT | XML_PARSE_NOBLANKS);
		
			if (doc == NULL) {
				NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Errors while parsing returned XML" forKey:NSLocalizedDescriptionKey];
			
				response.error = [NSError errorWithDomain:@"LibreAccessService_1_2_0Soap11BindingResponseXML" code:1 userInfo:userInfo];
			} else {
				cur = xmlDocGetRootElement(doc);
				cur = cur->children;
			
				for( ; cur != NULL ; cur = cur->next) {
					if(cur->type == XML_ELEMENT_NODE) {
					
						if(xmlStrEqual(cur->name, (const xmlChar *) "Body")) {
							NSMutableArray *responseBodyParts = [NSMutableArray array];
						
							xmlNodePtr bodyNode;
							for(bodyNode=cur->children ; bodyNode != NULL ; bodyNode = bodyNode->next) {
								if(cur->type == XML_ELEMENT_NODE) {
									if(xmlStrEqual(bodyNode->name, (const xmlChar *) "SaveProfileContentAnnotationsResponse")) {
										tns1_SaveProfileContentAnnotationsResponse *bodyObject = [tns1_SaveProfileContentAnnotationsResponse deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
									if ((bodyNode->ns != nil && xmlStrEqual(bodyNode->ns->prefix, cur->ns->prefix)) && 
										xmlStrEqual(bodyNode->name, (const xmlChar *) "Fault")) {
										SOAPFault *bodyObject = [SOAPFault deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
								}
							}
						
							response.bodyParts = responseBodyParts;
						}
					}
				}
			
				xmlFreeDoc(doc);
			}
			if(delegate != nil && [delegate respondsToSelector:@selector(operation:completedWithResponse:)] == YES) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[delegate operation:self completedWithResponse:response];
				});
			}
		});
	}
}
@end
@implementation LibreAccessService_1_2_0Soap11Binding_RemoveDefaultBooks
@synthesize parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
parameters:(tns1_RemoveDefaultBooksRequest *)aParameters
{
	if((self = [super initWithBinding:aBinding delegate:responseDelegate])) {
		self.parameters = aParameters;
	}
	
	return self;
}
- (void)dealloc
{
	if(parameters != nil) [parameters release];
	
	[super dealloc];
}
- (void)main
{
	[response autorelease];
	response = [LibreAccessService_1_2_0Soap11BindingResponse new];
	
	LibreAccessService_1_2_0Soap11Binding_envelope *envelope = [LibreAccessService_1_2_0Soap11Binding_envelope sharedInstance];
	
	NSMutableDictionary *headerElements = nil;
	headerElements = [NSMutableDictionary dictionary];
	
	NSMutableDictionary *bodyElements = nil;
	NSMutableArray *bodyKeys = nil;
	bodyElements = [NSMutableDictionary dictionary];
	bodyKeys = [NSMutableArray array];
	id obj;
	obj = nil;
	if(parameters != nil) obj = parameters;
	if(obj != nil) {
		[bodyElements setObject:obj forKey:@"RemoveDefaultBooksRequest"];
		[bodyKeys addObject:@"RemoveDefaultBooksRequest"];
	}
	
	NSString *operationXMLString = [envelope serializedFormUsingHeaderElements:headerElements bodyElements:bodyElements bodyKeys:bodyKeys];
	
	[binding sendHTTPCallUsingBody:operationXMLString soapAction:@"http://webservices.libredigital.com/libreaccess/RemoveDefaultBooks" forOperation:self];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (responseData != nil && delegate != nil)
	{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			xmlDocPtr doc;
			xmlNodePtr cur;
		
			if (binding.logXMLInOut) {
				NSLog(@"ResponseBody:\n%@", [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease]);
			}
		
#if !TARGET_OS_IPHONE && (!defined(MAC_OS_X_VERSION_10_6) || MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_6)
	// Not yet defined in 10.5 libxml
	#define XML_PARSE_COMPACT 0
#endif
			doc = xmlReadMemory([responseData bytes], [responseData length], NULL, NULL, XML_PARSE_COMPACT | XML_PARSE_NOBLANKS);
		
			if (doc == NULL) {
				NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Errors while parsing returned XML" forKey:NSLocalizedDescriptionKey];
			
				response.error = [NSError errorWithDomain:@"LibreAccessService_1_2_0Soap11BindingResponseXML" code:1 userInfo:userInfo];
			} else {
				cur = xmlDocGetRootElement(doc);
				cur = cur->children;
			
				for( ; cur != NULL ; cur = cur->next) {
					if(cur->type == XML_ELEMENT_NODE) {
					
						if(xmlStrEqual(cur->name, (const xmlChar *) "Body")) {
							NSMutableArray *responseBodyParts = [NSMutableArray array];
						
							xmlNodePtr bodyNode;
							for(bodyNode=cur->children ; bodyNode != NULL ; bodyNode = bodyNode->next) {
								if(cur->type == XML_ELEMENT_NODE) {
									if(xmlStrEqual(bodyNode->name, (const xmlChar *) "RemoveDefaultBooksResponse")) {
										tns1_RemoveDefaultBooksResponse *bodyObject = [tns1_RemoveDefaultBooksResponse deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
									if ((bodyNode->ns != nil && xmlStrEqual(bodyNode->ns->prefix, cur->ns->prefix)) && 
										xmlStrEqual(bodyNode->name, (const xmlChar *) "Fault")) {
										SOAPFault *bodyObject = [SOAPFault deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
								}
							}
						
							response.bodyParts = responseBodyParts;
						}
					}
				}
			
				xmlFreeDoc(doc);
			}
			if(delegate != nil && [delegate respondsToSelector:@selector(operation:completedWithResponse:)] == YES) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[delegate operation:self completedWithResponse:response];
				});
			}
		});
	}
}
@end
@implementation LibreAccessService_1_2_0Soap11Binding_SetAccountAutoAssign
@synthesize parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
parameters:(tns1_SetAccountAutoAssignRequest *)aParameters
{
	if((self = [super initWithBinding:aBinding delegate:responseDelegate])) {
		self.parameters = aParameters;
	}
	
	return self;
}
- (void)dealloc
{
	if(parameters != nil) [parameters release];
	
	[super dealloc];
}
- (void)main
{
	[response autorelease];
	response = [LibreAccessService_1_2_0Soap11BindingResponse new];
	
	LibreAccessService_1_2_0Soap11Binding_envelope *envelope = [LibreAccessService_1_2_0Soap11Binding_envelope sharedInstance];
	
	NSMutableDictionary *headerElements = nil;
	headerElements = [NSMutableDictionary dictionary];
	
	NSMutableDictionary *bodyElements = nil;
	NSMutableArray *bodyKeys = nil;
	bodyElements = [NSMutableDictionary dictionary];
	bodyKeys = [NSMutableArray array];
	id obj;
	obj = nil;
	if(parameters != nil) obj = parameters;
	if(obj != nil) {
		[bodyElements setObject:obj forKey:@"SetAccountAutoAssignRequest"];
		[bodyKeys addObject:@"SetAccountAutoAssignRequest"];
	}
	
	NSString *operationXMLString = [envelope serializedFormUsingHeaderElements:headerElements bodyElements:bodyElements bodyKeys:bodyKeys];
	
	[binding sendHTTPCallUsingBody:operationXMLString soapAction:@"http://webservices.libredigital.com/libreaccess/SetAccountAutoAssign" forOperation:self];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (responseData != nil && delegate != nil)
	{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			xmlDocPtr doc;
			xmlNodePtr cur;
		
			if (binding.logXMLInOut) {
				NSLog(@"ResponseBody:\n%@", [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease]);
			}
		
#if !TARGET_OS_IPHONE && (!defined(MAC_OS_X_VERSION_10_6) || MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_6)
	// Not yet defined in 10.5 libxml
	#define XML_PARSE_COMPACT 0
#endif
			doc = xmlReadMemory([responseData bytes], [responseData length], NULL, NULL, XML_PARSE_COMPACT | XML_PARSE_NOBLANKS);
		
			if (doc == NULL) {
				NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Errors while parsing returned XML" forKey:NSLocalizedDescriptionKey];
			
				response.error = [NSError errorWithDomain:@"LibreAccessService_1_2_0Soap11BindingResponseXML" code:1 userInfo:userInfo];
			} else {
				cur = xmlDocGetRootElement(doc);
				cur = cur->children;
			
				for( ; cur != NULL ; cur = cur->next) {
					if(cur->type == XML_ELEMENT_NODE) {
					
						if(xmlStrEqual(cur->name, (const xmlChar *) "Body")) {
							NSMutableArray *responseBodyParts = [NSMutableArray array];
						
							xmlNodePtr bodyNode;
							for(bodyNode=cur->children ; bodyNode != NULL ; bodyNode = bodyNode->next) {
								if(cur->type == XML_ELEMENT_NODE) {
									if(xmlStrEqual(bodyNode->name, (const xmlChar *) "SetAccountAutoAssignResponse")) {
										tns1_SetAccountAutoAssignResponse *bodyObject = [tns1_SetAccountAutoAssignResponse deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
									if ((bodyNode->ns != nil && xmlStrEqual(bodyNode->ns->prefix, cur->ns->prefix)) && 
										xmlStrEqual(bodyNode->name, (const xmlChar *) "Fault")) {
										SOAPFault *bodyObject = [SOAPFault deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
								}
							}
						
							response.bodyParts = responseBodyParts;
						}
					}
				}
			
				xmlFreeDoc(doc);
			}
			if(delegate != nil && [delegate respondsToSelector:@selector(operation:completedWithResponse:)] == YES) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[delegate operation:self completedWithResponse:response];
				});
			}
		});
	}
}
@end
@implementation LibreAccessService_1_2_0Soap11Binding_TokenExchange
@synthesize body;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
body:(tns1_TokenExchange *)aBody
{
	if((self = [super initWithBinding:aBinding delegate:responseDelegate])) {
		self.body = aBody;
	}
	
	return self;
}
- (void)dealloc
{
	if(body != nil) [body release];
	
	[super dealloc];
}
- (void)main
{
	[response autorelease];
	response = [LibreAccessService_1_2_0Soap11BindingResponse new];
	
	LibreAccessService_1_2_0Soap11Binding_envelope *envelope = [LibreAccessService_1_2_0Soap11Binding_envelope sharedInstance];
	
	NSMutableDictionary *headerElements = nil;
	headerElements = [NSMutableDictionary dictionary];
	
	NSMutableDictionary *bodyElements = nil;
	NSMutableArray *bodyKeys = nil;
	bodyElements = [NSMutableDictionary dictionary];
	bodyKeys = [NSMutableArray array];
	id obj;
	obj = nil;
	if(body != nil) obj = body;
	if(obj != nil) {
		[bodyElements setObject:obj forKey:@"TokenExchange"];
		[bodyKeys addObject:@"TokenExchange"];
	}
	
	NSString *operationXMLString = [envelope serializedFormUsingHeaderElements:headerElements bodyElements:bodyElements bodyKeys:bodyKeys];
	
	[binding sendHTTPCallUsingBody:operationXMLString soapAction:@"http://webservices.libredigital.com/libreaccess/TokenExchange" forOperation:self];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (responseData != nil && delegate != nil)
	{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			xmlDocPtr doc;
			xmlNodePtr cur;
		
			if (binding.logXMLInOut) {
				NSLog(@"ResponseBody:\n%@", [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease]);
			}
		
#if !TARGET_OS_IPHONE && (!defined(MAC_OS_X_VERSION_10_6) || MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_6)
	// Not yet defined in 10.5 libxml
	#define XML_PARSE_COMPACT 0
#endif
			doc = xmlReadMemory([responseData bytes], [responseData length], NULL, NULL, XML_PARSE_COMPACT | XML_PARSE_NOBLANKS);
		
			if (doc == NULL) {
				NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Errors while parsing returned XML" forKey:NSLocalizedDescriptionKey];
			
				response.error = [NSError errorWithDomain:@"LibreAccessService_1_2_0Soap11BindingResponseXML" code:1 userInfo:userInfo];
			} else {
				cur = xmlDocGetRootElement(doc);
				cur = cur->children;
			
				for( ; cur != NULL ; cur = cur->next) {
					if(cur->type == XML_ELEMENT_NODE) {
					
						if(xmlStrEqual(cur->name, (const xmlChar *) "Body")) {
							NSMutableArray *responseBodyParts = [NSMutableArray array];
						
							xmlNodePtr bodyNode;
							for(bodyNode=cur->children ; bodyNode != NULL ; bodyNode = bodyNode->next) {
								if(cur->type == XML_ELEMENT_NODE) {
									if(xmlStrEqual(bodyNode->name, (const xmlChar *) "TokenExchangeResponse")) {
										tns1_TokenExchangeResponse *bodyObject = [tns1_TokenExchangeResponse deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
									if ((bodyNode->ns != nil && xmlStrEqual(bodyNode->ns->prefix, cur->ns->prefix)) && 
										xmlStrEqual(bodyNode->name, (const xmlChar *) "Fault")) {
										SOAPFault *bodyObject = [SOAPFault deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
								}
							}
						
							response.bodyParts = responseBodyParts;
						}
					}
				}
			
				xmlFreeDoc(doc);
			}
			if(delegate != nil && [delegate respondsToSelector:@selector(operation:completedWithResponse:)] == YES) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[delegate operation:self completedWithResponse:response];
				});
			}
		});
	}
}
@end
@implementation LibreAccessService_1_2_0Soap11Binding_RenewToken
@synthesize body;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
body:(tns1_RenewTokenRequest *)aBody
{
	if((self = [super initWithBinding:aBinding delegate:responseDelegate])) {
		self.body = aBody;
	}
	
	return self;
}
- (void)dealloc
{
	if(body != nil) [body release];
	
	[super dealloc];
}
- (void)main
{
	[response autorelease];
	response = [LibreAccessService_1_2_0Soap11BindingResponse new];
	
	LibreAccessService_1_2_0Soap11Binding_envelope *envelope = [LibreAccessService_1_2_0Soap11Binding_envelope sharedInstance];
	
	NSMutableDictionary *headerElements = nil;
	headerElements = [NSMutableDictionary dictionary];
	
	NSMutableDictionary *bodyElements = nil;
	NSMutableArray *bodyKeys = nil;
	bodyElements = [NSMutableDictionary dictionary];
	bodyKeys = [NSMutableArray array];
	id obj;
	obj = nil;
	if(body != nil) obj = body;
	if(obj != nil) {
		[bodyElements setObject:obj forKey:@"RenewTokenRequest"];
		[bodyKeys addObject:@"RenewTokenRequest"];
	}
	
	NSString *operationXMLString = [envelope serializedFormUsingHeaderElements:headerElements bodyElements:bodyElements bodyKeys:bodyKeys];
	
	[binding sendHTTPCallUsingBody:operationXMLString soapAction:@"http://webservices.libredigital.com/libreaccess/RenewToken" forOperation:self];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (responseData != nil && delegate != nil)
	{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			xmlDocPtr doc;
			xmlNodePtr cur;
		
			if (binding.logXMLInOut) {
				NSLog(@"ResponseBody:\n%@", [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease]);
			}
		
#if !TARGET_OS_IPHONE && (!defined(MAC_OS_X_VERSION_10_6) || MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_6)
	// Not yet defined in 10.5 libxml
	#define XML_PARSE_COMPACT 0
#endif
			doc = xmlReadMemory([responseData bytes], [responseData length], NULL, NULL, XML_PARSE_COMPACT | XML_PARSE_NOBLANKS);
		
			if (doc == NULL) {
				NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Errors while parsing returned XML" forKey:NSLocalizedDescriptionKey];
			
				response.error = [NSError errorWithDomain:@"LibreAccessService_1_2_0Soap11BindingResponseXML" code:1 userInfo:userInfo];
			} else {
				cur = xmlDocGetRootElement(doc);
				cur = cur->children;
			
				for( ; cur != NULL ; cur = cur->next) {
					if(cur->type == XML_ELEMENT_NODE) {
					
						if(xmlStrEqual(cur->name, (const xmlChar *) "Body")) {
							NSMutableArray *responseBodyParts = [NSMutableArray array];
						
							xmlNodePtr bodyNode;
							for(bodyNode=cur->children ; bodyNode != NULL ; bodyNode = bodyNode->next) {
								if(cur->type == XML_ELEMENT_NODE) {
									if(xmlStrEqual(bodyNode->name, (const xmlChar *) "RenewTokenResponse")) {
										tns1_RenewTokenResponse *bodyObject = [tns1_RenewTokenResponse deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
									if ((bodyNode->ns != nil && xmlStrEqual(bodyNode->ns->prefix, cur->ns->prefix)) && 
										xmlStrEqual(bodyNode->name, (const xmlChar *) "Fault")) {
										SOAPFault *bodyObject = [SOAPFault deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
								}
							}
						
							response.bodyParts = responseBodyParts;
						}
					}
				}
			
				xmlFreeDoc(doc);
			}
			if(delegate != nil && [delegate respondsToSelector:@selector(operation:completedWithResponse:)] == YES) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[delegate operation:self completedWithResponse:response];
				});
			}
		});
	}
}
@end
@implementation LibreAccessService_1_2_0Soap11Binding_ListRatings
@synthesize parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
parameters:(tns1_ListRatingsRequest *)aParameters
{
	if((self = [super initWithBinding:aBinding delegate:responseDelegate])) {
		self.parameters = aParameters;
	}
	
	return self;
}
- (void)dealloc
{
	if(parameters != nil) [parameters release];
	
	[super dealloc];
}
- (void)main
{
	[response autorelease];
	response = [LibreAccessService_1_2_0Soap11BindingResponse new];
	
	LibreAccessService_1_2_0Soap11Binding_envelope *envelope = [LibreAccessService_1_2_0Soap11Binding_envelope sharedInstance];
	
	NSMutableDictionary *headerElements = nil;
	headerElements = [NSMutableDictionary dictionary];
	
	NSMutableDictionary *bodyElements = nil;
	NSMutableArray *bodyKeys = nil;
	bodyElements = [NSMutableDictionary dictionary];
	bodyKeys = [NSMutableArray array];
	id obj;
	obj = nil;
	if(parameters != nil) obj = parameters;
	if(obj != nil) {
		[bodyElements setObject:obj forKey:@"ListRatingsRequest"];
		[bodyKeys addObject:@"ListRatingsRequest"];
	}
	
	NSString *operationXMLString = [envelope serializedFormUsingHeaderElements:headerElements bodyElements:bodyElements bodyKeys:bodyKeys];
	
	[binding sendHTTPCallUsingBody:operationXMLString soapAction:@"http://webservices.libredigital.com/libreaccess/ListRatings" forOperation:self];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (responseData != nil && delegate != nil)
	{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			xmlDocPtr doc;
			xmlNodePtr cur;
		
			if (binding.logXMLInOut) {
				NSLog(@"ResponseBody:\n%@", [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease]);
			}
		
#if !TARGET_OS_IPHONE && (!defined(MAC_OS_X_VERSION_10_6) || MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_6)
	// Not yet defined in 10.5 libxml
	#define XML_PARSE_COMPACT 0
#endif
			doc = xmlReadMemory([responseData bytes], [responseData length], NULL, NULL, XML_PARSE_COMPACT | XML_PARSE_NOBLANKS);
		
			if (doc == NULL) {
				NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Errors while parsing returned XML" forKey:NSLocalizedDescriptionKey];
			
				response.error = [NSError errorWithDomain:@"LibreAccessService_1_2_0Soap11BindingResponseXML" code:1 userInfo:userInfo];
			} else {
				cur = xmlDocGetRootElement(doc);
				cur = cur->children;
			
				for( ; cur != NULL ; cur = cur->next) {
					if(cur->type == XML_ELEMENT_NODE) {
					
						if(xmlStrEqual(cur->name, (const xmlChar *) "Body")) {
							NSMutableArray *responseBodyParts = [NSMutableArray array];
						
							xmlNodePtr bodyNode;
							for(bodyNode=cur->children ; bodyNode != NULL ; bodyNode = bodyNode->next) {
								if(cur->type == XML_ELEMENT_NODE) {
									if(xmlStrEqual(bodyNode->name, (const xmlChar *) "ListRatingsResponse")) {
										tns1_ListRatingsResponse *bodyObject = [tns1_ListRatingsResponse deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
									if ((bodyNode->ns != nil && xmlStrEqual(bodyNode->ns->prefix, cur->ns->prefix)) && 
										xmlStrEqual(bodyNode->name, (const xmlChar *) "Fault")) {
										SOAPFault *bodyObject = [SOAPFault deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
								}
							}
						
							response.bodyParts = responseBodyParts;
						}
					}
				}
			
				xmlFreeDoc(doc);
			}
			if(delegate != nil && [delegate respondsToSelector:@selector(operation:completedWithResponse:)] == YES) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[delegate operation:self completedWithResponse:response];
				});
			}
		});
	}
}
@end
@implementation LibreAccessService_1_2_0Soap11Binding_ListBooksAssignment
@synthesize body;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
body:(tns1_ListBooksAssignmentRequest *)aBody
{
	if((self = [super initWithBinding:aBinding delegate:responseDelegate])) {
		self.body = aBody;
	}
	
	return self;
}
- (void)dealloc
{
	if(body != nil) [body release];
	
	[super dealloc];
}
- (void)main
{
	[response autorelease];
	response = [LibreAccessService_1_2_0Soap11BindingResponse new];
	
	LibreAccessService_1_2_0Soap11Binding_envelope *envelope = [LibreAccessService_1_2_0Soap11Binding_envelope sharedInstance];
	
	NSMutableDictionary *headerElements = nil;
	headerElements = [NSMutableDictionary dictionary];
	
	NSMutableDictionary *bodyElements = nil;
	NSMutableArray *bodyKeys = nil;
	bodyElements = [NSMutableDictionary dictionary];
	bodyKeys = [NSMutableArray array];
	id obj;
	obj = nil;
	if(body != nil) obj = body;
	if(obj != nil) {
		[bodyElements setObject:obj forKey:@"ListBooksAssignmentRequest"];
		[bodyKeys addObject:@"ListBooksAssignmentRequest"];
	}
	
	NSString *operationXMLString = [envelope serializedFormUsingHeaderElements:headerElements bodyElements:bodyElements bodyKeys:bodyKeys];
	
	[binding sendHTTPCallUsingBody:operationXMLString soapAction:@"http://webservices.libredigital.com/libreaccess/ListBooksAssignment" forOperation:self];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (responseData != nil && delegate != nil)
	{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			xmlDocPtr doc;
			xmlNodePtr cur;
		
			if (binding.logXMLInOut) {
				NSLog(@"ResponseBody:\n%@", [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease]);
			}
		
#if !TARGET_OS_IPHONE && (!defined(MAC_OS_X_VERSION_10_6) || MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_6)
	// Not yet defined in 10.5 libxml
	#define XML_PARSE_COMPACT 0
#endif
			doc = xmlReadMemory([responseData bytes], [responseData length], NULL, NULL, XML_PARSE_COMPACT | XML_PARSE_NOBLANKS);
		
			if (doc == NULL) {
				NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Errors while parsing returned XML" forKey:NSLocalizedDescriptionKey];
			
				response.error = [NSError errorWithDomain:@"LibreAccessService_1_2_0Soap11BindingResponseXML" code:1 userInfo:userInfo];
			} else {
				cur = xmlDocGetRootElement(doc);
				cur = cur->children;
			
				for( ; cur != NULL ; cur = cur->next) {
					if(cur->type == XML_ELEMENT_NODE) {
					
						if(xmlStrEqual(cur->name, (const xmlChar *) "Body")) {
							NSMutableArray *responseBodyParts = [NSMutableArray array];
						
							xmlNodePtr bodyNode;
							for(bodyNode=cur->children ; bodyNode != NULL ; bodyNode = bodyNode->next) {
								if(cur->type == XML_ELEMENT_NODE) {
									if(xmlStrEqual(bodyNode->name, (const xmlChar *) "ListBooksAssignmentResponse")) {
										tns1_ListBooksAssignmentResponse *bodyObject = [tns1_ListBooksAssignmentResponse deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
									if ((bodyNode->ns != nil && xmlStrEqual(bodyNode->ns->prefix, cur->ns->prefix)) && 
										xmlStrEqual(bodyNode->name, (const xmlChar *) "Fault")) {
										SOAPFault *bodyObject = [SOAPFault deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
								}
							}
						
							response.bodyParts = responseBodyParts;
						}
					}
				}
			
				xmlFreeDoc(doc);
			}
			if(delegate != nil && [delegate respondsToSelector:@selector(operation:completedWithResponse:)] == YES) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[delegate operation:self completedWithResponse:response];
				});
			}
		});
	}
}
@end
@implementation LibreAccessService_1_2_0Soap11Binding_AcknowledgeLicense
@synthesize parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
parameters:(tns1_AcknowledgeLicenseRequest *)aParameters
{
	if((self = [super initWithBinding:aBinding delegate:responseDelegate])) {
		self.parameters = aParameters;
	}
	
	return self;
}
- (void)dealloc
{
	if(parameters != nil) [parameters release];
	
	[super dealloc];
}
- (void)main
{
	[response autorelease];
	response = [LibreAccessService_1_2_0Soap11BindingResponse new];
	
	LibreAccessService_1_2_0Soap11Binding_envelope *envelope = [LibreAccessService_1_2_0Soap11Binding_envelope sharedInstance];
	
	NSMutableDictionary *headerElements = nil;
	headerElements = [NSMutableDictionary dictionary];
	
	NSMutableDictionary *bodyElements = nil;
	NSMutableArray *bodyKeys = nil;
	bodyElements = [NSMutableDictionary dictionary];
	bodyKeys = [NSMutableArray array];
	id obj;
	obj = nil;
	if(parameters != nil) obj = parameters;
	if(obj != nil) {
		[bodyElements setObject:obj forKey:@"AcknowledgeLicenseRequest"];
		[bodyKeys addObject:@"AcknowledgeLicenseRequest"];
	}
	
	NSString *operationXMLString = [envelope serializedFormUsingHeaderElements:headerElements bodyElements:bodyElements bodyKeys:bodyKeys];
	
	[binding sendHTTPCallUsingBody:operationXMLString soapAction:@"http://webservices.libredigital.com/libreaccess/AcknowledgeLicense" forOperation:self];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (responseData != nil && delegate != nil)
	{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			xmlDocPtr doc;
			xmlNodePtr cur;
		
			if (binding.logXMLInOut) {
				NSLog(@"ResponseBody:\n%@", [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease]);
			}
		
#if !TARGET_OS_IPHONE && (!defined(MAC_OS_X_VERSION_10_6) || MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_6)
	// Not yet defined in 10.5 libxml
	#define XML_PARSE_COMPACT 0
#endif
			doc = xmlReadMemory([responseData bytes], [responseData length], NULL, NULL, XML_PARSE_COMPACT | XML_PARSE_NOBLANKS);
		
			if (doc == NULL) {
				NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Errors while parsing returned XML" forKey:NSLocalizedDescriptionKey];
			
				response.error = [NSError errorWithDomain:@"LibreAccessService_1_2_0Soap11BindingResponseXML" code:1 userInfo:userInfo];
			} else {
				cur = xmlDocGetRootElement(doc);
				cur = cur->children;
			
				for( ; cur != NULL ; cur = cur->next) {
					if(cur->type == XML_ELEMENT_NODE) {
					
						if(xmlStrEqual(cur->name, (const xmlChar *) "Body")) {
							NSMutableArray *responseBodyParts = [NSMutableArray array];
						
							xmlNodePtr bodyNode;
							for(bodyNode=cur->children ; bodyNode != NULL ; bodyNode = bodyNode->next) {
								if(cur->type == XML_ELEMENT_NODE) {
									if(xmlStrEqual(bodyNode->name, (const xmlChar *) "AcknowledgeLicenseResponse")) {
										tns1_AcknowledgeLicenseResponse *bodyObject = [tns1_AcknowledgeLicenseResponse deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
									if ((bodyNode->ns != nil && xmlStrEqual(bodyNode->ns->prefix, cur->ns->prefix)) && 
										xmlStrEqual(bodyNode->name, (const xmlChar *) "Fault")) {
										SOAPFault *bodyObject = [SOAPFault deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
								}
							}
						
							response.bodyParts = responseBodyParts;
						}
					}
				}
			
				xmlFreeDoc(doc);
			}
			if(delegate != nil && [delegate respondsToSelector:@selector(operation:completedWithResponse:)] == YES) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[delegate operation:self completedWithResponse:response];
				});
			}
		});
	}
}
@end
@implementation LibreAccessService_1_2_0Soap11Binding_SharedTokenExchange
@synthesize body;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
body:(tns1_SharedTokenExchangeRequest *)aBody
{
	if((self = [super initWithBinding:aBinding delegate:responseDelegate])) {
		self.body = aBody;
	}
	
	return self;
}
- (void)dealloc
{
	if(body != nil) [body release];
	
	[super dealloc];
}
- (void)main
{
	[response autorelease];
	response = [LibreAccessService_1_2_0Soap11BindingResponse new];
	
	LibreAccessService_1_2_0Soap11Binding_envelope *envelope = [LibreAccessService_1_2_0Soap11Binding_envelope sharedInstance];
	
	NSMutableDictionary *headerElements = nil;
	headerElements = [NSMutableDictionary dictionary];
	
	NSMutableDictionary *bodyElements = nil;
	NSMutableArray *bodyKeys = nil;
	bodyElements = [NSMutableDictionary dictionary];
	bodyKeys = [NSMutableArray array];
	id obj;
	obj = nil;
	if(body != nil) obj = body;
	if(obj != nil) {
		[bodyElements setObject:obj forKey:@"SharedTokenExchangeRequest"];
		[bodyKeys addObject:@"SharedTokenExchangeRequest"];
	}
	
	NSString *operationXMLString = [envelope serializedFormUsingHeaderElements:headerElements bodyElements:bodyElements bodyKeys:bodyKeys];
	
	[binding sendHTTPCallUsingBody:operationXMLString soapAction:@"http://webservices.libredigital.com/libreaccess/SharedTokenExchange" forOperation:self];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (responseData != nil && delegate != nil)
	{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			xmlDocPtr doc;
			xmlNodePtr cur;
		
			if (binding.logXMLInOut) {
				NSLog(@"ResponseBody:\n%@", [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease]);
			}
		
#if !TARGET_OS_IPHONE && (!defined(MAC_OS_X_VERSION_10_6) || MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_6)
	// Not yet defined in 10.5 libxml
	#define XML_PARSE_COMPACT 0
#endif
			doc = xmlReadMemory([responseData bytes], [responseData length], NULL, NULL, XML_PARSE_COMPACT | XML_PARSE_NOBLANKS);
		
			if (doc == NULL) {
				NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Errors while parsing returned XML" forKey:NSLocalizedDescriptionKey];
			
				response.error = [NSError errorWithDomain:@"LibreAccessService_1_2_0Soap11BindingResponseXML" code:1 userInfo:userInfo];
			} else {
				cur = xmlDocGetRootElement(doc);
				cur = cur->children;
			
				for( ; cur != NULL ; cur = cur->next) {
					if(cur->type == XML_ELEMENT_NODE) {
					
						if(xmlStrEqual(cur->name, (const xmlChar *) "Body")) {
							NSMutableArray *responseBodyParts = [NSMutableArray array];
						
							xmlNodePtr bodyNode;
							for(bodyNode=cur->children ; bodyNode != NULL ; bodyNode = bodyNode->next) {
								if(cur->type == XML_ELEMENT_NODE) {
									if(xmlStrEqual(bodyNode->name, (const xmlChar *) "SharedTokenExchangeResponse")) {
										tns1_SharedTokenExchangeResponse *bodyObject = [tns1_SharedTokenExchangeResponse deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
									if ((bodyNode->ns != nil && xmlStrEqual(bodyNode->ns->prefix, cur->ns->prefix)) && 
										xmlStrEqual(bodyNode->name, (const xmlChar *) "Fault")) {
										SOAPFault *bodyObject = [SOAPFault deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
								}
							}
						
							response.bodyParts = responseBodyParts;
						}
					}
				}
			
				xmlFreeDoc(doc);
			}
			if(delegate != nil && [delegate respondsToSelector:@selector(operation:completedWithResponse:)] == YES) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[delegate operation:self completedWithResponse:response];
				});
			}
		});
	}
}
@end
@implementation LibreAccessService_1_2_0Soap11Binding_DeviceLeftDomain
@synthesize parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
parameters:(tns1_DeviceLeftDomainRequest *)aParameters
{
	if((self = [super initWithBinding:aBinding delegate:responseDelegate])) {
		self.parameters = aParameters;
	}
	
	return self;
}
- (void)dealloc
{
	if(parameters != nil) [parameters release];
	
	[super dealloc];
}
- (void)main
{
	[response autorelease];
	response = [LibreAccessService_1_2_0Soap11BindingResponse new];
	
	LibreAccessService_1_2_0Soap11Binding_envelope *envelope = [LibreAccessService_1_2_0Soap11Binding_envelope sharedInstance];
	
	NSMutableDictionary *headerElements = nil;
	headerElements = [NSMutableDictionary dictionary];
	
	NSMutableDictionary *bodyElements = nil;
	NSMutableArray *bodyKeys = nil;
	bodyElements = [NSMutableDictionary dictionary];
	bodyKeys = [NSMutableArray array];
	id obj;
	obj = nil;
	if(parameters != nil) obj = parameters;
	if(obj != nil) {
		[bodyElements setObject:obj forKey:@"DeviceLeftDomainRequest"];
		[bodyKeys addObject:@"DeviceLeftDomainRequest"];
	}
	
	NSString *operationXMLString = [envelope serializedFormUsingHeaderElements:headerElements bodyElements:bodyElements bodyKeys:bodyKeys];
	
	[binding sendHTTPCallUsingBody:operationXMLString soapAction:@"http://webservices.libredigital.com/libreaccess/DeviceLeftDomain" forOperation:self];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (responseData != nil && delegate != nil)
	{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			xmlDocPtr doc;
			xmlNodePtr cur;
		
			if (binding.logXMLInOut) {
				NSLog(@"ResponseBody:\n%@", [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease]);
			}
		
#if !TARGET_OS_IPHONE && (!defined(MAC_OS_X_VERSION_10_6) || MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_6)
	// Not yet defined in 10.5 libxml
	#define XML_PARSE_COMPACT 0
#endif
			doc = xmlReadMemory([responseData bytes], [responseData length], NULL, NULL, XML_PARSE_COMPACT | XML_PARSE_NOBLANKS);
		
			if (doc == NULL) {
				NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Errors while parsing returned XML" forKey:NSLocalizedDescriptionKey];
			
				response.error = [NSError errorWithDomain:@"LibreAccessService_1_2_0Soap11BindingResponseXML" code:1 userInfo:userInfo];
			} else {
				cur = xmlDocGetRootElement(doc);
				cur = cur->children;
			
				for( ; cur != NULL ; cur = cur->next) {
					if(cur->type == XML_ELEMENT_NODE) {
					
						if(xmlStrEqual(cur->name, (const xmlChar *) "Body")) {
							NSMutableArray *responseBodyParts = [NSMutableArray array];
						
							xmlNodePtr bodyNode;
							for(bodyNode=cur->children ; bodyNode != NULL ; bodyNode = bodyNode->next) {
								if(cur->type == XML_ELEMENT_NODE) {
									if(xmlStrEqual(bodyNode->name, (const xmlChar *) "DeviceLeftDomainResponse")) {
										tns1_DeviceLeftDomainResponse *bodyObject = [tns1_DeviceLeftDomainResponse deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
									if ((bodyNode->ns != nil && xmlStrEqual(bodyNode->ns->prefix, cur->ns->prefix)) && 
										xmlStrEqual(bodyNode->name, (const xmlChar *) "Fault")) {
										SOAPFault *bodyObject = [SOAPFault deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
								}
							}
						
							response.bodyParts = responseBodyParts;
						}
					}
				}
			
				xmlFreeDoc(doc);
			}
			if(delegate != nil && [delegate respondsToSelector:@selector(operation:completedWithResponse:)] == YES) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[delegate operation:self completedWithResponse:response];
				});
			}
		});
	}
}
@end
@implementation LibreAccessService_1_2_0Soap11Binding_GetLicensableStatus
@synthesize parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
parameters:(tns1_GetLicensableStatusRequest *)aParameters
{
	if((self = [super initWithBinding:aBinding delegate:responseDelegate])) {
		self.parameters = aParameters;
	}
	
	return self;
}
- (void)dealloc
{
	if(parameters != nil) [parameters release];
	
	[super dealloc];
}
- (void)main
{
	[response autorelease];
	response = [LibreAccessService_1_2_0Soap11BindingResponse new];
	
	LibreAccessService_1_2_0Soap11Binding_envelope *envelope = [LibreAccessService_1_2_0Soap11Binding_envelope sharedInstance];
	
	NSMutableDictionary *headerElements = nil;
	headerElements = [NSMutableDictionary dictionary];
	
	NSMutableDictionary *bodyElements = nil;
	NSMutableArray *bodyKeys = nil;
	bodyElements = [NSMutableDictionary dictionary];
	bodyKeys = [NSMutableArray array];
	id obj;
	obj = nil;
	if(parameters != nil) obj = parameters;
	if(obj != nil) {
		[bodyElements setObject:obj forKey:@"GetLicensableStatusRequest"];
		[bodyKeys addObject:@"GetLicensableStatusRequest"];
	}
	
	NSString *operationXMLString = [envelope serializedFormUsingHeaderElements:headerElements bodyElements:bodyElements bodyKeys:bodyKeys];
	
	[binding sendHTTPCallUsingBody:operationXMLString soapAction:@"http://webservices.libredigital.com/libreaccess/GetLicensableStatus" forOperation:self];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (responseData != nil && delegate != nil)
	{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			xmlDocPtr doc;
			xmlNodePtr cur;
		
			if (binding.logXMLInOut) {
				NSLog(@"ResponseBody:\n%@", [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease]);
			}
		
#if !TARGET_OS_IPHONE && (!defined(MAC_OS_X_VERSION_10_6) || MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_6)
	// Not yet defined in 10.5 libxml
	#define XML_PARSE_COMPACT 0
#endif
			doc = xmlReadMemory([responseData bytes], [responseData length], NULL, NULL, XML_PARSE_COMPACT | XML_PARSE_NOBLANKS);
		
			if (doc == NULL) {
				NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Errors while parsing returned XML" forKey:NSLocalizedDescriptionKey];
			
				response.error = [NSError errorWithDomain:@"LibreAccessService_1_2_0Soap11BindingResponseXML" code:1 userInfo:userInfo];
			} else {
				cur = xmlDocGetRootElement(doc);
				cur = cur->children;
			
				for( ; cur != NULL ; cur = cur->next) {
					if(cur->type == XML_ELEMENT_NODE) {
					
						if(xmlStrEqual(cur->name, (const xmlChar *) "Body")) {
							NSMutableArray *responseBodyParts = [NSMutableArray array];
						
							xmlNodePtr bodyNode;
							for(bodyNode=cur->children ; bodyNode != NULL ; bodyNode = bodyNode->next) {
								if(cur->type == XML_ELEMENT_NODE) {
									if(xmlStrEqual(bodyNode->name, (const xmlChar *) "GetLicensableStatusResponse")) {
										tns1_GetLicensableStatusResponse *bodyObject = [tns1_GetLicensableStatusResponse deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
									if ((bodyNode->ns != nil && xmlStrEqual(bodyNode->ns->prefix, cur->ns->prefix)) && 
										xmlStrEqual(bodyNode->name, (const xmlChar *) "Fault")) {
										SOAPFault *bodyObject = [SOAPFault deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
								}
							}
						
							response.bodyParts = responseBodyParts;
						}
					}
				}
			
				xmlFreeDoc(doc);
			}
			if(delegate != nil && [delegate respondsToSelector:@selector(operation:completedWithResponse:)] == YES) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[delegate operation:self completedWithResponse:response];
				});
			}
		});
	}
}
@end
@implementation LibreAccessService_1_2_0Soap11Binding_ListReadingStatisticsMonthlyAverage
@synthesize parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
parameters:(tns1_ListReadingStatisticsMonthlyAverageRequest *)aParameters
{
	if((self = [super initWithBinding:aBinding delegate:responseDelegate])) {
		self.parameters = aParameters;
	}
	
	return self;
}
- (void)dealloc
{
	if(parameters != nil) [parameters release];
	
	[super dealloc];
}
- (void)main
{
	[response autorelease];
	response = [LibreAccessService_1_2_0Soap11BindingResponse new];
	
	LibreAccessService_1_2_0Soap11Binding_envelope *envelope = [LibreAccessService_1_2_0Soap11Binding_envelope sharedInstance];
	
	NSMutableDictionary *headerElements = nil;
	headerElements = [NSMutableDictionary dictionary];
	
	NSMutableDictionary *bodyElements = nil;
	NSMutableArray *bodyKeys = nil;
	bodyElements = [NSMutableDictionary dictionary];
	bodyKeys = [NSMutableArray array];
	id obj;
	obj = nil;
	if(parameters != nil) obj = parameters;
	if(obj != nil) {
		[bodyElements setObject:obj forKey:@"ListReadingStatisticsMonthlyAverageRequest"];
		[bodyKeys addObject:@"ListReadingStatisticsMonthlyAverageRequest"];
	}
	
	NSString *operationXMLString = [envelope serializedFormUsingHeaderElements:headerElements bodyElements:bodyElements bodyKeys:bodyKeys];
	
	[binding sendHTTPCallUsingBody:operationXMLString soapAction:@"http://webservices.libredigital.com/libreaccess/ListReadingStatisticsMonthlyAverage" forOperation:self];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (responseData != nil && delegate != nil)
	{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			xmlDocPtr doc;
			xmlNodePtr cur;
		
			if (binding.logXMLInOut) {
				NSLog(@"ResponseBody:\n%@", [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease]);
			}
		
#if !TARGET_OS_IPHONE && (!defined(MAC_OS_X_VERSION_10_6) || MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_6)
	// Not yet defined in 10.5 libxml
	#define XML_PARSE_COMPACT 0
#endif
			doc = xmlReadMemory([responseData bytes], [responseData length], NULL, NULL, XML_PARSE_COMPACT | XML_PARSE_NOBLANKS);
		
			if (doc == NULL) {
				NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Errors while parsing returned XML" forKey:NSLocalizedDescriptionKey];
			
				response.error = [NSError errorWithDomain:@"LibreAccessService_1_2_0Soap11BindingResponseXML" code:1 userInfo:userInfo];
			} else {
				cur = xmlDocGetRootElement(doc);
				cur = cur->children;
			
				for( ; cur != NULL ; cur = cur->next) {
					if(cur->type == XML_ELEMENT_NODE) {
					
						if(xmlStrEqual(cur->name, (const xmlChar *) "Body")) {
							NSMutableArray *responseBodyParts = [NSMutableArray array];
						
							xmlNodePtr bodyNode;
							for(bodyNode=cur->children ; bodyNode != NULL ; bodyNode = bodyNode->next) {
								if(cur->type == XML_ELEMENT_NODE) {
									if(xmlStrEqual(bodyNode->name, (const xmlChar *) "ListReadingStatisticsMonthlyAverageResponse")) {
										tns1_ListReadingStatisticsMonthlyAverageResponse *bodyObject = [tns1_ListReadingStatisticsMonthlyAverageResponse deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
									if ((bodyNode->ns != nil && xmlStrEqual(bodyNode->ns->prefix, cur->ns->prefix)) && 
										xmlStrEqual(bodyNode->name, (const xmlChar *) "Fault")) {
										SOAPFault *bodyObject = [SOAPFault deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
								}
							}
						
							response.bodyParts = responseBodyParts;
						}
					}
				}
			
				xmlFreeDoc(doc);
			}
			if(delegate != nil && [delegate respondsToSelector:@selector(operation:completedWithResponse:)] == YES) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[delegate operation:self completedWithResponse:response];
				});
			}
		});
	}
}
@end
@implementation LibreAccessService_1_2_0Soap11Binding_ListReadBooks
@synthesize parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
parameters:(tns1_ListReadBooksRequest *)aParameters
{
	if((self = [super initWithBinding:aBinding delegate:responseDelegate])) {
		self.parameters = aParameters;
	}
	
	return self;
}
- (void)dealloc
{
	if(parameters != nil) [parameters release];
	
	[super dealloc];
}
- (void)main
{
	[response autorelease];
	response = [LibreAccessService_1_2_0Soap11BindingResponse new];
	
	LibreAccessService_1_2_0Soap11Binding_envelope *envelope = [LibreAccessService_1_2_0Soap11Binding_envelope sharedInstance];
	
	NSMutableDictionary *headerElements = nil;
	headerElements = [NSMutableDictionary dictionary];
	
	NSMutableDictionary *bodyElements = nil;
	NSMutableArray *bodyKeys = nil;
	bodyElements = [NSMutableDictionary dictionary];
	bodyKeys = [NSMutableArray array];
	id obj;
	obj = nil;
	if(parameters != nil) obj = parameters;
	if(obj != nil) {
		[bodyElements setObject:obj forKey:@"ListReadBooksRequest"];
		[bodyKeys addObject:@"ListReadBooksRequest"];
	}
	
	NSString *operationXMLString = [envelope serializedFormUsingHeaderElements:headerElements bodyElements:bodyElements bodyKeys:bodyKeys];
	
	[binding sendHTTPCallUsingBody:operationXMLString soapAction:@"http://webservices.libredigital.com/libreaccess/ListReadBooks" forOperation:self];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (responseData != nil && delegate != nil)
	{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			xmlDocPtr doc;
			xmlNodePtr cur;
		
			if (binding.logXMLInOut) {
				NSLog(@"ResponseBody:\n%@", [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease]);
			}
		
#if !TARGET_OS_IPHONE && (!defined(MAC_OS_X_VERSION_10_6) || MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_6)
	// Not yet defined in 10.5 libxml
	#define XML_PARSE_COMPACT 0
#endif
			doc = xmlReadMemory([responseData bytes], [responseData length], NULL, NULL, XML_PARSE_COMPACT | XML_PARSE_NOBLANKS);
		
			if (doc == NULL) {
				NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Errors while parsing returned XML" forKey:NSLocalizedDescriptionKey];
			
				response.error = [NSError errorWithDomain:@"LibreAccessService_1_2_0Soap11BindingResponseXML" code:1 userInfo:userInfo];
			} else {
				cur = xmlDocGetRootElement(doc);
				cur = cur->children;
			
				for( ; cur != NULL ; cur = cur->next) {
					if(cur->type == XML_ELEMENT_NODE) {
					
						if(xmlStrEqual(cur->name, (const xmlChar *) "Body")) {
							NSMutableArray *responseBodyParts = [NSMutableArray array];
						
							xmlNodePtr bodyNode;
							for(bodyNode=cur->children ; bodyNode != NULL ; bodyNode = bodyNode->next) {
								if(cur->type == XML_ELEMENT_NODE) {
									if(xmlStrEqual(bodyNode->name, (const xmlChar *) "ListReadBooksResponse")) {
										tns1_ListReadBooksResponse *bodyObject = [tns1_ListReadBooksResponse deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
									if ((bodyNode->ns != nil && xmlStrEqual(bodyNode->ns->prefix, cur->ns->prefix)) && 
										xmlStrEqual(bodyNode->name, (const xmlChar *) "Fault")) {
										SOAPFault *bodyObject = [SOAPFault deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
								}
							}
						
							response.bodyParts = responseBodyParts;
						}
					}
				}
			
				xmlFreeDoc(doc);
			}
			if(delegate != nil && [delegate respondsToSelector:@selector(operation:completedWithResponse:)] == YES) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[delegate operation:self completedWithResponse:response];
				});
			}
		});
	}
}
@end
@implementation LibreAccessService_1_2_0Soap11Binding_ValidateUserKey
@synthesize parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
parameters:(tns1_ValidateUserKeyRequest *)aParameters
{
	if((self = [super initWithBinding:aBinding delegate:responseDelegate])) {
		self.parameters = aParameters;
	}
	
	return self;
}
- (void)dealloc
{
	if(parameters != nil) [parameters release];
	
	[super dealloc];
}
- (void)main
{
	[response autorelease];
	response = [LibreAccessService_1_2_0Soap11BindingResponse new];
	
	LibreAccessService_1_2_0Soap11Binding_envelope *envelope = [LibreAccessService_1_2_0Soap11Binding_envelope sharedInstance];
	
	NSMutableDictionary *headerElements = nil;
	headerElements = [NSMutableDictionary dictionary];
	
	NSMutableDictionary *bodyElements = nil;
	NSMutableArray *bodyKeys = nil;
	bodyElements = [NSMutableDictionary dictionary];
	bodyKeys = [NSMutableArray array];
	id obj;
	obj = nil;
	if(parameters != nil) obj = parameters;
	if(obj != nil) {
		[bodyElements setObject:obj forKey:@"ValidateUserKeyRequest"];
		[bodyKeys addObject:@"ValidateUserKeyRequest"];
	}
	
	NSString *operationXMLString = [envelope serializedFormUsingHeaderElements:headerElements bodyElements:bodyElements bodyKeys:bodyKeys];
	
	[binding sendHTTPCallUsingBody:operationXMLString soapAction:@"http://webservices.libredigital.com/libreaccess/ValidateUserKey" forOperation:self];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (responseData != nil && delegate != nil)
	{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			xmlDocPtr doc;
			xmlNodePtr cur;
		
			if (binding.logXMLInOut) {
				NSLog(@"ResponseBody:\n%@", [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease]);
			}
		
#if !TARGET_OS_IPHONE && (!defined(MAC_OS_X_VERSION_10_6) || MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_6)
	// Not yet defined in 10.5 libxml
	#define XML_PARSE_COMPACT 0
#endif
			doc = xmlReadMemory([responseData bytes], [responseData length], NULL, NULL, XML_PARSE_COMPACT | XML_PARSE_NOBLANKS);
		
			if (doc == NULL) {
				NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Errors while parsing returned XML" forKey:NSLocalizedDescriptionKey];
			
				response.error = [NSError errorWithDomain:@"LibreAccessService_1_2_0Soap11BindingResponseXML" code:1 userInfo:userInfo];
			} else {
				cur = xmlDocGetRootElement(doc);
				cur = cur->children;
			
				for( ; cur != NULL ; cur = cur->next) {
					if(cur->type == XML_ELEMENT_NODE) {
					
						if(xmlStrEqual(cur->name, (const xmlChar *) "Body")) {
							NSMutableArray *responseBodyParts = [NSMutableArray array];
						
							xmlNodePtr bodyNode;
							for(bodyNode=cur->children ; bodyNode != NULL ; bodyNode = bodyNode->next) {
								if(cur->type == XML_ELEMENT_NODE) {
									if(xmlStrEqual(bodyNode->name, (const xmlChar *) "ValidateUserKeyResponse")) {
										tns1_ValidateUserKeyResponse *bodyObject = [tns1_ValidateUserKeyResponse deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
									if ((bodyNode->ns != nil && xmlStrEqual(bodyNode->ns->prefix, cur->ns->prefix)) && 
										xmlStrEqual(bodyNode->name, (const xmlChar *) "Fault")) {
										SOAPFault *bodyObject = [SOAPFault deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
								}
							}
						
							response.bodyParts = responseBodyParts;
						}
					}
				}
			
				xmlFreeDoc(doc);
			}
			if(delegate != nil && [delegate respondsToSelector:@selector(operation:completedWithResponse:)] == YES) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[delegate operation:self completedWithResponse:response];
				});
			}
		});
	}
}
@end
@implementation LibreAccessService_1_2_0Soap11Binding_ListUserCSRNotes
@synthesize parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
parameters:(tns1_ListUserCSRNotesRequest *)aParameters
{
	if((self = [super initWithBinding:aBinding delegate:responseDelegate])) {
		self.parameters = aParameters;
	}
	
	return self;
}
- (void)dealloc
{
	if(parameters != nil) [parameters release];
	
	[super dealloc];
}
- (void)main
{
	[response autorelease];
	response = [LibreAccessService_1_2_0Soap11BindingResponse new];
	
	LibreAccessService_1_2_0Soap11Binding_envelope *envelope = [LibreAccessService_1_2_0Soap11Binding_envelope sharedInstance];
	
	NSMutableDictionary *headerElements = nil;
	headerElements = [NSMutableDictionary dictionary];
	
	NSMutableDictionary *bodyElements = nil;
	NSMutableArray *bodyKeys = nil;
	bodyElements = [NSMutableDictionary dictionary];
	bodyKeys = [NSMutableArray array];
	id obj;
	obj = nil;
	if(parameters != nil) obj = parameters;
	if(obj != nil) {
		[bodyElements setObject:obj forKey:@"ListUserCSRNotesRequest"];
		[bodyKeys addObject:@"ListUserCSRNotesRequest"];
	}
	
	NSString *operationXMLString = [envelope serializedFormUsingHeaderElements:headerElements bodyElements:bodyElements bodyKeys:bodyKeys];
	
	[binding sendHTTPCallUsingBody:operationXMLString soapAction:@"http://webservices.libredigital.com/libreaccess/ListUserCSRNotes" forOperation:self];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (responseData != nil && delegate != nil)
	{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			xmlDocPtr doc;
			xmlNodePtr cur;
		
			if (binding.logXMLInOut) {
				NSLog(@"ResponseBody:\n%@", [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease]);
			}
		
#if !TARGET_OS_IPHONE && (!defined(MAC_OS_X_VERSION_10_6) || MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_6)
	// Not yet defined in 10.5 libxml
	#define XML_PARSE_COMPACT 0
#endif
			doc = xmlReadMemory([responseData bytes], [responseData length], NULL, NULL, XML_PARSE_COMPACT | XML_PARSE_NOBLANKS);
		
			if (doc == NULL) {
				NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Errors while parsing returned XML" forKey:NSLocalizedDescriptionKey];
			
				response.error = [NSError errorWithDomain:@"LibreAccessService_1_2_0Soap11BindingResponseXML" code:1 userInfo:userInfo];
			} else {
				cur = xmlDocGetRootElement(doc);
				cur = cur->children;
			
				for( ; cur != NULL ; cur = cur->next) {
					if(cur->type == XML_ELEMENT_NODE) {
					
						if(xmlStrEqual(cur->name, (const xmlChar *) "Body")) {
							NSMutableArray *responseBodyParts = [NSMutableArray array];
						
							xmlNodePtr bodyNode;
							for(bodyNode=cur->children ; bodyNode != NULL ; bodyNode = bodyNode->next) {
								if(cur->type == XML_ELEMENT_NODE) {
									if(xmlStrEqual(bodyNode->name, (const xmlChar *) "ListUserCSRNotesResponse")) {
										tns1_ListUserCSRNotesResponse *bodyObject = [tns1_ListUserCSRNotesResponse deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
									if ((bodyNode->ns != nil && xmlStrEqual(bodyNode->ns->prefix, cur->ns->prefix)) && 
										xmlStrEqual(bodyNode->name, (const xmlChar *) "Fault")) {
										SOAPFault *bodyObject = [SOAPFault deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
								}
							}
						
							response.bodyParts = responseBodyParts;
						}
					}
				}
			
				xmlFreeDoc(doc);
			}
			if(delegate != nil && [delegate respondsToSelector:@selector(operation:completedWithResponse:)] == YES) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[delegate operation:self completedWithResponse:response];
				});
			}
		});
	}
}
@end
@implementation LibreAccessService_1_2_0Soap11Binding_SaveLastPageLocation
@synthesize parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
parameters:(tns1_SaveLastPageLocationRequest *)aParameters
{
	if((self = [super initWithBinding:aBinding delegate:responseDelegate])) {
		self.parameters = aParameters;
	}
	
	return self;
}
- (void)dealloc
{
	if(parameters != nil) [parameters release];
	
	[super dealloc];
}
- (void)main
{
	[response autorelease];
	response = [LibreAccessService_1_2_0Soap11BindingResponse new];
	
	LibreAccessService_1_2_0Soap11Binding_envelope *envelope = [LibreAccessService_1_2_0Soap11Binding_envelope sharedInstance];
	
	NSMutableDictionary *headerElements = nil;
	headerElements = [NSMutableDictionary dictionary];
	
	NSMutableDictionary *bodyElements = nil;
	NSMutableArray *bodyKeys = nil;
	bodyElements = [NSMutableDictionary dictionary];
	bodyKeys = [NSMutableArray array];
	id obj;
	obj = nil;
	if(parameters != nil) obj = parameters;
	if(obj != nil) {
		[bodyElements setObject:obj forKey:@"SaveLastPageLocationRequest"];
		[bodyKeys addObject:@"SaveLastPageLocationRequest"];
	}
	
	NSString *operationXMLString = [envelope serializedFormUsingHeaderElements:headerElements bodyElements:bodyElements bodyKeys:bodyKeys];
	
	[binding sendHTTPCallUsingBody:operationXMLString soapAction:@"http://webservices.libredigital.com/libreaccess/SaveLastPageLocation" forOperation:self];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (responseData != nil && delegate != nil)
	{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			xmlDocPtr doc;
			xmlNodePtr cur;
		
			if (binding.logXMLInOut) {
				NSLog(@"ResponseBody:\n%@", [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease]);
			}
		
#if !TARGET_OS_IPHONE && (!defined(MAC_OS_X_VERSION_10_6) || MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_6)
	// Not yet defined in 10.5 libxml
	#define XML_PARSE_COMPACT 0
#endif
			doc = xmlReadMemory([responseData bytes], [responseData length], NULL, NULL, XML_PARSE_COMPACT | XML_PARSE_NOBLANKS);
		
			if (doc == NULL) {
				NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Errors while parsing returned XML" forKey:NSLocalizedDescriptionKey];
			
				response.error = [NSError errorWithDomain:@"LibreAccessService_1_2_0Soap11BindingResponseXML" code:1 userInfo:userInfo];
			} else {
				cur = xmlDocGetRootElement(doc);
				cur = cur->children;
			
				for( ; cur != NULL ; cur = cur->next) {
					if(cur->type == XML_ELEMENT_NODE) {
					
						if(xmlStrEqual(cur->name, (const xmlChar *) "Body")) {
							NSMutableArray *responseBodyParts = [NSMutableArray array];
						
							xmlNodePtr bodyNode;
							for(bodyNode=cur->children ; bodyNode != NULL ; bodyNode = bodyNode->next) {
								if(cur->type == XML_ELEMENT_NODE) {
									if(xmlStrEqual(bodyNode->name, (const xmlChar *) "SaveLastPageLocationResponse")) {
										tns1_SaveLastPageLocationResponse *bodyObject = [tns1_SaveLastPageLocationResponse deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
									if ((bodyNode->ns != nil && xmlStrEqual(bodyNode->ns->prefix, cur->ns->prefix)) && 
										xmlStrEqual(bodyNode->name, (const xmlChar *) "Fault")) {
										SOAPFault *bodyObject = [SOAPFault deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
								}
							}
						
							response.bodyParts = responseBodyParts;
						}
					}
				}
			
				xmlFreeDoc(doc);
			}
			if(delegate != nil && [delegate respondsToSelector:@selector(operation:completedWithResponse:)] == YES) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[delegate operation:self completedWithResponse:response];
				});
			}
		});
	}
}
@end
@implementation LibreAccessService_1_2_0Soap11Binding_SaveRatings
@synthesize parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
parameters:(tns1_SaveRatingsRequest *)aParameters
{
	if((self = [super initWithBinding:aBinding delegate:responseDelegate])) {
		self.parameters = aParameters;
	}
	
	return self;
}
- (void)dealloc
{
	if(parameters != nil) [parameters release];
	
	[super dealloc];
}
- (void)main
{
	[response autorelease];
	response = [LibreAccessService_1_2_0Soap11BindingResponse new];
	
	LibreAccessService_1_2_0Soap11Binding_envelope *envelope = [LibreAccessService_1_2_0Soap11Binding_envelope sharedInstance];
	
	NSMutableDictionary *headerElements = nil;
	headerElements = [NSMutableDictionary dictionary];
	
	NSMutableDictionary *bodyElements = nil;
	NSMutableArray *bodyKeys = nil;
	bodyElements = [NSMutableDictionary dictionary];
	bodyKeys = [NSMutableArray array];
	id obj;
	obj = nil;
	if(parameters != nil) obj = parameters;
	if(obj != nil) {
		[bodyElements setObject:obj forKey:@"SaveRatingsRequest"];
		[bodyKeys addObject:@"SaveRatingsRequest"];
	}
	
	NSString *operationXMLString = [envelope serializedFormUsingHeaderElements:headerElements bodyElements:bodyElements bodyKeys:bodyKeys];
	
	[binding sendHTTPCallUsingBody:operationXMLString soapAction:@"http://webservices.libredigital.com/libreaccess/SaveRatings" forOperation:self];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (responseData != nil && delegate != nil)
	{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			xmlDocPtr doc;
			xmlNodePtr cur;
		
			if (binding.logXMLInOut) {
				NSLog(@"ResponseBody:\n%@", [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease]);
			}
		
#if !TARGET_OS_IPHONE && (!defined(MAC_OS_X_VERSION_10_6) || MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_6)
	// Not yet defined in 10.5 libxml
	#define XML_PARSE_COMPACT 0
#endif
			doc = xmlReadMemory([responseData bytes], [responseData length], NULL, NULL, XML_PARSE_COMPACT | XML_PARSE_NOBLANKS);
		
			if (doc == NULL) {
				NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Errors while parsing returned XML" forKey:NSLocalizedDescriptionKey];
			
				response.error = [NSError errorWithDomain:@"LibreAccessService_1_2_0Soap11BindingResponseXML" code:1 userInfo:userInfo];
			} else {
				cur = xmlDocGetRootElement(doc);
				cur = cur->children;
			
				for( ; cur != NULL ; cur = cur->next) {
					if(cur->type == XML_ELEMENT_NODE) {
					
						if(xmlStrEqual(cur->name, (const xmlChar *) "Body")) {
							NSMutableArray *responseBodyParts = [NSMutableArray array];
						
							xmlNodePtr bodyNode;
							for(bodyNode=cur->children ; bodyNode != NULL ; bodyNode = bodyNode->next) {
								if(cur->type == XML_ELEMENT_NODE) {
									if(xmlStrEqual(bodyNode->name, (const xmlChar *) "SaveRatingsResponse")) {
										tns1_SaveRatingsResponse *bodyObject = [tns1_SaveRatingsResponse deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
									if ((bodyNode->ns != nil && xmlStrEqual(bodyNode->ns->prefix, cur->ns->prefix)) && 
										xmlStrEqual(bodyNode->name, (const xmlChar *) "Fault")) {
										SOAPFault *bodyObject = [SOAPFault deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
								}
							}
						
							response.bodyParts = responseBodyParts;
						}
					}
				}
			
				xmlFreeDoc(doc);
			}
			if(delegate != nil && [delegate respondsToSelector:@selector(operation:completedWithResponse:)] == YES) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[delegate operation:self completedWithResponse:response];
				});
			}
		});
	}
}
@end
@implementation LibreAccessService_1_2_0Soap11Binding_ListUserSettings
@synthesize parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
parameters:(tns1_ListUserSettingsRequest *)aParameters
{
	if((self = [super initWithBinding:aBinding delegate:responseDelegate])) {
		self.parameters = aParameters;
	}
	
	return self;
}
- (void)dealloc
{
	if(parameters != nil) [parameters release];
	
	[super dealloc];
}
- (void)main
{
	[response autorelease];
	response = [LibreAccessService_1_2_0Soap11BindingResponse new];
	
	LibreAccessService_1_2_0Soap11Binding_envelope *envelope = [LibreAccessService_1_2_0Soap11Binding_envelope sharedInstance];
	
	NSMutableDictionary *headerElements = nil;
	headerElements = [NSMutableDictionary dictionary];
	
	NSMutableDictionary *bodyElements = nil;
	NSMutableArray *bodyKeys = nil;
	bodyElements = [NSMutableDictionary dictionary];
	bodyKeys = [NSMutableArray array];
	id obj;
	obj = nil;
	if(parameters != nil) obj = parameters;
	if(obj != nil) {
		[bodyElements setObject:obj forKey:@"ListUserSettingsRequest"];
		[bodyKeys addObject:@"ListUserSettingsRequest"];
	}
	
	NSString *operationXMLString = [envelope serializedFormUsingHeaderElements:headerElements bodyElements:bodyElements bodyKeys:bodyKeys];
	
	[binding sendHTTPCallUsingBody:operationXMLString soapAction:@"http://webservices.libredigital.com/libreaccess/ListUserSettings" forOperation:self];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (responseData != nil && delegate != nil)
	{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			xmlDocPtr doc;
			xmlNodePtr cur;
		
			if (binding.logXMLInOut) {
				NSLog(@"ResponseBody:\n%@", [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease]);
			}
		
#if !TARGET_OS_IPHONE && (!defined(MAC_OS_X_VERSION_10_6) || MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_6)
	// Not yet defined in 10.5 libxml
	#define XML_PARSE_COMPACT 0
#endif
			doc = xmlReadMemory([responseData bytes], [responseData length], NULL, NULL, XML_PARSE_COMPACT | XML_PARSE_NOBLANKS);
		
			if (doc == NULL) {
				NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Errors while parsing returned XML" forKey:NSLocalizedDescriptionKey];
			
				response.error = [NSError errorWithDomain:@"LibreAccessService_1_2_0Soap11BindingResponseXML" code:1 userInfo:userInfo];
			} else {
				cur = xmlDocGetRootElement(doc);
				cur = cur->children;
			
				for( ; cur != NULL ; cur = cur->next) {
					if(cur->type == XML_ELEMENT_NODE) {
					
						if(xmlStrEqual(cur->name, (const xmlChar *) "Body")) {
							NSMutableArray *responseBodyParts = [NSMutableArray array];
						
							xmlNodePtr bodyNode;
							for(bodyNode=cur->children ; bodyNode != NULL ; bodyNode = bodyNode->next) {
								if(cur->type == XML_ELEMENT_NODE) {
									if(xmlStrEqual(bodyNode->name, (const xmlChar *) "ListUserSettingsResponse")) {
										tns1_ListUserSettingsResponse *bodyObject = [tns1_ListUserSettingsResponse deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
									if ((bodyNode->ns != nil && xmlStrEqual(bodyNode->ns->prefix, cur->ns->prefix)) && 
										xmlStrEqual(bodyNode->name, (const xmlChar *) "Fault")) {
										SOAPFault *bodyObject = [SOAPFault deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
								}
							}
						
							response.bodyParts = responseBodyParts;
						}
					}
				}
			
				xmlFreeDoc(doc);
			}
			if(delegate != nil && [delegate respondsToSelector:@selector(operation:completedWithResponse:)] == YES) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[delegate operation:self completedWithResponse:response];
				});
			}
		});
	}
}
@end
@implementation LibreAccessService_1_2_0Soap11Binding_ListProfileContentAnnotations
@synthesize parameters;
- (id)initWithBinding:(LibreAccessService_1_2_0Soap11Binding *)aBinding delegate:(id<LibreAccessService_1_2_0Soap11BindingResponseDelegate>)responseDelegate
parameters:(tns1_ListProfileContentAnnotationsRequest *)aParameters
{
	if((self = [super initWithBinding:aBinding delegate:responseDelegate])) {
		self.parameters = aParameters;
	}
	
	return self;
}
- (void)dealloc
{
	if(parameters != nil) [parameters release];
	
	[super dealloc];
}
- (void)main
{
	[response autorelease];
	response = [LibreAccessService_1_2_0Soap11BindingResponse new];
	
	LibreAccessService_1_2_0Soap11Binding_envelope *envelope = [LibreAccessService_1_2_0Soap11Binding_envelope sharedInstance];
	
	NSMutableDictionary *headerElements = nil;
	headerElements = [NSMutableDictionary dictionary];
	
	NSMutableDictionary *bodyElements = nil;
	NSMutableArray *bodyKeys = nil;
	bodyElements = [NSMutableDictionary dictionary];
	bodyKeys = [NSMutableArray array];
	id obj;
	obj = nil;
	if(parameters != nil) obj = parameters;
	if(obj != nil) {
		[bodyElements setObject:obj forKey:@"ListProfileContentAnnotationsRequest"];
		[bodyKeys addObject:@"ListProfileContentAnnotationsRequest"];
	}
	
	NSString *operationXMLString = [envelope serializedFormUsingHeaderElements:headerElements bodyElements:bodyElements bodyKeys:bodyKeys];
	
	[binding sendHTTPCallUsingBody:operationXMLString soapAction:@"http://webservices.libredigital.com/libreaccess/ListProfileContentAnnotations" forOperation:self];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (responseData != nil && delegate != nil)
	{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			xmlDocPtr doc;
			xmlNodePtr cur;
		
			if (binding.logXMLInOut) {
				NSLog(@"ResponseBody:\n%@", [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease]);
			}
		
#if !TARGET_OS_IPHONE && (!defined(MAC_OS_X_VERSION_10_6) || MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_6)
	// Not yet defined in 10.5 libxml
	#define XML_PARSE_COMPACT 0
#endif
			doc = xmlReadMemory([responseData bytes], [responseData length], NULL, NULL, XML_PARSE_COMPACT | XML_PARSE_NOBLANKS);
		
			if (doc == NULL) {
				NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Errors while parsing returned XML" forKey:NSLocalizedDescriptionKey];
			
				response.error = [NSError errorWithDomain:@"LibreAccessService_1_2_0Soap11BindingResponseXML" code:1 userInfo:userInfo];
			} else {
				cur = xmlDocGetRootElement(doc);
				cur = cur->children;
			
				for( ; cur != NULL ; cur = cur->next) {
					if(cur->type == XML_ELEMENT_NODE) {
					
						if(xmlStrEqual(cur->name, (const xmlChar *) "Body")) {
							NSMutableArray *responseBodyParts = [NSMutableArray array];
						
							xmlNodePtr bodyNode;
							for(bodyNode=cur->children ; bodyNode != NULL ; bodyNode = bodyNode->next) {
								if(cur->type == XML_ELEMENT_NODE) {
									if(xmlStrEqual(bodyNode->name, (const xmlChar *) "ListProfileContentAnnotationsResponse")) {
										tns1_ListProfileContentAnnotationsResponse *bodyObject = [tns1_ListProfileContentAnnotationsResponse deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
									if ((bodyNode->ns != nil && xmlStrEqual(bodyNode->ns->prefix, cur->ns->prefix)) && 
										xmlStrEqual(bodyNode->name, (const xmlChar *) "Fault")) {
										SOAPFault *bodyObject = [SOAPFault deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
								}
							}
						
							response.bodyParts = responseBodyParts;
						}
					}
				}
			
				xmlFreeDoc(doc);
			}
			if(delegate != nil && [delegate respondsToSelector:@selector(operation:completedWithResponse:)] == YES) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[delegate operation:self completedWithResponse:response];
				});
			}
		});
	}
}
@end
static LibreAccessService_1_2_0Soap11Binding_envelope *LibreAccessService_1_2_0Soap11BindingSharedEnvelopeInstance = nil;
@implementation LibreAccessService_1_2_0Soap11Binding_envelope
+ (LibreAccessService_1_2_0Soap11Binding_envelope *)sharedInstance
{
	if(LibreAccessService_1_2_0Soap11BindingSharedEnvelopeInstance == nil) {
		LibreAccessService_1_2_0Soap11BindingSharedEnvelopeInstance = [LibreAccessService_1_2_0Soap11Binding_envelope new];
	}
	
	return LibreAccessService_1_2_0Soap11BindingSharedEnvelopeInstance;
}
- (NSString *)serializedFormUsingHeaderElements:(NSDictionary *)headerElements bodyElements:(NSDictionary *)bodyElements bodyKeys:(NSArray *)bodyKeys
{
	xmlDocPtr doc;
	
	doc = xmlNewDoc((const xmlChar*)XML_DEFAULT_VERSION);
	if (doc == NULL) {
		NSLog(@"Error creating the xml document tree");
		return @"";
	}
	
	xmlNodePtr root = xmlNewDocNode(doc, NULL, (const xmlChar*)"Envelope", NULL);
	xmlDocSetRootElement(doc, root);
	
	xmlNsPtr soapEnvelopeNs = xmlNewNs(root, (const xmlChar*)"http://schemas.xmlsoap.org/soap/envelope/", (const xmlChar*)"soap");
	xmlSetNs(root, soapEnvelopeNs);
	
	xmlNsPtr xslNs = xmlNewNs(root, (const xmlChar*)"http://www.w3.org/1999/XSL/Transform", (const xmlChar*)"xsl");
	xmlNewNs(root, (const xmlChar*)"http://www.w3.org/2001/XMLSchema-instance", (const xmlChar*)"xsi");
	
	xmlNewNsProp(root, xslNs, (const xmlChar*)"version", (const xmlChar*)"1.0");
	
	xmlNewNs(root, (const xmlChar*)"http://www.w3.org/2001/XMLSchema", (const xmlChar*)"xsd");
	xmlNewNs(root, (const xmlChar*)"http://webservices.libredigital.com/LibreAccess/v1.2.0", (const xmlChar*)"LibreAccessServiceSvc");
	xmlNewNs(root, (const xmlChar*)"http://webservices.libredigital.com/LibreAccess/schema/types/v1.2.0", (const xmlChar*)"tns1");
	
	if((headerElements != nil) && ([headerElements count] > 0)) {
		xmlNodePtr headerNode = xmlNewDocNode(doc, soapEnvelopeNs, (const xmlChar*)"Header", NULL);
		xmlAddChild(root, headerNode);
		
		for(NSString *key in [headerElements allKeys]) {
			id header = [headerElements objectForKey:key];
			xmlAddChild(headerNode, [header xmlNodeForDoc:doc elementName:key elementNSPrefix:nil]);
		}
	}
	
	if((bodyElements != nil) && ([bodyElements count] > 0)) {
		xmlNodePtr bodyNode = xmlNewDocNode(doc, soapEnvelopeNs, (const xmlChar*)"Body", NULL);
		xmlAddChild(root, bodyNode);
		
		for(NSString *key in bodyKeys) {
			id body = [bodyElements objectForKey:key];
			xmlAddChild(bodyNode, [body xmlNodeForDoc:doc elementName:key elementNSPrefix:[body nsPrefix]]);
		}
	}
	
	xmlChar *buf;
	int size;
	xmlDocDumpFormatMemory(doc, &buf, &size, 1);
	
	NSString *serializedForm = [NSString stringWithCString:(const char*)buf encoding:NSUTF8StringEncoding];
	xmlFree(buf);
	
	xmlFreeDoc(doc);	
	return serializedForm;
}
@end
@implementation LibreAccessService_1_2_0Soap11BindingResponse
@synthesize headers;
@synthesize bodyParts;
@synthesize error;
- (id)init
{
	if((self = [super init])) {
		headers = nil;
		bodyParts = nil;
		error = nil;
	}
	
	return self;
}
- (void)dealloc {
	self.headers = nil;
	self.bodyParts = nil;
	self.error = nil;	
	[super dealloc];
}
@end
