//
//  ViewController.m
//  ObjectiveC_Check
//
//  Created by Karthikeyan A. on 02/10/19.
//  Copyright © 2019 Karthikeyan. All rights reserved.
//

#import "ViewController.h"

NSString* const setCurrentIdentifier = @"setCurrentIdentifier";


@interface ViewController ()

@end


@implementation ViewController
@synthesize appleIDLoginInfoTextView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (@available(iOS 13.0, *)) {
           [self observeAppleSignInState];
           [self setupUI];
       }
     
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
  // [self perfomExistingAccountSetupFlows];
}

- (void)observeAppleSignInState {
    if (@available(iOS 13.0, *)) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(handleSignInWithAppleStateChanged:) name:ASAuthorizationAppleIDProviderCredentialRevokedNotification object:nil];
    }
}

- (void)handleSignInWithAppleStateChanged:(id)noti {    
    NSLog(@"%s", __FUNCTION__);
    NSLog(@"%@", noti);
}

- (void)perfomExistingAccountSetupFlows {
    if (@available(iOS 13.0, *)) {
        // A mechanism for generating requests to authenticate users based on their Apple ID.
        ASAuthorizationAppleIDProvider *appleIDProvider = [ASAuthorizationAppleIDProvider new];
        
        // An OpenID authorization request that relies on the user’s Apple ID.
        ASAuthorizationAppleIDRequest *authAppleIDRequest = [appleIDProvider createRequest];
        
        // A mechanism for generating requests to perform keychain credential sharing.
        ASAuthorizationPasswordRequest *passwordRequest = [[ASAuthorizationPasswordProvider new] createRequest];
        
        NSMutableArray <ASAuthorizationRequest *>* mArr = [NSMutableArray arrayWithCapacity:2];
        if (authAppleIDRequest) {
            [mArr addObject:authAppleIDRequest];
        }
        if (passwordRequest) {
            [mArr addObject:passwordRequest];
        }
        // ASAuthorizationRequest：A base class for different kinds of authorization requests.
        NSArray <ASAuthorizationRequest *>* requests = [mArr copy];
        
        // A controller that manages authorization requests created by a provider.
        // Creates a controller from a collection of authorization requests.
        ASAuthorizationController *authorizationController = [[ASAuthorizationController alloc] initWithAuthorizationRequests:requests];

        // A delegate that the authorization controller informs about the success or failure of an authorization attempt.
        authorizationController.delegate = self;
        // A delegate that provides a display context in which the system can present an authorization interface to the user.
        authorizationController.presentationContextProvider = self;
        
        // starts the authorization flows named during controller initialization.
        [authorizationController performRequests];
    }
}

