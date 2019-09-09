//
//  RegexKitLite.h
//  http://regexkit.sourceforge.net/
//  Licensed under the terms of the BSD License, as specified below.
//

/*
 Copyright (c) 2008-2010, John Engelhart
 
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 
 * Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 
 * Neither the name of the Zang Industries nor the names of its
 contributors may be used to endorse or promote products derived from
 this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
 TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#ifdef    __OBJC__
#import <Foundation/NSArray.h>
#import <Foundation/NSError.h>
#import <Foundation/NSObjCRuntime.h>
#import <Foundation/NSRange.h>
#import <Foundation/NSString.h>
#endif // __OBJC__

#include <limits.h>
#include <stdint.h>
#include <sys/types.h>
#include <TargetConditionals.h>
#include <AvailabilityMacros.h>

#ifdef __cplusplus
extern "C" {
#endif
  
#ifndef   REGEXKITLITE_VERSION_DEFINED
#define   REGEXKITLITE_VERSION_DEFINED

#define _RKL__STRINGIFY(b)       #b
#define _RKL_STRINGIFY(a)        _RKL__STRINGIFY(a)
#define _RKL_JOIN_VERSION(a,b)   _RKL_STRINGIFY(a##.##b)
#define _RKL_VERSION_STRING(a,b) _RKL_JOIN_VERSION(a,b)

#define REGEXKITLITE_VERSION_MAJOR 4
#define REGEXKITLITE_VERSION_MINOR 0

#define REGEXKITLITE_VERSION_CSTRING   _RKL_VERSION_STRING(REGEXKITLITE_VERSION_MAJOR, REGEXKITLITE_VERSION_MINOR)
#define REGEXKITLITE_VERSION_NSSTRING  @REGEXKITLITE_VERSION_CSTRING

#endif // REGEXKITLITE_VERSION_DEFINED

#if !defined(MLSRKL_BLOCKS) && defined(NS_BLOCKS_AVAILABLE) && (NS_BLOCKS_AVAILABLE == 1)
#define MLSRKL_BLOCKS 1
#endif
  
#if       defined(MLSRKL_BLOCKS) && (MLSRKL_BLOCKS == 1)
#define _RKL_BLOCKS_ENABLED 1
#endif // defined(MLSRKL_BLOCKS) && (MLSRKL_BLOCKS == 1)

#if       defined(_RKL_BLOCKS_ENABLED) && !defined(__BLOCKS__)
#warning RegexKitLite support for Blocks is enabled, but __BLOCKS__ is not defined.  This compiler may not support Blocks, in which case the behavior is undefined.  This will probably cause numerous compiler errors.
#endif // defined(_RKL_BLOCKS_ENABLED) && !defined(__BLOCKS__)

// For Mac OS X < 10.5.
#ifndef   NSINTEGER_DEFINED
#define   NSINTEGER_DEFINED
#if       defined(__LP64__) || defined(NS_BUILD_32_LIKE_64)
typedef long           NSInteger;
typedef unsigned long  NSUInteger;
#define NSIntegerMin   LONG_MIN
#define NSIntegerMax   LONG_MAX
#define NSUIntegerMax  ULONG_MAX
#else  // defined(__LP64__) || defined(NS_BUILD_32_LIKE_64)
typedef int            NSInteger;
typedef unsigned int   NSUInteger;
#define NSIntegerMin   INT_MIN
#define NSIntegerMax   INT_MAX
#define NSUIntegerMax  UINT_MAX
#endif // defined(__LP64__) || defined(NS_BUILD_32_LIKE_64)
#endif // NSINTEGER_DEFINED

#ifndef   MLSRKLREGEXOPTIONS_DEFINED
#define   MLSRKLREGEXOPTIONS_DEFINED

// These must be identical to their ICU regex counterparts. See http://www.icu-project.org/userguide/regexp.html
enum {
  MLSRKLNoOptions             = 0,
  MLSRKLCaseless              = 2,
  MLSRKLComments              = 4,
  MLSRKLDotAll                = 32,
  MLSRKLMultiline             = 8,
  MLSRKLUnicodeWordBoundaries = 256
};
typedef uint32_t MLSRKLRegexOptions; // This must be identical to the ICU 'flags' argument type.

#endif // MLSRKLREGEXOPTIONS_DEFINED

#ifndef   MLSRKLREGEXENUMERATIONOPTIONS_DEFINED
#define   MLSRKLREGEXENUMERATIONOPTIONS_DEFINED

enum {
  MLSRKLRegexEnumerationNoOptions                               = 0UL,
  MLSRKLRegexEnumerationCapturedStringsNotRequired              = 1UL << 9,
  MLSRKLRegexEnumerationReleaseStringReturnedByReplacementBlock = 1UL << 10,
  MLSRKLRegexEnumerationFastCapturedStringsXXX                  = 1UL << 11,
};
typedef NSUInteger MLSRKLRegexEnumerationOptions;
  
#endif // MLSRKLREGEXENUMERATIONOPTIONS_DEFINED

#ifndef _REGEXKITLITE_H_
#define _REGEXKITLITE_H_

#if defined(__GNUC__) && (__GNUC__ >= 4) && defined(__APPLE_CC__) && (__APPLE_CC__ >= 5465)
#define MLSRKL_DEPRECATED_ATTRIBUTE __attribute__((deprecated))
#else
#define MLSRKL_DEPRECATED_ATTRIBUTE
#endif

#if       defined(NS_REQUIRES_NIL_TERMINATION)
#define MLSRKL_REQUIRES_NIL_TERMINATION NS_REQUIRES_NIL_TERMINATION
#else  // defined(NS_REQUIRES_NIL_TERMINATION)
#define MLSRKL_REQUIRES_NIL_TERMINATION
#endif // defined(NS_REQUIRES_NIL_TERMINATION)
  
// This requires a few levels of rewriting to get the desired results.
#define _RKL_CONCAT_2(c,d) c ## d
#define _RKL_CONCAT(a,b) _RKL_CONCAT_2(a,b)
  
#ifdef    MLSRKL_PREPEND_TO_METHODS
#define MLSRKL_METHOD_PREPEND(x) _RKL_CONCAT(MLSRKL_PREPEND_TO_METHODS, x)
#else  // MLSRKL_PREPEND_TO_METHODS
#define MLSRKL_METHOD_PREPEND(x) x
#endif // MLSRKL_PREPEND_TO_METHODS
  
// If it looks like low memory notifications might be available, add code to register and respond to them.
// This is (should be) harmless if it turns out that this isn't the case, since the notification that we register for,
// UIApplicationDidReceiveMemoryWarningNotification, is dynamically looked up via dlsym().
#if ((defined(TARGET_OS_EMBEDDED) && (TARGET_OS_EMBEDDED != 0)) || (defined(TARGET_OS_IPHONE) && (TARGET_OS_IPHONE != 0))) && (!defined(MLSRKL_REGISTER_FOR_IPHONE_LOWMEM_NOTIFICATIONS) || (MLSRKL_REGISTER_FOR_IPHONE_LOWMEM_NOTIFICATIONS != 0))
#define MLSRKL_REGISTER_FOR_IPHONE_LOWMEM_NOTIFICATIONS 1
#endif

#ifdef __OBJC__

// NSException exception name.
extern NSString * const MLSRKLICURegexException;

// NSError error domains and user info keys.
extern NSString * const MLSRKLICURegexErrorDomain;

extern NSString * const MLSRKLICURegexEnumerationOptionsErrorKey;
extern NSString * const MLSRKLICURegexErrorCodeErrorKey;
extern NSString * const MLSRKLICURegexErrorNameErrorKey;
extern NSString * const MLSRKLICURegexLineErrorKey;
extern NSString * const MLSRKLICURegexOffsetErrorKey;
extern NSString * const MLSRKLICURegexPreContextErrorKey;
extern NSString * const MLSRKLICURegexPostContextErrorKey;
extern NSString * const MLSRKLICURegexRegexErrorKey;
extern NSString * const MLSRKLICURegexRegexOptionsErrorKey;
extern NSString * const MLSRKLICURegexReplacedCountErrorKey;
extern NSString * const MLSRKLICURegexReplacedStringErrorKey;
extern NSString * const MLSRKLICURegexReplacementStringErrorKey;
extern NSString * const MLSRKLICURegexSubjectRangeErrorKey;
extern NSString * const MLSRKLICURegexSubjectStringErrorKey;
  
@interface NSString (RegexKitLiteAdditions)

+ (void)MLSRKL_METHOD_PREPEND(clearStringCache);

// Although these are marked as deprecated, a bug in GCC prevents a warning from being issues for + class methods.  Filed bug with Apple, #6736857.
+ (NSInteger)MLSRKL_METHOD_PREPEND(captureCountForRegex):(NSString *)regex MLSRKL_DEPRECATED_ATTRIBUTE;
+ (NSInteger)MLSRKL_METHOD_PREPEND(captureCountForRegex):(NSString *)regex options:(MLSRKLRegexOptions)options error:(NSError **)error MLSRKL_DEPRECATED_ATTRIBUTE;

- (NSArray *)MLSRKL_METHOD_PREPEND(componentsSeparatedByRegex):(NSString *)regex;
- (NSArray *)MLSRKL_METHOD_PREPEND(componentsSeparatedByRegex):(NSString *)regex range:(NSRange)range;
- (NSArray *)MLSRKL_METHOD_PREPEND(componentsSeparatedByRegex):(NSString *)regex options:(MLSRKLRegexOptions)options range:(NSRange)range error:(NSError **)error;

- (BOOL)MLSRKL_METHOD_PREPEND(isMatchedByRegex):(NSString *)regex;
- (BOOL)MLSRKL_METHOD_PREPEND(isMatchedByRegex):(NSString *)regex inRange:(NSRange)range;
- (BOOL)MLSRKL_METHOD_PREPEND(isMatchedByRegex):(NSString *)regex options:(MLSRKLRegexOptions)options inRange:(NSRange)range error:(NSError **)error;

- (NSRange)MLSRKL_METHOD_PREPEND(rangeOfRegex):(NSString *)regex;
- (NSRange)MLSRKL_METHOD_PREPEND(rangeOfRegex):(NSString *)regex capture:(NSInteger)capture;
- (NSRange)MLSRKL_METHOD_PREPEND(rangeOfRegex):(NSString *)regex inRange:(NSRange)range;
- (NSRange)MLSRKL_METHOD_PREPEND(rangeOfRegex):(NSString *)regex options:(MLSRKLRegexOptions)options inRange:(NSRange)range capture:(NSInteger)capture error:(NSError **)error;

- (NSString *)MLSRKL_METHOD_PREPEND(stringByMatching):(NSString *)regex;
- (NSString *)MLSRKL_METHOD_PREPEND(stringByMatching):(NSString *)regex capture:(NSInteger)capture;
- (NSString *)MLSRKL_METHOD_PREPEND(stringByMatching):(NSString *)regex inRange:(NSRange)range;
- (NSString *)MLSRKL_METHOD_PREPEND(stringByMatching):(NSString *)regex options:(MLSRKLRegexOptions)options inRange:(NSRange)range capture:(NSInteger)capture error:(NSError **)error;

- (NSString *)MLSRKL_METHOD_PREPEND(stringByReplacingOccurrencesOfRegex):(NSString *)regex withString:(NSString *)replacement;
- (NSString *)MLSRKL_METHOD_PREPEND(stringByReplacingOccurrencesOfRegex):(NSString *)regex withString:(NSString *)replacement range:(NSRange)searchRange;
- (NSString *)MLSRKL_METHOD_PREPEND(stringByReplacingOccurrencesOfRegex):(NSString *)regex withString:(NSString *)replacement options:(MLSRKLRegexOptions)options range:(NSRange)searchRange error:(NSError **)error;

  //// >= 3.0

- (NSInteger)MLSRKL_METHOD_PREPEND(captureCount);
- (NSInteger)MLSRKL_METHOD_PREPEND(captureCountWithOptions):(MLSRKLRegexOptions)options error:(NSError **)error;

- (BOOL)MLSRKL_METHOD_PREPEND(isRegexValid);
- (BOOL)MLSRKL_METHOD_PREPEND(isRegexValidWithOptions):(MLSRKLRegexOptions)options error:(NSError **)error;

- (void)MLSRKL_METHOD_PREPEND(flushCachedRegexData);

- (NSArray *)MLSRKL_METHOD_PREPEND(componentsMatchedByRegex):(NSString *)regex;
- (NSArray *)MLSRKL_METHOD_PREPEND(componentsMatchedByRegex):(NSString *)regex capture:(NSInteger)capture;
- (NSArray *)MLSRKL_METHOD_PREPEND(componentsMatchedByRegex):(NSString *)regex range:(NSRange)range;
- (NSArray *)MLSRKL_METHOD_PREPEND(componentsMatchedByRegex):(NSString *)regex options:(MLSRKLRegexOptions)options range:(NSRange)range capture:(NSInteger)capture error:(NSError **)error;


- (NSArray *)MLSRKL_METHOD_PREPEND(captureComponentsMatchedByRegex):(NSString *)regex;
- (NSArray *)MLSRKL_METHOD_PREPEND(captureComponentsMatchedByRegex):(NSString *)regex range:(NSRange)range;
- (NSArray *)MLSRKL_METHOD_PREPEND(captureComponentsMatchedByRegex):(NSString *)regex options:(MLSRKLRegexOptions)options range:(NSRange)range error:(NSError **)error;

- (NSArray *)MLSRKL_METHOD_PREPEND(arrayOfCaptureComponentsMatchedByRegex):(NSString *)regex;
- (NSArray *)MLSRKL_METHOD_PREPEND(arrayOfCaptureComponentsMatchedByRegex):(NSString *)regex range:(NSRange)range;
- (NSArray *)MLSRKL_METHOD_PREPEND(arrayOfCaptureComponentsMatchedByRegex):(NSString *)regex options:(MLSRKLRegexOptions)options range:(NSRange)range error:(NSError **)error;

  //// >= 4.0

- (NSArray *)MLSRKL_METHOD_PREPEND(arrayOfDictionariesByMatchingRegex):(NSString *)regex withKeysAndCaptures:(id)firstKey, ... MLSRKL_REQUIRES_NIL_TERMINATION;
- (NSArray *)MLSRKL_METHOD_PREPEND(arrayOfDictionariesByMatchingRegex):(NSString *)regex range:(NSRange)range withKeysAndCaptures:(id)firstKey, ... MLSRKL_REQUIRES_NIL_TERMINATION;
- (NSArray *)MLSRKL_METHOD_PREPEND(arrayOfDictionariesByMatchingRegex):(NSString *)regex options:(MLSRKLRegexOptions)options range:(NSRange)range error:(NSError **)error withKeysAndCaptures:(id)firstKey, ... MLSRKL_REQUIRES_NIL_TERMINATION;
- (NSArray *)MLSRKL_METHOD_PREPEND(arrayOfDictionariesByMatchingRegex):(NSString *)regex options:(MLSRKLRegexOptions)options range:(NSRange)range error:(NSError **)error withFirstKey:(id)firstKey arguments:(va_list)varArgsList;

- (NSArray *)MLSRKL_METHOD_PREPEND(arrayOfDictionariesByMatchingRegex):(NSString *)regex options:(MLSRKLRegexOptions)options range:(NSRange)range error:(NSError **)error withKeys:(id *)keys forCaptures:(int *)captures count:(NSUInteger)count;

- (NSDictionary *)MLSRKL_METHOD_PREPEND(dictionaryByMatchingRegex):(NSString *)regex withKeysAndCaptures:(id)firstKey, ... MLSRKL_REQUIRES_NIL_TERMINATION;
- (NSDictionary *)MLSRKL_METHOD_PREPEND(dictionaryByMatchingRegex):(NSString *)regex range:(NSRange)range withKeysAndCaptures:(id)firstKey, ... MLSRKL_REQUIRES_NIL_TERMINATION;
- (NSDictionary *)MLSRKL_METHOD_PREPEND(dictionaryByMatchingRegex):(NSString *)regex options:(MLSRKLRegexOptions)options range:(NSRange)range error:(NSError **)error withKeysAndCaptures:(id)firstKey, ... MLSRKL_REQUIRES_NIL_TERMINATION;
- (NSDictionary *)MLSRKL_METHOD_PREPEND(dictionaryByMatchingRegex):(NSString *)regex options:(MLSRKLRegexOptions)options range:(NSRange)range error:(NSError **)error withFirstKey:(id)firstKey arguments:(va_list)varArgsList;

- (NSDictionary *)MLSRKL_METHOD_PREPEND(dictionaryByMatchingRegex):(NSString *)regex options:(MLSRKLRegexOptions)options range:(NSRange)range error:(NSError **)error withKeys:(id *)keys forCaptures:(int *)captures count:(NSUInteger)count;

#ifdef    _RKL_BLOCKS_ENABLED

- (BOOL)MLSRKL_METHOD_PREPEND(enumerateStringsMatchedByRegex):(NSString *)regex usingBlock:(void (^)(NSInteger captureCount, NSString * const capturedStrings[captureCount], const NSRange capturedRanges[captureCount], volatile BOOL * const stop))block;
- (BOOL)MLSRKL_METHOD_PREPEND(enumerateStringsMatchedByRegex):(NSString *)regex options:(MLSRKLRegexOptions)options inRange:(NSRange)range error:(NSError **)error enumerationOptions:(MLSRKLRegexEnumerationOptions)enumerationOptions usingBlock:(void (^)(NSInteger captureCount, NSString * const capturedStrings[captureCount], const NSRange capturedRanges[captureCount], volatile BOOL * const stop))block;

- (BOOL)MLSRKL_METHOD_PREPEND(enumerateStringsSeparatedByRegex):(NSString *)regex usingBlock:(void (^)(NSInteger captureCount, NSString * const capturedStrings[captureCount], const NSRange capturedRanges[captureCount], volatile BOOL * const stop))block;
- (BOOL)MLSRKL_METHOD_PREPEND(enumerateStringsSeparatedByRegex):(NSString *)regex options:(MLSRKLRegexOptions)options inRange:(NSRange)range error:(NSError **)error enumerationOptions:(MLSRKLRegexEnumerationOptions)enumerationOptions usingBlock:(void (^)(NSInteger captureCount, NSString * const capturedStrings[captureCount], const NSRange capturedRanges[captureCount], volatile BOOL * const stop))block;

- (NSString *)MLSRKL_METHOD_PREPEND(stringByReplacingOccurrencesOfRegex):(NSString *)regex usingBlock:(NSString *(^)(NSInteger captureCount, NSString * const capturedStrings[captureCount], const NSRange capturedRanges[captureCount], volatile BOOL * const stop))block;
- (NSString *)MLSRKL_METHOD_PREPEND(stringByReplacingOccurrencesOfRegex):(NSString *)regex options:(MLSRKLRegexOptions)options inRange:(NSRange)range error:(NSError **)error enumerationOptions:(MLSRKLRegexEnumerationOptions)enumerationOptions usingBlock:(NSString *(^)(NSInteger captureCount, NSString * const capturedStrings[captureCount], const NSRange capturedRanges[captureCount], volatile BOOL * const stop))block;

#endif // _RKL_BLOCKS_ENABLED

@end

@interface NSMutableString (RegexKitLiteAdditions)

- (NSInteger)MLSRKL_METHOD_PREPEND(replaceOccurrencesOfRegex):(NSString *)regex withString:(NSString *)replacement;
- (NSInteger)MLSRKL_METHOD_PREPEND(replaceOccurrencesOfRegex):(NSString *)regex withString:(NSString *)replacement range:(NSRange)searchRange;
- (NSInteger)MLSRKL_METHOD_PREPEND(replaceOccurrencesOfRegex):(NSString *)regex withString:(NSString *)replacement options:(MLSRKLRegexOptions)options range:(NSRange)searchRange error:(NSError **)error;

  //// >= 4.0

#ifdef    _RKL_BLOCKS_ENABLED

- (NSInteger)MLSRKL_METHOD_PREPEND(replaceOccurrencesOfRegex):(NSString *)regex usingBlock:(NSString *(^)(NSInteger captureCount, NSString * const capturedStrings[captureCount], const NSRange capturedRanges[captureCount], volatile BOOL * const stop))block;
- (NSInteger)MLSRKL_METHOD_PREPEND(replaceOccurrencesOfRegex):(NSString *)regex options:(MLSRKLRegexOptions)options inRange:(NSRange)range error:(NSError **)error enumerationOptions:(MLSRKLRegexEnumerationOptions)enumerationOptions usingBlock:(NSString *(^)(NSInteger captureCount, NSString * const capturedStrings[captureCount], const NSRange capturedRanges[captureCount], volatile BOOL * const stop))block;

#endif // _RKL_BLOCKS_ENABLED

@end

#endif // __OBJC__

#endif // _REGEXKITLITE_H_

#ifdef __cplusplus
}  // extern "C"
#endif
