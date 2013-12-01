//
// The MIT License (MIT)
//
// Copyright (c) 2013 Martin Johannesson
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
// DEALINGS IN THE SOFTWARE.
//

#import "MJLocalizableStringsFile.h"
#import "MJLocalizerErrors.h"
#import "MJLocalizableStringsTable.h"
#import "MJLocalizableString.h"

@implementation MJLocalizableStringsFile


+ (BOOL)writeStringsTable:(MJLocalizableStringsTable *)stringsTable path:(NSString *)folderPath error:(NSError * __autoreleasing *)error
{
    *error = nil;
    
    NSArray *strings = [stringsTable localizableStrings];
    NSMutableString *fileContents = [NSMutableString stringWithCapacity:65536];
    
    for (MJLocalizableString *string in strings) {
        [fileContents appendFormat:@"\n/* %@ */\n\"%@\" = \"%@\";\n",
         string.comment, string.key, string.value];
    }
    
    BOOL outputPathIsDirectory = NO;
    
    BOOL outputPathExists = [[NSFileManager defaultManager] fileExistsAtPath:folderPath
                                                                 isDirectory:&outputPathIsDirectory];
    if (!outputPathExists) {
        *error = [NSError errorWithDomain:MJLocalizerDomain
                                     code:MJLocalizableStringsFileOutputPathDoesNotExistError
                                 userInfo:@{NSLocalizedDescriptionKey : [NSString stringWithFormat:@"Output path \"%@\" does not exist.", folderPath]}];
        return NO;
    }
    
    if (!outputPathIsDirectory) {
        *error = [NSError errorWithDomain:MJLocalizerDomain
                                     code:MJLocalizableStringsFileOutputPathIsNotADirectoryError
                                 userInfo:@{NSLocalizedDescriptionKey : [NSString stringWithFormat:@"Output path \"%@\" is not a directory.", folderPath]}];
        return NO;
    }
    
    NSString *filePath = [[folderPath stringByAppendingPathComponent:stringsTable.name] stringByAppendingPathExtension:@"strings"];
    
    return [fileContents writeToFile:filePath
                          atomically:YES
                            encoding:NSUTF16StringEncoding
                               error:error];
    
    return NO;
}

+ (MJLocalizableStringsTable *)readStringsTable:(NSString *)file error:(NSError * __autoreleasing *)error
{
    *error = nil;

    if (!file) {
        *error = [NSError errorWithDomain:MJLocalizerDomain
                                     code:MJLocalizableStringsFilePathIsNilError
                                 userInfo:@{NSLocalizedDescriptionKey : @"Strings file path must not be nil."}];
        return NO;
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:file]) {
        *error = [NSError errorWithDomain:MJLocalizerDomain
                                     code:MJLocalizableStringsFileDoesNotExist
                                 userInfo:@{NSLocalizedDescriptionKey : [NSString stringWithFormat:@"Strings file \"%@\" does not exist.", file]}];
        return NO;
    }
    
    if (![self scanStringsFile:file error:error]) {
        return NO;
    }

    return NO;
}

// Grammar:
//          <table> = ([\t \n]* (<comment> | <entry>))* [\t \n]*
//        <comment> = "/*" <any-character> "*/"
//          <entry> = <string> [\t \n]* '=' [\t \n]* <string> [\t \n]* ';'
//         <string> = '"' (<any-character> | "\"")* '"'

+ (BOOL)scanStringsFile:(NSString *)file error:(NSError * __autoreleasing *)error
{
    NSString *tableName = [[file lastPathComponent] stringByDeletingPathExtension];
    MJLocalizableStringsTable *table = [[MJLocalizableStringsTable alloc] initWithName:tableName];
    
    NSString *stringsFileContents = [NSString stringWithContentsOfFile:file
                                                              encoding:NSUTF16StringEncoding
                                                                 error:error];
    if (stringsFileContents == nil) {
        return NO;
    }
    
    return [self scanTable:table fromString:stringsFileContents];
}

