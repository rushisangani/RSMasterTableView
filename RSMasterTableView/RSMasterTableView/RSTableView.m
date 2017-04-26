//
// RSTableView.m
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

#import "RSTableView.h"

static NSString   *kDefaultNoDataFoundMessage   = @"No data found.";
static NSString   *kDefaultNoResultFoundMessage = @"No result found.";

@interface RSTableView () <UISearchBarDelegate>
{
    NSString *_noDataFoundMessage;
    BOOL isInfiniteScrollingEnabled;
}

@property (nonatomic, copy) void(^pullToRefreshActionHandler)(void);
@property (nonatomic, copy) void(^infiniteScrollingActionHandler)(void);
@property (nonatomic, copy) void(^refreshAllDataActionHandler)(void);
@property (nonatomic, copy) void(^webSearchActionHandler)(NSString *searchString);

@property (nonatomic, strong) UILabel *lblNoDataFound;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@property (nonatomic, strong) NSString *searchPlaceHolder;
@property (nonatomic, assign) BOOL isPulltoRefershON;
@property (nonatomic, assign) BOOL isSearchON;
@property (nonatomic) CGRect labelFrame;

@end

@implementation RSTableView
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
    
    // add indicatorView
    [self addSubview:self.indicatorView];
    
    self.startIndex = kDefaultStartIndex;
    self.recordsPerPage = kDefaultRecordsPerPage;
    self.totalCount = 0;
}

#pragma mark- Public methods

-(void)setupTableViewWithCellConfiguration:(UITableViewCellConfiguration)cellConfigurationBlock forCellIdentifier:(NSString *)cellIdentifier {
    
    self.tableViewDataSource = [[RSTableViewDataSource alloc] initWithArray:self.dataSourceArray cellIdentifer:cellIdentifier andCellConfiguration:cellConfigurationBlock];
    
    self.dataSource = self.tableViewDataSource;
}

- (void)setupTableViewWithMultipleSections:(UITableViewCellConfiguration)cellConfigurationBlock forCellIdentifier:(NSString *)cellIdentifier {
    
    self.tableViewDataSource = [[RSTableViewDataSource alloc] initWitSections:self.dataSourceArray cellIdentifer:cellIdentifier andCellConfiguration:cellConfigurationBlock];
    
    self.dataSource = self.tableViewDataSource;
}

#pragma mark- Response handling

- (void)didCompleteFetchData:(NSArray *)dataArray withTotalCount:(NSUInteger)totalCount {
    
    // remove old data on pull to refresh and search
    if(self.isPulltoRefershON || self.isSearchON) {
        [self.dataSourceArray removeAllObjects];
    }
    
    // get total count
    self.totalCount = (!_ignoreTotalCount) ? totalCount : 0;
    
    if(self.tableViewDataSource.isMultipleSections){
        
        // perform insertion for multiple section tableview
        
        NSMutableArray * array = [NSMutableArray arrayWithArray:dataArray];
        [self didCompleteFetchDataWithSections:array withTotalCount:totalCount];
    }
    else {
        
        // update start index
        self.startIndex += dataArray.count;
        
        // if no more result then not show infinite scrolling
        BOOL infiniteScrolling = YES;
        
        if ((!_ignoreTotalCount && self.startIndex >= self.totalCount) || dataArray.count < self.recordsPerPage) {
            infiniteScrolling = NO;
        }
        
        /* update flag only if infinite scrolling is enabled */
        
        if(isInfiniteScrollingEnabled)
            self.showsInfiniteScrolling = infiniteScrolling;
        
        // get startRow and endRow
        NSUInteger startRow = self.dataSourceArray.count;
        NSUInteger endRow = startRow + dataArray.count;
        
        // add data to dataSource array first
        
        [self.dataSourceArray addObjectsFromArray:dataArray];
        
        // show no data found message if no data
        if(self.dataSourceArray.count == 0 && (dataArray == nil || dataArray.count == 0)){
            self.lblNoDataFound.hidden = NO;
            [self reloadData];
        }
        else{
            [self insertRowsInSection:0 fromStartIndex:startRow toEndIndex:endRow];
        }
    }
    
    // clear the pull to refresh & infinite scroll
    self.isPulltoRefershON = NO;
    [self stopAnimation];
}

