//
//  ViewController.h
//  ObjectiveC_Check
//
//  Created by Karthikeyan A. on 02/10/19.
//  Copyright © 2019 Karthikeyan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AuthenticationServices/AuthenticationServices.h>

extern NSString* const setCurrentIdentifier;

@interface ViewController : UIViewController<ASAuthorizationControllerDelegate,ASAuthorizationControllerPresentationContextProviding>


@property (nonatomic, strong) UITextView *appleIDLoginInfoTextView;


@end

