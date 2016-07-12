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

static NSString   *kDefaultNoDataFoundMessage = @"No data found";
static CGFloat    kDefaultStartIndex = 1;
static CGFloat    kDefaultRecordsPerPage = 20;

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

- (void)setupTableViewWithMultipleSections:(UITableViewCellConfiguration)cellConfigurationBlock forCellIdentifier:(NSString *)cellIdentifier {
 
    self.tableViewDataSource = [[RSTableViewDataSource alloc] initWitDictionary:self.dataSourceDictionary cellIdentifer:cellIdentifier andCellConfiguration:cellConfigurationBlock];
    
    self.dataSource = self.tableViewDataSource;
}

- (void)didCompleteFetchData:(NSArray *)dataArray withTotalCount:(NSUInteger)totalCount {
    
    if(dataArray.count > 0 && self.isPulltoRefershON) {
        [self.dataSourceArray removeAllObjects];    // remove old data
    }
    
    // get total count and set new start index
    self.totalCount = totalCount;
    self.startIndex += dataArray.count;
    
    int currentRow = (int)self.dataSourceArray.count;
    
    // if no more result then not show infinite scrolling
    if (self.startIndex >= self.totalCount || dataArray.count < self.recordsPerPage) {
        self.showsInfiniteScrolling = NO;
    }
    else {
        self.showsInfiniteScrolling = YES;
    }
    
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

- (void)didCompleteFetchDataWithSections:(NSDictionary *)dataDictionary andTotalCount:(NSUInteger)totalCount {
    
    if(dataDictionary.count > 0 && self.isPulltoRefershON) {
        [self.dataSourceDictionary removeAllObjects]; // remove old data
    }
    
    // get total count
    self.totalCount = totalCount;
    
    NSUInteger fetchedRecords = 0;
    
    for (NSString *key in [dataDictionary allKeys]) {
        fetchedRecords += [[dataDictionary objectForKey:key] count];
    }
    
    // update start index
    self.startIndex += fetchedRecords;
    
    // if no more result then not show infinite scrolling
    if (self.startIndex >= self.totalCount || fetchedRecords < self.recordsPerPage) {
        self.showsInfiniteScrolling = NO;
    }
    else {
        self.showsInfiniteScrolling = YES;
    }
    
    // check if new data contains same section title as last section title
    
    NSString *lastSectionKey = [[self.dataSourceDictionary allKeys] lastObject];
    NSString *newDataKey = [[dataDictionary allKeys] firstObject];
    
    NSUInteger currentSection = 0, newStartIndex = 0, endIndex = 0, newSectionIndex = 0, newLastSectionIndex = 0;
    BOOL isDataTobeAddInLastSection = NO;
    
    if([lastSectionKey isEqualToString:newDataKey]){
    
        isDataTobeAddInLastSection = YES;
        
        // get current section index
        currentSection = [self.dataSourceDictionary allKeys].count-1;
        
        // get last row index in current section from where we'll add more rows
        newStartIndex = [[self.dataSourceDictionary objectForKey:lastSectionKey] count];
        
        // get count for new records for the same section
        endIndex = newStartIndex + [[dataDictionary objectForKey:newDataKey] count];
    }
    
    // get new section index
    newSectionIndex = [self.dataSourceDictionary allKeys].count;
    
    // get count for new sections
    newLastSectionIndex = newSectionIndex + [[dataDictionary allKeys] count];
    
    // add new data and reload tableView
    [self.dataSourceDictionary addEntriesFromDictionary:dataDictionary];
    
    // show no data found message if no data
    if(self.dataSourceDictionary.count == 0){
        self.lblNoDataFound.hidden = NO;
    }
    else{
        
        if(isDataTobeAddInLastSection){
            [self insertRowsInSection:currentSection fromStartIndex:newStartIndex toEndIndex:endIndex];
        }
        
        [self insertNewSectionsFromStartIndex:newSectionIndex toEndIndex:newLastSectionIndex];
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

- (void)insertRowsInSection:(NSUInteger)section fromStartIndex:(NSUInteger)startIndex toEndIndex:(NSUInteger)endIndex {
 
    // hide backgorund label
    self.lblNoDataFound.hidden = YES;
    
    // direct reload if pull to refresh
    if(self.isPulltoRefershON){
        [self reloadData];
    }
    
    // insert new rows and sections for infinite scrolling
    else {
        
        NSMutableArray *indexPaths = [NSMutableArray array];
        
        for (; startIndex < endIndex; startIndex++) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:startIndex inSection:section]];
        }
        
        // insert new rows
        if(indexPaths.count > 0){
            
            [self beginUpdates];
            [self insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
            [self endUpdates];
        }
    }
}

-(void)insertNewSectionsFromStartIndex:(NSUInteger)startIndex toEndIndex:(NSUInteger)endIndex {
    
    // hide backgorund label
    self.lblNoDataFound.hidden = YES;
    
    // direct reload if pull to refresh
    if(self.isPulltoRefershON){
        [self reloadData];
    }
    
    else {
        
        // insert new sections
        
        [self beginUpdates];
        for (; startIndex < endIndex; startIndex++) {
            
            [self insertSections:[NSIndexSet indexSetWithIndex:startIndex] withRowAnimation:UITableViewRowAnimationNone];
        }
        [self endUpdates];
    }
}

-(void)stopAnimation {
    
    [self.pullToRefreshView stopAnimating];
    [self.infiniteScrollingView stopAnimating];
}

-(BOOL)isRecordsTobeAddedInCurrentSectionFromData:(NSDictionary *)dictionary {
    
    /* check if new data contains same section title as last section title */
    
    NSString *lastSectionKey = [[self.dataSourceDictionary allKeys] lastObject];
    NSString *newDataKey = [[dictionary allKeys] firstObject];
    
    return ([lastSectionKey isEqualToString:newDataKey]);
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

- (NSMutableDictionary *)dataSourceDictionary {
    
    if(!_dataSourceDictionary){
        _dataSourceDictionary = [[NSMutableDictionary alloc] init];
    }
    return _dataSourceDictionary;
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