- (void)didFailToFetchdata {
    [self stopAnimation];
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath {
    return [self.tableViewDataSource objectAtIndexPath:indexPath];
}

- (void)refreshAllDataWithActionHandler:(void (^)(void))actionHandler {
    
    self.refreshAllDataActionHandler = nil;
    self.refreshAllDataActionHandler = actionHandler;
    
    [self refreshAllData];
}

-(void)clearAllData {
    
    // clear all data
    [self.dataSourceArray removeAllObjects];
    
    // reload tableview
    [self reloadData];
}

#pragma mark- Custom methods

-(void)didCompleteFetchDataWithSections:(NSMutableArray *)dataArray withTotalCount:(NSUInteger)totalCount {
    
    // update start index
    NSUInteger fetchedRecords = 0;
    
    for (NSDictionary *dict in dataArray) {
        
        NSString *key = [[dict allKeys] firstObject];
        fetchedRecords += [[dict objectForKey:key] count];
    }
    self.startIndex += fetchedRecords;
    
    // if no more result then not show infinite scrolling
    BOOL infiniteScrolling = YES;
    
    if ((!_ignoreTotalCount && self.startIndex >= self.totalCount) || fetchedRecords < self.recordsPerPage) {
        infiniteScrolling = NO;
    }
    
    /* update flag only if infinite scrolling is enabled */
    
    if(isInfiniteScrollingEnabled)
        self.showsInfiniteScrolling = infiniteScrolling;
    
    
    // get startRow, endRow, startSection and endSection to insert data
    
    NSMutableDictionary *currentSectionDict = [NSMutableDictionary dictionaryWithDictionary:[self.dataSourceArray lastObject]];     // current section dictionary
    NSString *sectionKey = [[currentSectionDict allKeys] firstObject];                                                              // current section title as key
    NSMutableArray *currentSectionData = [currentSectionDict objectForKey:sectionKey];                                              // current section data array
    
    NSMutableDictionary *newSectionDict = [NSMutableDictionary dictionaryWithDictionary:[dataArray firstObject]];                   // new section dictionary
    NSString *newSectionKey = [[newSectionDict allKeys] firstObject];                                                               // new section title as key
    NSMutableArray *newSectionData = [newSectionDict objectForKey:newSectionKey];                                                   // new section data array
    
    NSUInteger startRow = 0;
    NSUInteger endRow = 0;
    NSUInteger startSection = 0;
    NSUInteger endSection = 0;
    
    if ([sectionKey isEqualToString:newSectionKey]) {
        
        // add data in same section
        
        startSection = self.dataSourceArray.count - 1;
        
        startRow = currentSectionData.count;
        endRow = startRow + newSectionData.count;
        
        // add data to existing dataSource in current section
        [currentSectionData addObjectsFromArray:newSectionData];
        
        // update to dictionary
        [currentSectionDict setObject:currentSectionData forKey:sectionKey];
        
        // reflect changes in dataSource array
        [self.dataSourceArray replaceObjectAtIndex:startSection withObject:currentSectionDict];
        
        // insert row in same section
        [self insertRowsInSection:startSection fromStartIndex:startRow toEndIndex:endRow];
        
        // remove first object from newDataAray because we've already added to the current section
        [dataArray removeObjectAtIndex:0];
    }
    
    // create new sections
    
    startSection = self.dataSourceArray.count;
    endSection = startSection + dataArray.count;
    
    // add data to dataSource array first
    
    [self.dataSourceArray addObjectsFromArray:dataArray];
    
    // show no data found message if no data
    if(self.dataSourceArray.count == 0){
        self.lblNoDataFound.hidden = NO;
    }
    else{
        [self insertNewSectionsFromStartIndex:startSection toEndIndex:endSection];
    }
}

- (void)insertRowsInSection:(NSUInteger)section fromStartIndex:(NSUInteger)startIndex toEndIndex:(NSUInteger)endIndex {
    
    // hide backgorund label
    self.lblNoDataFound.hidden = YES;
    
    // direct reload if pull to refresh
    if(self.isPulltoRefershON || self.isSearchON){
        [self reloadData];
    }
    
    // insert new rows for infinite scrolling
    else {
        
        NSMutableArray *indexPaths = [NSMutableArray array];
        
        for (; startIndex < endIndex; startIndex++) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:startIndex inSection:section]];
        }
        
        // insert new rows if not 0
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
    if(self.isPulltoRefershON || self.isSearchON){
        [self reloadData];
    }
    else {
        
        // insert new sections
        
        if(startIndex < endIndex){
            
            [self beginUpdates];
            for (; startIndex < endIndex; startIndex++) {
                [self insertSections:[NSIndexSet indexSetWithIndex:startIndex] withRowAnimation:UITableViewRowAnimationNone];
            }
            [self endUpdates];
        }
    }
}

-(void)startAnimation {
    
    self.lblNoDataFound.hidden = YES;
    [self.indicatorView startAnimating];
}

-(void)stopAnimation {
    
    [self.pullToRefreshView stopAnimating];
    [self.infiniteScrollingView stopAnimating];
    [self.indicatorView stopAnimating];
}

#pragma mark- Pull To Refresh