- (void)setupUI {
    
    // Sign In With Apple 
    appleIDLoginInfoTextView = [[UITextView alloc] initWithFrame:CGRectMake(.0, 40.0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) * 0.4) textContainer:nil];
    appleIDLoginInfoTextView.font = [UIFont systemFontOfSize:32.0];
    [self.view addSubview:appleIDLoginInfoTextView];
    

    if (@available(iOS 13.0, *)) {
    // Sign In With Apple Button
    ASAuthorizationAppleIDButton *appleIDButton = [ASAuthorizationAppleIDButton new];
        
    appleIDButton.frame =  CGRectMake(.0, .0, CGRectGetWidth(self.view.frame) - 40.0, 100.0);
    CGPoint origin = CGPointMake(20.0, CGRectGetMidY(self.view.frame));
    CGRect frame = appleIDButton.frame;
    frame.origin = origin;
    appleIDButton.frame = frame;
    appleIDButton.cornerRadius = CGRectGetHeight(appleIDButton.frame) * 0.25;
    [self.view addSubview:appleIDButton];
    [appleIDButton addTarget:self action:@selector(handleAuthrization:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    NSMutableString *mStr = [NSMutableString string];
    [mStr appendString:@"Sign In With Apple \n"];
    appleIDLoginInfoTextView.text = [mStr copy];
}

#pragma mark - Actions

- (void)handleAuthrization:(UIButton *)sender {
    if (@available(iOS 13.0, *)) {
        // A mechanism for generating requests to authenticate users based on their Apple ID.
        ASAuthorizationAppleIDProvider *appleIDProvider = [ASAuthorizationAppleIDProvider new];
        
        // Creates a new Apple ID authorization request.
        ASAuthorizationAppleIDRequest *request = appleIDProvider.createRequest;
        // The contact information to be requested from the user during authentication.
        request.requestedScopes = @[ASAuthorizationScopeFullName, ASAuthorizationScopeEmail];
        
        // A controller that manages authorization requests created by a provider.
        ASAuthorizationController *controller = [[ASAuthorizationController alloc] initWithAuthorizationRequests:@[request]];
        
        // A delegate that the authorization controller informs about the success or failure of an authorization attempt.
        controller.delegate = self;
        
        // A delegate that provides a display context in which the system can present an authorization interface to the user.
        controller.presentationContextProvider = self;
        
        // starts the authorization flows named during controller initialization.
        [controller performRequests];
    }
}
 
#pragma mark - Delegate

 - (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithAuthorization:(ASAuthorization *)authorization  API_AVAILABLE(ios(13.0)){
    
    NSLog(@"%s", __FUNCTION__);
    NSLog(@"%@", controller);
    NSLog(@"%@", authorization);
    
    NSLog(@"authorization.credential：%@", authorization.credential);
    
    NSMutableString *mStr = [NSMutableString string];
    mStr = [appleIDLoginInfoTextView.text mutableCopy];
    
    if ([authorization.credential isKindOfClass:[ASAuthorizationAppleIDCredential class]]) {
        // ASAuthorizationAppleIDCredential
        ASAuthorizationAppleIDCredential *appleIDCredential = authorization.credential;
        NSString *user = appleIDCredential.user;
        [[NSUserDefaults standardUserDefaults] setValue:user forKey:setCurrentIdentifier];
        [mStr appendString:user?:@""];
        NSString *familyName = appleIDCredential.fullName.familyName;
        [mStr appendString:familyName?:@""];
        NSString *givenName = appleIDCredential.fullName.givenName;
        [mStr appendString:givenName?:@""];
        NSString *email = appleIDCredential.email;
        [mStr appendString:email?:@""];
        NSLog(@"mStr：%@", mStr);
        [mStr appendString:@"\n"];
        appleIDLoginInfoTextView.text = mStr;
        
    } else if ([authorization.credential isKindOfClass:[ASPasswordCredential class]]) {
        ASPasswordCredential *passwordCredential = authorization.credential;
        NSString *user = passwordCredential.user;
        NSString *password = passwordCredential.password;
        [mStr appendString:user?:@""];
        [mStr appendString:password?:@""];
        [mStr appendString:@"\n"];
        NSLog(@"mStr：%@", mStr);
        appleIDLoginInfoTextView.text = mStr;
    } else {
         mStr = [@"check" mutableCopy];
        appleIDLoginInfoTextView.text = mStr;
    }
}
 

- (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithError:(NSError *)error  API_AVAILABLE(ios(13.0)){
    
    NSLog(@"%s", __FUNCTION__);
    NSLog(@"error ：%@", error);
    NSString *errorMsg = nil;
    switch (error.code) {
        case ASAuthorizationErrorCanceled:
            errorMsg = @"ASAuthorizationErrorCanceled";
            break;
        case ASAuthorizationErrorFailed:
            errorMsg = @"ASAuthorizationErrorFailed";
            break;
        case ASAuthorizationErrorInvalidResponse:
            errorMsg = @"ASAuthorizationErrorInvalidResponse";
            break;
        case ASAuthorizationErrorNotHandled:
            errorMsg = @"ASAuthorizationErrorNotHandled";
            break;
        case ASAuthorizationErrorUnknown:
            errorMsg = @"ASAuthorizationErrorUnknown";
            break;
    }
    
    NSMutableString *mStr = [appleIDLoginInfoTextView.text mutableCopy];
    [mStr appendString:errorMsg];
    [mStr appendString:@"\n"];
    appleIDLoginInfoTextView.text = [mStr copy];
    
    if (errorMsg) {
        return;
    }
    
    if (error.localizedDescription) {
        NSMutableString *mStr = [appleIDLoginInfoTextView.text mutableCopy];
        [mStr appendString:error.localizedDescription];
        [mStr appendString:@"\n"];
        appleIDLoginInfoTextView.text = [mStr copy];
    }
    NSLog(@"controller requests：%@", controller.authorizationRequests);
    /*
     ((ASAuthorizationAppleIDRequest *)(controller.authorizationRequests[0])).requestedScopes
     <__NSArrayI 0x2821e2520>(
     full_name,
     email
     )
     */
}
 
//! Tells the delegate from which window it should present content to the user.
 - (ASPresentationAnchor)presentationAnchorForAuthorizationController:(ASAuthorizationController *)controller  API_AVAILABLE(ios(13.0)){
    
    NSLog(@"window：%s", __FUNCTION__);
    return self.view.window;
}

- (void)dealloc {
    
    if (@available(iOS 13.0, *)) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:ASAuthorizationAppleIDProviderCredentialRevokedNotification object:nil];
    }
}


@end
