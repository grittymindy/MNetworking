//
//  ASIAuthenticationDialog.h
//  Part of ASIHTTPRequest -> http://allseeing-i.com/ASIHTTPRequest
//
//  Created by Ben Copsey on 21/08/2009.
//  Copyright 2009 All-Seeing Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class M_ASIHTTPRequest;

typedef enum _M_ASIAuthenticationType {
	M_ASIStandardAuthenticationType = 0,
    M_ASIProxyAuthenticationType = 1
} M_ASIAuthenticationType;

@interface M_ASIAutorotatingViewController : UIViewController
@end

@interface M_ASIAuthenticationDialog : M_ASIAutorotatingViewController <UIActionSheetDelegate, UITableViewDelegate, UITableViewDataSource> {
	M_ASIHTTPRequest *request;
	M_ASIAuthenticationType type;
	UITableView *tableView;
	UIViewController *presentingController;
	BOOL didEnableRotationNotifications;
}
+ (void)presentAuthenticationDialogForRequest:(M_ASIHTTPRequest *)request;
+ (void)dismiss;

@property (atomic, retain) M_ASIHTTPRequest *request;
@property (atomic, assign) M_ASIAuthenticationType type;
@property (atomic, assign) BOOL didEnableRotationNotifications;
@property (retain, nonatomic) UIViewController *presentingController;
@end