-(void)enablePullToRefreshWithActionHandler:(void (^)(void))actionHandler {
    
    /* add pullToRefresh if search bar is not visible */
    
    if(!_isSearchON){
        
        self.pullToRefreshActionHandler = actionHandler;
        
        __weak typeof(self) weakSelf = self;
        
        [self addPullToRefreshWithActionHandler:^{
            [weakSelf performPullToRefresh];
        }];
    }
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
    }
}

#pragma mark- Infinite Scrolling

-(void)enableInfiniteScrollingWithActionHandler:(void (^)(void))actionHandler {
    
    self.infiniteScrollingActionHandler = actionHandler;
    isInfiniteScrollingEnabled = YES;
    
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

#pragma mark- Refresh all data

-(void)refreshAllData {
    
    if(self.refreshAllDataActionHandler){
        
        [self clearAllData];
        
        // set startIndex to default
        self.startIndex = kDefaultStartIndex;
        
        // once reset, allow the infinite scroll again
        
        if(isInfiniteScrollingEnabled)
            self.showsInfiniteScrolling = YES;
        
        self.refreshAllDataActionHandler();
    }
}

#pragma mark- Web search

-(void)enableWebSearchWithPlaceHolder:(NSString *)placeHolderString actionHandler:(void (^)(NSString *))actionHandler {

    self.searchPlaceHolder = placeHolderString;
    self.webSearchActionHandler = actionHandler;
    self.isSearchON = YES;
    
    /* disable pullToRefresh for search bar */
    self.showsPullToRefresh = self.isPulltoRefershON = self.showsInfiniteScrolling = NO;
    
    [self addSearchBarWithPlaceHolder:self.searchPlaceHolder];
}

-(void)addSearchBarWithPlaceHolder:(NSString *)placeHolder {
    
    self.searchBar = [[RSSearchBar alloc] init];
    [self.searchBar setFrame:CGRectMake(0, 0, self.frame.size.width, kDefaultSearchBarHeight) placeHolder:placeHolder font:nil andTextColor:nil];
    
    self.searchBar.tintColor = [[UIColor darkTextColor] colorWithAlphaComponent:0.9];
    self.searchBar.barTintColor = [UIColor lightGrayColor];
    
    self.searchBar.showsCancelButton = YES;
    self.searchBar.delegate = self;
    
    // add search bar to tableHeaderView
    self.tableHeaderView = self.searchBar;
}

#pragma mark- SearchBar Delegate

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    // remove previous data
    [self.dataSourceArray removeAllObjects];
    [self reloadData];
    
    // hide backgorund label when user is typing
    self.lblNoDataFound.hidden = YES;
    
    // set startIndex to default
    self.startIndex = kDefaultStartIndex;
    
    if(self.webSearchActionHandler){
        
        [self startAnimation];
        self.webSearchActionHandler(searchText);
    }
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.lblNoDataFound.frame = self.labelFrame;
    self.indicatorView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
}

#pragma mark- Setter / Getter

-(NSMutableArray *)dataSourceArray{
    
    if(!_dataSourceArray){
        
        _dataSourceArray = [[NSMutableArray alloc] init];
        return _dataSourceArray;
    }
    return _tableViewDataSource.dataArray;
}

-(void)setNoDataFoundMessage:(NSString *)noDataFoundMessage {
    
    _noDataFoundMessage = noDataFoundMessage;
    self.lblNoDataFound.text = _noDataFoundMessage;
}

-(NSString *)searchPlaceHolder {
    
    if(!_searchPlaceHolder){
        _searchPlaceHolder = @"Search";
    }
    return _searchPlaceHolder;
}

-(NSString *)noDataFoundMessage {
    
    if(!_noDataFoundMessage){
        _noDataFoundMessage = (_isSearchON) ? kDefaultNoResultFoundMessage : kDefaultNoDataFoundMessage;
    }
    return _noDataFoundMessage;
}

-(UIActivityIndicatorView *)indicatorView {
    
    if(!_indicatorView){
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    return _indicatorView;
}

-(UILabel *)lblNoDataFound {
    
    if(!_lblNoDataFound){
        
        _lblNoDataFound = [[UILabel alloc] initWithFrame:self.labelFrame];
        _lblNoDataFound.font = [UIFont systemFontOfSize:17];
        _lblNoDataFound.textAlignment = NSTextAlignmentCenter;
        _lblNoDataFound.numberOfLines = 0;
        _lblNoDataFound.hidden = YES;
        _lblNoDataFound.backgroundColor = [UIColor whiteColor];
        _lblNoDataFound.text = self.noDataFoundMessage;
    }
    return _lblNoDataFound;
}

-(CGRect)labelFrame {
    return CGRectMake(kDefaultLabelMargin, self.bounds.origin.y, self.bounds.size.width-(2*kDefaultLabelMargin), self.bounds.size.height);
}

@end
