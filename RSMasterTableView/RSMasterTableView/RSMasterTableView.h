//
// RSMasterTableView.h
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


#import <UIKit/UIKit.h>
#import "RSTableViewDataSource.h"
#import "SVPullToRefresh.h"

@interface RSMasterTableView : UITableView

/* public methods */

/* tableView with single section  */

-(void)setupTableViewCellConfiguration:(UITableViewCellConfiguration)cellConfigurationBlock forCellIdentifier:(NSString *)cellIdentifier;

/* tableView with multiple sections */

-(void)setupTableViewSectionConfiguration:(UITableViewSectionConfiguration)sectionConfigurationBlock cellConfiguration:(UITableViewCellConfiguration)cellConfigurationBlock forCellIdentifier:(NSString *)cellIdentifier;


/* Pull To Refresh */

-(void)enablePullToRefreshWithActionHandler:(void(^)(void))actionHandler;

/* Infinite Scrolling */

-(void)enableInfiniteScrollingWithActionHandler:(void(^)(void))actionHandler;

/* properties */

@property (nonatomic, strong) RSTableViewDataSource *tableViewDataSource;   // DataSource for TableView

@property (nonatomic, strong) NSString *noDataFoundMessage;                 // message to be shown when no data found

@property (nonatomic, strong) NSMutableArray *dataSourceArray;              // dataSource array for TableView with single section

@property (nonatomic, strong) NSMutableDictionary *dataSourceDictionary;    // dataSource dictionary that contains key as a 'Section Title' and value as an array for that section


/* fetch data completion */

-(void)didCompleteFetchData:(NSArray *)dataArray withTotalCount:(NSUInteger)totalCount;     // To be called for table with single section

-(void)didCompleteFetchDataWithSections:(NSDictionary *)dataDictionary;                     // To be called for table with multiple section


/* fetch data failure */

-(void)didFailToFetchdata;

/* Paging properties */

@property (nonatomic, assign) NSUInteger startIndex;
@property (nonatomic, assign) NSUInteger recordsPerPage;
@property (nonatomic, assign) NSUInteger totalCount;


@end
