//
// The MIT License (MIT)
//
// Copyright (c) 2013 Martin Johannesson
//
// Permission is hereby granted, free of charge, to any person oMJaining a
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
#import "MJLocalizableStringsExtractor.h"
#import "MJLocalizableStringMacro.h"
#import "MJLocalizableString.h"
#import "MJLocalizableStringsTable.h"
#import "MJLocalizableStringsDatabase.h"

@implementation MJLocalizableStringsExtractor

- (NSString *)scanCommentWithScanner:(NSScanner *)scanner
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

- (void)scanWhitespaceAndCommentsWithScanner:(NSScanner *)scanner
{
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    
    while (YES) {
        [scanner scanCharactersFromSet:whitespace intoString:NULL];
        NSString *comment = [self scanCommentWithScanner:scanner];
        if (!comment) {
            break;
        }
    }
}

- (NSString *)scanObjCStringWithScanner:(NSScanner *)scanner
{
    NSCharacterSet *notBackslashOrQuote = [[NSCharacterSet characterSetWithCharactersInString:@"\\\""] invertedSet];
    
    BOOL scannedOpeningQuote = [scanner scanString:@"@\"" intoString:NULL];
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

- (NSString *)scanStringWithScanner:(NSScanner *)scanner
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


- (NSArray *)scanParametersOfMacro:(MJLocalizableStringMacro *)macro
                           scanner:(NSScanner *)scanner
{
    [self scanWhitespaceAndCommentsWithScanner:scanner];
    
    if (![scanner scanString:@"(" intoString:nil]) {
        return nil;
    }
    
    NSMutableArray *parameters = [NSMutableArray arrayWithCapacity:10];
    
    while (YES) {
        [self scanWhitespaceAndCommentsWithScanner:scanner];
        
        // Scan parameter
        NSString *string = [self scanObjCStringWithScanner:scanner];
        if (string) {
            while (YES) {
                [self scanWhitespaceAndCommentsWithScanner:scanner];
                NSString *continuedString = [self scanStringWithScanner:scanner];
                if (continuedString) {
                    string = [string stringByAppendingString:continuedString];
                } else {
                    continuedString = [self scanObjCStringWithScanner:scanner];
                    if (continuedString) {
                        string = [string stringByAppendingString:continuedString];
                    } else {
                        break;
                    }
                }
            }
            [parameters addObject:string];
        } else {
            NSCharacterSet *commaOrClosingParenthesis = [NSCharacterSet characterSetWithCharactersInString:@",)"];
            [scanner scanUpToCharactersFromSet:commaOrClosingParenthesis intoString:nil];
            [parameters addObject:@""];
        }
        
        if (![scanner scanString:@"," intoString:nil]) {
            break;
        }
    }
    
    if (![scanner scanString:@")" intoString:nil]) {
        return nil;
    }
    
    return parameters;
}

- (BOOL)addOccurrencesOfMacro:(MJLocalizableStringMacro *)macro
                       inCode:(NSString *)code
                     database:(MJLocalizableStringsDatabase *)stringsDatabase
{
    NSScanner *scanner = [NSScanner scannerWithString:code];
    [scanner setCharactersToBeSkipped:nil];
    [scanner setCaseSensitive:YES];
    
    
    while (YES) {
        if (![scanner scanUpToString:macro.name intoString:nil]) {
            break;
        }
        
        if ([scanner isAtEnd]) {
            break;
        }
        
        if (![scanner scanString:macro.name intoString:nil]) {
            break;
        }
        
        NSArray *parameters = [self scanParametersOfMacro:macro scanner:scanner];
        if (!parameters) {
            NSLog(@"ERROR: failed to parse arguments in localization macro.");
            return NO;
        }
        
        if (parameters.count != macro.argumentCount) {
            NSLog(@"ERROR: Invalid number of arguments in localization macro.");
            return NO;
        }
        
        NSString *key = nil;
        NSString *tableName = nil;
        NSString *value = nil;
        NSString *comment = nil;
        
        for (MJLocalizableStringMacroArgument *argument in macro.arguments) {
            if (argument.index < parameters.count) {
                NSString *argumentString = [parameters objectAtIndex:argument.index];
                if (argument.argument == MJMacroArgumentIdKey) {
                    key = argumentString;
                } else if (argument.argument == MJMacroArgumentIdTable) {
                    tableName = argumentString;
                } else if (argument.argument == MJMacroArgumentIdValue) {
                    value = argumentString;
                } else if (argument.argument == MJMacroArgumentIdComment) {
                    comment = argumentString;
                } else if (argument.argument == MJMacroArgumentIdIgnore) {
                    // Ignoring argument.
                }
            }
        }
        
        if (!value || [value isEqualToString:@""]) {
            value = key;
        }
        
        if (!comment || [comment isEqualToString:@""]) {
            comment = @"No comment given.";
        }
        
        if (!tableName || [tableName isEqualToString:@""]) {
            tableName = @"Localizable";
        }
        
        MJLocalizableString *localizableString = [[MJLocalizableString alloc] initWithKey:key value:value comment:comment];
        
        MJLocalizableStringsTable *table = [stringsDatabase tableWithName:tableName];
        if (!table) {
            table = [[MJLocalizableStringsTable alloc] initWithName:tableName];
            [stringsDatabase addTable:table];
        }
        
        BOOL added = [table addLocalizableString:localizableString];
        if (!added) {
            // This is probably not really a warning.
            //NSLog(@"WARNING: Localizable string with key %@ already exists in table %@", key, tableName);
        }
        
        
    }
    
    return YES;
}

- (BOOL)extractLocalizableStringsInFile:(NSString *)codeFilePath
                             toDatabase:(MJLocalizableStringsDatabase *)stringsDatabase
                                  macro:(MJLocalizableStringMacro *)macro
{
    return [self extractLocalizableStringsInFile:codeFilePath
                                      toDatabase:stringsDatabase
                                          macros:[NSArray arrayWithObject:macro]];
}

- (BOOL)extractLocalizableStringsInFile:(NSString *)codeFilePath
                             toDatabase:(MJLocalizableStringsDatabase *)stringsDatabase
                                 macros:(NSArray *)macros
{
    NSString *code = [NSString stringWithContentsOfFile:codeFilePath
                                               encoding:NSUTF8StringEncoding
                                                  error:nil];
    
    for (MJLocalizableStringMacro *macro in macros) {
        [self addOccurrencesOfMacro:macro inCode:code database:stringsDatabase];
    }
    
    return NO;
}

@end
