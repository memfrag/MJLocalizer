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

#import "MJLocalizableStringsTableMerger.h"
#import "MJLocalizableStringsTable.h"

@implementation MJLocalizableStringsTableMerger {
    MJLocalizableStringsTable *_translatedTable;
    MJLocalizableStringsTable *_newTable;
    MJLocalizableStringsTable *_mergedTable;
}


- (id)initWithTranslatedTable:(MJLocalizableStringsTable *)translatedTable
                     newTable:(MJLocalizableStringsTable *)newTable
{
    self = [super init];
    if (self) {
        _translatedTable = translatedTable;
        _newTable = newTable;
    }
    
    return self;
}

- (MJLocalizableStringsTable *)mergedTable
{
    if (![_translatedTable.name isEqualToString:_newTable.name]) {
        return nil;
    }
    
    if (_mergedTable) {
        return _mergedTable;
    }
    
    _mergedTable = [[MJLocalizableStringsTable alloc] initWithName:_newTable.name];
    
    for (MJLocalizableString *string in _translatedTable.localizableStrings) {
        if (!self.keepStringsMissingInNewTable) {
            // Ignore translated strings that are no longer in the new table.
            if ([_newTable containsLocalizableString:string]) {
                [_mergedTable addLocalizableString:string];
            }
        }
    }
    
    // Add new strings that are not in the translated file.
    for (MJLocalizableString *string in _newTable.localizableStrings) {
        if (![_translatedTable containsLocalizableString:string]) {
            [_mergedTable addLocalizableString:string];
        }
    }
    
    return _mergedTable;
}

@end
