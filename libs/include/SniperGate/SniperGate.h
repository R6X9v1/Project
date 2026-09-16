//
//  SniperGate.h
//  SniperGate
//
//  Created by Sniper Team on 20/08/2025.
//

/*
  SniperGate - Comprehensive App Protection System

  This header is responsible for invoking core functions of the application
  and serves as the main interface for managing security and subscription controls.

  System Features:
  - Protects your application from unauthorized access.
  - Ensures that only valid subscribers with licensed keys can access the app.
  - Manages and enforces subscription access seamlessly.
  - Provides a unified interface for initializing all core application services.
  - Supports Objective-C, Swift, and C++ integration.
  
  Notes:
  - This system is essential for controlling application access and managing subscriptions.
  - All application services should be initialized through the designated functions.
  - Access to the app is restricted until a valid subscription key is provided.
*/

#import <Foundation/Foundation.h>

@interface SniperGate : NSObject


/// Returns the key activation date (Start Date) as a string
/// Example return: @"2026-02-24"
+ (NSString *)StartDate;

/// Returns the key expiration date (Expiration Date) as a string
/// Example return: @"2026-12-31"
+ (NSString *)ExpirationDate;

+ (NSString *)var_00022351;


@end

#pragma once
#ifdef __cplusplus
extern "C" {
#endif

/**
  sub_00238e7b - This function must be called by the responsible party in charge of
  initializing all application services. It activates the full system, ensuring
  that the application runs correctly and only authorized users can access it.

  ⚠️ Important Note: If this function is not made responsible for running your app,
     the system will be **completely ineffective and provide no protection**.
*/
void sub_00238e7b(void); // Initialize all application services and enforce subscription access

#ifdef __cplusplus
}
#endif
