//
//  NSNumber+ObjectTypes.m
//  Scholastic
//
//  Created by John S. Eddie on 17/01/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "NSNumber+ObjectTypes.h"


@implementation NSNumber (ObjectTypes)

+ (NSNumber *)numberWithStatus:(SCHStatus)value
{
	return([NSNumber numberWithInt:value]);	
}

- (id)initWithStatus:(SCHStatus)value
{
	return([self initWithInt:value]);
}

- (SCHStatus)statusValue
{
	return([self intValue]);
}

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

+ (NSNumber *)numberWithSaveAction:(SCHSaveActions)value
{
	return([NSNumber numberWithInt:value]);	
}

- (id)initWithSaveAction:(SCHSaveActions)value
{
	return([self initWithInt:value]);	
}

- (SCHSaveActions)saveActionValue
{
	return([self intValue]);	
}

+ (NSNumber *)numberWithUserSettingsType:(SCHUserSettingsTypes)value
{
	return([NSNumber numberWithInt:value]);		
}

- (id)initWithUserSettingsType:(SCHUserSettingsTypes)value
{
	return([self initWithInt:value]);		
}

- (SCHUserSettingsTypes)userSettingsTypeValue
{
	return([self intValue]);		
}

+ (NSNumber *)numberWithTopFavoritesType:(SCHTopFavoritesTypes)value
{
	return([NSNumber numberWithInt:value]);			
}

- (id)initWithTopFavoritesType:(SCHTopFavoritesTypes)value
{
	return([self initWithInt:value]);		
}

- (SCHTopFavoritesTypes)topFavoritesTypeValue
{
	return([self intValue]);		
}

@end
