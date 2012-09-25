//
//  LibreAccessActivityLogSvc+Binding.h
//  Scholastic
//
//  Created by John S. Eddie on 04/09/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "LibreAccessActivityLogSvc.h"

// Re-define some elements of the generated web service to ease any WSDL changes

typedef LibreAccessActivityLogOldSoap11Binding LibreAccessActivityLogSoap11Binding;
typedef LibreAccessActivityLogOldSoap11BindingOperation LibreAccessActivityLogSoap11BindingOperation;
typedef LibreAccessActivityLogOldSoap11BindingResponse LibreAccessActivityLogSoap11BindingResponse;

@protocol LibreAccessActivityLogSoap11BindingResponseDelegate <LibreAccessActivityLogOldSoap11BindingResponseDelegate>
@end

typedef LibreAccessActivityLogOldSoap11Binding_SaveActivityLog LibreAccessActivityLogSoap11Binding_SaveActivityLog;

@interface LibreAccessActivityLogSvc (Binding)

+ (LibreAccessActivityLogSoap11Binding *)SCHLibreAccessActivityLogSoap11Binding;

@end
