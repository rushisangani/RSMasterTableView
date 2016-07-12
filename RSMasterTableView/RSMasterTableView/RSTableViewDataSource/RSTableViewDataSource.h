//
// RSTableViewDataSource.h
//
// Copyright (c) Rushi Sangani.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^UITableViewCellConfiguration)(id cell, id object, NSIndexPath *indexPath);

@interface RSTableViewDataSource : NSObject <UITableViewDataSource>

/* public methods */

/* initialize with array for single tableView section */

-(instancetype)initWithArray:(NSMutableArray *)dataArray cellIdentifer:(NSString *)cellIdentifier andCellConfiguration:(UITableViewCellConfiguration)cellConfigurationBlock;

/* initialize with dictionary for multiple tableView section, where section title will be key of each item in dictionary and section data will be the array object in dictionary associated with the key */

-(instancetype)initWitDictionary:(NSMutableDictionary *)dataDictionary cellIdentifer:(NSString *)cellIdentifier  andCellConfiguration:(UITableViewCellConfiguration)cellConfigurationBlock;

/* get object at indexPath */

-(id)objectAtIndexPath:(NSIndexPath *)indexPath;

@end
