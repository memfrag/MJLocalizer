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

#import "MJLocalizableStringMacro.h"

@implementation MJLocalizableStringMacroArgument

- (id)initWithArgument:(MJMacroArgumentId)argument index:(NSUInteger)index
{
    self = [super init];
    if (self) {
        _argument = argument;
        _index = index;
    }
    return self;
}

@end


@implementation MJLocalizableStringMacro {
    NSMutableArray *_arguments;
}

- (id)initWithName:(NSString *)name
{
    self = [super init];
    if (self) {
        _name = [name copy];
        _arguments = [NSMutableArray arrayWithCapacity:10];
    }
    return self;
}

- (NSUInteger)argumentCount
{
    return _arguments.count;
}

- (NSArray *)arguments
{
    return _arguments;
}

- (void)addArgument:(MJLocalizableStringMacroArgument *)argument
{
    [_arguments addObject:argument];
}

- (void)addArguments:(NSArray *)arguments
{
    [_arguments addObjectsFromArray:arguments];
}

- (MJLocalizableStringMacroArgument *)argumentAtIndex:(NSUInteger)index
{
    if (index < _arguments.count) {
        return _arguments[index];
    } else {
        return nil;
    }
}

@end
