#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "AutoCompletion.h"
#import "AutoCompletionAnimator.h"
#import "AutoCompletionDataSource.h"
#import "AutoCompletionTextField.h"
#import "AutoCompletionTextFieldDataSource.h"
#import "AutoCompletionTextFieldDelegate.h"

FOUNDATION_EXPORT double AutoCompletionVersionNumber;
FOUNDATION_EXPORT const unsigned char AutoCompletionVersionString[];

