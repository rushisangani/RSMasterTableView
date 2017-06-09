//
// RSTableView.h
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
#import "RSSearchBar.h"


/*******    constants   **********/

static NSUInteger kDefaultStartIndex                = 1;
static NSUInteger kDefaultRecordsPerPage            = 20;
static CGFloat kDefaultLabelMargin                  = 25;


@interface RSTableView : UITableView


/*****  tableView configuration  *******/

-(void)setupTableViewWithCellConfiguration:(UITableViewCellConfiguration)cellConfigurationBlock forCellIdentifier:(NSString *)cellIdentifier;

/* tableView with multiple seciton */

-(void)setupTableViewWithMultipleSections:(UITableViewCellConfiguration)cellConfigurationBlock forCellIdentifier:(NSString *)cellIdentifier;

/* Pull To Refresh */

-(void)enablePullToRefreshWithActionHandler:(void(^)(void))actionHandler;

/* Infinite Scrolling */

-(void)enableInfiniteScrollingWithActionHandler:(void(^)(void))actionHandler;


/* Web search method */

-(void)enableSearchWithPlaceHolder:(NSString *)placeHolderString borderColor:(UIColor *)borderColor actionHandler:(void(^)(NSString *searchString))actionHandler;


/***** fetch data completion *****/

/* To be called for table with single section */

-(void)didCompleteFetchData:(NSArray *)dataArray withTotalCount:(NSUInteger)totalCount;

/* fetch data failure */

-(void)didFailToFetchdata;


/****   get object  ****/

-(id)objectAtIndexPath:(NSIndexPath *)indexPath;


/**** refresh all data *******/

-(void)refreshAllDataWithActionHandler:(void(^)(void))actionHandler;


/*** clear all data *****/

-(void)clearAllData;


/*** start / stop indicator *****/

-(void)startAnimation;

-(void)stopAnimation;


/****** properties  *******/

@property (nonatomic, strong) RSTableViewDataSource *tableViewDataSource;   // DataSource for TableView

@property (nonatomic, strong) RSSearchBar *searchBar;                       // default search bar

@property (nonatomic, strong) NSString *noDataFoundMessage;                 // message to be shown when no data found

@property (nonatomic, strong) NSMutableArray *dataSourceArray;              // dataSource array for TableView


/**** Paging properties ******/

@property (nonatomic, assign) NSUInteger startIndex;
@property (nonatomic, assign) NSUInteger recordsPerPage;
@property (nonatomic, assign) NSUInteger totalCount;


/* ignore total count if server is no sending total count */

@property (nonatomic, assign) BOOL ignoreTotalCount;

@end
