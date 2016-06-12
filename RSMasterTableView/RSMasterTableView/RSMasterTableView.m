//
// RSMasterTableView.m
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

#import "RSMasterTableView.h"
#import "SVPullToRefresh.h"

static NSUInteger kDefaultStartIndex = 0;
static NSUInteger kDefaultRecordsPerPage = 20;
static NSString   *kDefaultNoDataFoundMessage = @"No data found";

@interface RSMasterTableView ()
{
    NSString *_noDataFoundMessage;
}
@property (nonatomic, copy) void(^pullToRefreshActionHandler)(void);
@property (nonatomic, copy) void(^infiniteScrollingActionHandler)(void);
@property (nonatomic, assign) BOOL isPulltoRefershON;
@property (nonatomic, strong) UILabel *lblNoDataFound;

@end

@implementation RSMasterTableView
@synthesize noDataFoundMessage = _noDataFoundMessage;

#pragma mark- Init

-(void)awakeFromNib {
    [super awakeFromNib];
    
    [self initialize];
}

-(void)initialize {
    
    self.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin| UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight;
    
    // hide empty cells
    self.tableFooterView = [UIView new];
    
    // set no data found label as background view
    [self setBackgroundView:self.lblNoDataFound];
    
    self.startIndex = kDefaultStartIndex;
    self.recordsPerPage = kDefaultRecordsPerPage;
    self.totalCount = 0;
}

#pragma mark- Public methods

-(void)setupTableViewCellConfiguration:(UITableViewCellConfiguration)cellConfigurationBlock forCellIdentifier:(NSString *)cellIdentifier {
    
    self.tableViewDataSource = [[RSTableViewDataSource alloc] initWithArray:self.dataSourceArray cellIdentifer:cellIdentifier andCellConfiguration:cellConfigurationBlock];
    
    self.dataSource = self.tableViewDataSource;
}

- (void)didCompleteFetchData:(NSArray *)dataArray withTotalCount:(NSUInteger)totalCount {
    
    if(dataArray.count > 0 && self.isPulltoRefershON) {
        [self.dataSourceArray removeAllObjects]; // remove old data
    }
    
    // get total count and set new start index
    self.totalCount = totalCount;
    self.startIndex += dataArray.count;
    
    int currentRow = (int)self.dataSourceArray.count;
    
    // if no more result then not show infinite scrolling
    self.showsInfiniteScrolling = (self.startIndex >= self.totalCount) ? NO : YES;
    
    // add new data and reload tableView
    [self.dataSourceArray addObjectsFromArray:dataArray];
    
    // show no data found message if no data
    if(self.dataSourceArray.count == 0){
        self.lblNoDataFound.hidden = NO;
    }
    else{
        [self reloadTableView:currentRow];
    }
    
    // clear the pull to refresh & infinite scroll
    self.isPulltoRefershON = NO;
    [self stopAnimation];
}

- (void)didFailToFetchdata {
    [self stopAnimation];
}

#pragma mark- Custom methods

-(void)reloadTableView:(int)startingRow {

    // hide backgorund label
    self.lblNoDataFound.hidden = YES;
    
    // direct reload if pull to refresh
    if(self.isPulltoRefershON){
        [self reloadData];
    }
    
    // insert new rows for infinite scrolling
    else {
     
        // add new items after last row
        NSUInteger endingRow = [self.dataSourceArray count];
        
        NSMutableArray *indexPaths = [NSMutableArray array];
        
        for (; startingRow < endingRow; startingRow++) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:startingRow inSection:0]];
        }
        
        // insert new rows
        if(indexPaths.count > 0){
            
            [self beginUpdates];
            [self insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
            [self endUpdates];
        }
    }
}

-(void)stopAnimation {
    
    [self.pullToRefreshView stopAnimating];
    [self.infiniteScrollingView stopAnimating];
}

#pragma mark- Pull To Refresh

-(void)enablePullToRefreshWithActionHandler:(void (^)(void))actionHandler {

    self.pullToRefreshActionHandler = actionHandler;
    
    __weak typeof(self) weakSelf = self;
    
    [self addPullToRefreshWithActionHandler:^{
        [weakSelf performPullToRefresh];
    }];
}

-(void)performPullToRefresh {
    
    if(self.pullToRefreshActionHandler){
        
        // set startIndex to default
        self.startIndex = kDefaultStartIndex;
        
        self.isPulltoRefershON = YES;
        
        // start animation
        [self.pullToRefreshView startAnimating];
        
        // perform action
        self.pullToRefreshActionHandler();
        
        // once refresh, allow the infinite scroll again
        self.showsInfiniteScrolling = YES;
    }
}

#pragma mark- Infinite Scrolling

-(void)enableInfiniteScrollingWithActionHandler:(void (^)(void))actionHandler {
    
    self.infiniteScrollingActionHandler = actionHandler;
    
    __weak typeof(self) weakSelf = self;
    
    [self addInfiniteScrollingWithActionHandler:^{
        [weakSelf performInfiniteScrolling];
    }];
}

-(void)performInfiniteScrolling {
    
    if(self.infiniteScrollingActionHandler){
        
        self.isPulltoRefershON = NO;
        self.infiniteScrollingActionHandler();
    }
}

#pragma mark- Setter / Getter

-(NSMutableArray *)dataSourceArray{
    
    if(!_dataSourceArray){
        _dataSourceArray = [[NSMutableArray alloc] init];
    }
    return _dataSourceArray;
}

-(void)setNoDataFoundMessage:(NSString *)noDataFoundMessage {
    
    _noDataFoundMessage = noDataFoundMessage;
    self.lblNoDataFound.text = _noDataFoundMessage;
}

-(NSString *)noDataFoundMessage {
    
    if(!_noDataFoundMessage){
        _noDataFoundMessage = kDefaultNoDataFoundMessage;
    }
    return _noDataFoundMessage;
}

-(UILabel *)lblNoDataFound {
    
    if(!_lblNoDataFound){
        
        _lblNoDataFound = [[UILabel alloc] initWithFrame:self.frame];
        _lblNoDataFound.text = self.noDataFoundMessage;
        _lblNoDataFound.font = [UIFont systemFontOfSize:16];
        _lblNoDataFound.textAlignment = NSTextAlignmentCenter;
        _lblNoDataFound.numberOfLines = 0;
        _lblNoDataFound.hidden = YES;
    }
    return _lblNoDataFound;
}

@end
