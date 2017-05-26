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

typedef void (^UITableViewCellConfiguration)(id _Nonnull cell, id _Nonnull object, NSIndexPath * _Nonnull indexPath);

@interface RSTableViewDataSource : NSObject <UITableViewDataSource>

/* public methods */

/* initialize with array for single tableView section */

-(instancetype _Nonnull )initWithArray:(NSMutableArray *_Nullable)dataArray cellIdentifer:(NSString *_Nonnull)cellIdentifier andCellConfiguration:(UITableViewCellConfiguration _Nonnull )cellConfigurationBlock;

/* initialize with sections for multiple tableView section, where section title will be key of each dictionary and section data will be the array object associated with that key */

-(instancetype _Nonnull )initWitSections:(NSMutableArray *_Nullable)sectionsArray cellIdentifer:(NSString *_Nonnull)cellIdentifier  andCellConfiguration:(UITableViewCellConfiguration _Nonnull )cellConfigurationBlock;

/* get object at indexPath */

-(id _Nullable )objectAtIndexPath:(NSIndexPath *_Nonnull)indexPath;


/* properties */

@property (nonatomic, strong) NSMutableArray * _Nullable dataArray;   /* dataSource array */
@property (nonatomic, assign) BOOL isMultipleSections;     /* check if tableview is with multiple sections */

@end
