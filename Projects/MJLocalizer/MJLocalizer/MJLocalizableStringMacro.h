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

#import <Foundation/Foundation.h>

typedef enum MJMacroArgumentId
{
    MJMacroArgumentIdIgnore,
    MJMacroArgumentIdKey,
    MJMacroArgumentIdTable,
    MJMacroArgumentIdComment,
    MJMacroArgumentIdValue
} MJMacroArgumentId;

@interface MJLocalizableStringMacroArgument : NSObject

@property (nonatomic, assign, readonly) MJMacroArgumentId argument;
@property (nonatomic, assign, readonly) NSUInteger index;

- (id)initWithArgument:(MJMacroArgumentId)argument index:(NSUInteger)index;

@end


@interface MJLocalizableStringMacro : NSObject

@property (nonatomic, copy, readonly) NSString *name;

@property (nonatomic, assign, readonly) NSUInteger argumentCount;

@property (nonatomic, strong, readonly) NSArray *arguments;

- (id)initWithName:(NSString *)name;

- (void)addArgument:(MJLocalizableStringMacroArgument *)argument;

- (void)addArguments:(NSArray *)arguments;

- (MJLocalizableStringMacroArgument *)argumentAtIndex:(NSUInteger)index;

@end
