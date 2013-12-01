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

#import "MJLocalizableStringsTable.h"
#import "MJLocalizableString.h"

@implementation MJLocalizableStringsTable {
    NSMutableArray *_localizableStrings;
    NSMutableDictionary *_indices;
}

- (id)initWithName:(NSString *)name
{
    self = [super init];
    if (self) {
        _name = [name copy];
        _localizableStrings = [[NSMutableArray alloc] init];
        _indices = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (BOOL)addLocalizableString:(MJLocalizableString *)localizableString
{
    if ([self localizableStringForKey:localizableString.key]) {
        return NO;
    }
    
    NSNumber *index = [NSNumber numberWithUnsignedInteger:_localizableStrings.count];
    [_localizableStrings addObject:localizableString];
    [_indices setObject:index forKey:localizableString.key];
    
    return YES;
}

- (MJLocalizableString *)localizableStringForKey:(NSString *)key
{
    NSNumber *index = [_indices objectForKey:key];
    if (!index) {
        return nil;
    }
    
    return [_localizableStrings objectAtIndex:[index unsignedIntegerValue]];
}

- (BOOL)containsLocalizableString:(MJLocalizableString *)string
{
    return nil != [self localizableStringForKey:string.key];
}

- (NSArray *)localizableStrings
{
    return _localizableStrings;
}

@end