+ (BOOL)scanTable:(MJLocalizableStringsTable *)table fromString:(NSString *)stringsFileContents
{
    NSScanner *scanner = [NSScanner scannerWithString:stringsFileContents];
    [scanner setCharactersToBeSkipped:nil];
    
    NSString *potentialEntryComment = nil;
    while (YES) {
        NSString *whitespace = nil;
        [scanner scanCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] intoString:&whitespace];
        if (whitespace && ![self stringContainsAtMostOneNewline:whitespace]) {
            potentialEntryComment = nil;
        }
        
        NSString *comment = [self scanCommentWithScanner:scanner];
        if (!comment) {
            MJLocalizableString *string = [self scanEntryWithScanner:scanner];
            if (string) {
                string.comment = potentialEntryComment;
                potentialEntryComment = nil;
                [table addLocalizableString:string];
            } else {
                if ([scanner isAtEnd]) {
                    return YES;
                } else {
                    return NO;
                }
            }
        } else {
            potentialEntryComment = comment;
        }
    };
}

+ (BOOL)stringContainsAtMostOneNewline:(NSString *)string
{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\n"
                                                                           options:0
                                                                             error:NULL];
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:string
                                                        options:0
                                                          range:NSMakeRange(0, [string length])];
    return numberOfMatches < 2;
}

+ (NSString *)scanCommentWithScanner:(NSScanner *)scanner
{
    BOOL scannedCommentStart = [scanner scanString:@"/*" intoString:NULL];
    if (!scannedCommentStart) {
        return nil;
    }
    
    NSMutableString *comment = [NSMutableString string];
    while (YES) {
        NSCharacterSet *notAsterisk = [[NSCharacterSet characterSetWithCharactersInString:@"*"] invertedSet];
        NSString *notAsteriskString = nil;
        BOOL scannedNotAsterisk = [scanner scanCharactersFromSet:notAsterisk intoString:&notAsteriskString];
        if (scannedNotAsterisk) {
            [comment appendString:notAsteriskString];
        }
        
        BOOL scannedCommentEnd = [scanner scanString:@"*/" intoString:NULL];
        if (!scannedCommentEnd) {
            BOOL scannedAsterisk = [scanner scanString:@"*" intoString:NULL];
            if (!scannedAsterisk) {
                return nil;
            } else {
                [comment appendString:@"*"];
            }
        } else {
            return comment;
        }
    }
}

+ (MJLocalizableString *)scanEntryWithScanner:(NSScanner *)scanner
{
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    
    NSString *key = [self scanStringWithScanner:scanner];
    if (!key) {
        return nil;
    }
    
    [scanner scanCharactersFromSet:whitespace intoString:NULL];
    
    BOOL scannedEqualsSign = [scanner scanString:@"=" intoString:NULL];
    if (!scannedEqualsSign) {
        return nil;
    }
    
    [scanner scanCharactersFromSet:whitespace intoString:NULL];
    
    NSString *value = [self scanStringWithScanner:scanner];
    if (!value) {
        return nil;
    }
    
    [scanner scanCharactersFromSet:whitespace intoString:NULL];
    
    BOOL scannedSemiColon = [scanner scanString:@";" intoString:NULL];
    if (!scannedSemiColon) {
        return nil;
    }
    
    return [[MJLocalizableString alloc] initWithKey:key value:value comment:nil];
}

+ (NSString *)scanStringWithScanner:(NSScanner *)scanner
{
    NSCharacterSet *notBackslashOrQuote = [[NSCharacterSet characterSetWithCharactersInString:@"\\\""] invertedSet];
    
    BOOL scannedOpeningQuote = [scanner scanString:@"\"" intoString:NULL];
    if (!scannedOpeningQuote) {
        return nil;
    }
    
    NSMutableString *string = [NSMutableString string];
    while (YES) {
        NSString *scannedString = nil;
        BOOL scannedNotBackslashOrQuote = [scanner scanCharactersFromSet:notBackslashOrQuote intoString:&scannedString];
        if (scannedNotBackslashOrQuote) {
            [string appendString:scannedString];
        }
        
        BOOL scannedBackslash = [scanner scanString:@"\\" intoString:NULL];
        if (scannedBackslash) {
            [string appendString:@"\\"];
            BOOL scannedAnotherBackslash = [scanner scanString:@"\\" intoString:NULL];
            if (scannedAnotherBackslash) {
                [string appendString:@"\\\\"];
            } else {
                // Try to skip a quote character.
                BOOL scannedEscapedQuote = [scanner scanString:@"\"" intoString:NULL];
                if (scannedEscapedQuote) {
                    [string appendString:@"\""];
                }
            }
        } else {
            BOOL scannedClosingQuote = [scanner scanString:@"\"" intoString:NULL];
            if (!scannedClosingQuote) {
                return nil;
            }
            
            return string;
        }
    }
}

@end

