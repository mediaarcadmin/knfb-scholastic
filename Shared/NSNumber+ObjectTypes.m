//
//  NSNumber+ObjectTypes.m
//  Scholastic
//
//  Created by John S. Eddie on 17/01/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "NSNumber+ObjectTypes.h"


@implementation NSNumber (ObjectTypes)

+ (NSNumber *)numberWithStatusCode:(SCHStatusCodes)value
{
	return([NSNumber numberWithInt:value]);	
}

- (id)initWithStatusCode:(SCHStatusCodes)value
{
	return([self initWithInt:value]);
}

- (SCHStatusCodes)statusCodeValue
{
	return([self intValue]);
}

+ (NSNumber *)numberWithProfileType:(SCHProfileTypes)value
{
	return([NSNumber numberWithInt:value]);
}

- (id)initWithProfileType:(SCHProfileTypes)value
{
	return([self initWithInt:value]);
}

- (SCHProfileTypes)profileTypeValue
{
	return([self intValue]);
}

+ (NSNumber *)numberWithBookshelfStyle:(SCHBookshelfStyles)value
{
	return([NSNumber numberWithInt:value]);
}

- (id)initWithBookshelfStyle:(SCHBookshelfStyles)value
{
	return([self initWithInt:value]);
}

- (SCHBookshelfStyles)bookshelfStyleValue
{
	return([self intValue]);	
}

+ (NSNumber *)numberWithContentIdentifierType:(SCHContentIdentifierTypes)value
{
	return([NSNumber numberWithInt:value]);	
}

- (id)initWithContentIdentifierType:(SCHContentIdentifierTypes)value
{
	return([self initWithInt:value]);	
}

- (SCHContentIdentifierTypes)contentIdentifierTypeValue
{
	return([self intValue]);	
}

+ (NSNumber *)numberWithDRMQualifier:(SCHDRMQualifiers)value
{
	return([NSNumber numberWithInt:value]);	
}

- (id)initWithDRMQualifier:(SCHDRMQualifiers)value
{
	return([self initWithInt:value]);	
}

- (SCHDRMQualifiers)DRMQualifierValue
{
	return([self intValue]);	
}

+ (NSNumber *)numberWithProductType:(SCHProductTypes)value
{
	return([NSNumber numberWithInt:value]);	
}

- (id)initWithProductType:(SCHProductTypes)value
{
	return([self initWithInt:value]);	
}

- (SCHProductTypes)ProductTypeValue
{
	return([self intValue]);	
}


@end
