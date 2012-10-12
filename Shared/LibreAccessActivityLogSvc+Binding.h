//
//  LibreAccessActivityLogSvc+Binding.h
//  Scholastic
//
//  Created by John S. Eddie on 04/09/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "LibreAccessActivityLogSvc.h"

// Re-define some elements of the generated web service to ease any WSDL changes

typedef LibreAccessActivityLogV2Soap11Binding LibreAccessActivityLogSoap11Binding;
typedef LibreAccessActivityLogV2Soap11BindingOperation LibreAccessActivityLogSoap11BindingOperation;
typedef LibreAccessActivityLogV2Soap11BindingResponse LibreAccessActivityLogSoap11BindingResponse;

@protocol LibreAccessActivityLogSoap11BindingResponseDelegate <LibreAccessActivityLogV2Soap11BindingResponseDelegate>
@end

typedef LibreAccessActivityLogV2Soap11Binding_SaveActivityLog LibreAccessActivityLogSoap11Binding_SaveActivityLog;

@interface LibreAccessActivityLogSvc (Binding)

+ (LibreAccessActivityLogSoap11Binding *)SCHLibreAccessActivityLogSoap11Binding;

@end
