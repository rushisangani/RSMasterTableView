//
// RSTableViewDataSource.m
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

#import "RSTableViewDataSource.h"

@interface RSTableViewDataSource ()

@property (nonatomic, strong) NSMutableArray *dataArray;                // dataSource array
@property (nonatomic, strong) NSString *cellIdentifier;                 // cell identifier

/* cell configuration block */
@property (nonatomic, copy) void(^TableViewCellConfiguration)(id cell, id object, NSIndexPath *indexPath);

@end

@implementation RSTableViewDataSource

#pragma mark- Public methods

-(instancetype)initWithArray:(NSMutableArray *)dataArray cellIdentifer:(NSString *)cellIdentifier andCellConfiguration:(UITableViewCellConfiguration)cellConfigurationBlock {
    
    self = [super init];
    if(self){
        
        self.dataArray = dataArray;
        self.cellIdentifier = cellIdentifier;
        self.TableViewCellConfiguration = [cellConfigurationBlock copy];
    }
    return self;
}

- (instancetype)initWitSections:(NSMutableArray *)sectionsArray cellIdentifer:(NSString *)cellIdentifier andCellConfiguration:(UITableViewCellConfiguration)cellConfigurationBlock {
    
    self = [self initWithArray:sectionsArray cellIdentifer:cellIdentifier andCellConfiguration:cellConfigurationBlock];
    self.isSectionAvailable = YES;
    
    return self;
}

-(id)objectAtIndexPath:(NSIndexPath *)indexPath {
    
    if(self.isSectionAvailable){
        
        NSArray *sectionData = [self sectionDataArrayAtIndex:indexPath.section];
        return [sectionData objectAtIndex:indexPath.row];
    }
    return [self.dataArray objectAtIndex:indexPath.row];
}

#pragma mark- UITableView DataSource Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if(self.isSectionAvailable){
        return self.dataArray.count;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if(self.isSectionAvailable){
        return [self sectionDataArrayAtIndex:section].count;
    }
    return self.dataArray.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {

    if(self.isSectionAvailable){
        return [self sectionTitleAtIndex:section];
    }
    return nil;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];
    
    if(self.TableViewCellConfiguration){
        
        id object = [self objectAtIndexPath:indexPath];
        self.TableViewCellConfiguration(cell, object, indexPath);
    }
    
    return cell;
}

#pragma mark- Private methods

-(NSString *)sectionTitleAtIndex:(NSUInteger)index {
    
    if(self.dataArray.count > 0){
        
        NSDictionary *dataDict = [self.dataArray objectAtIndex:index];
        return [[dataDict allKeys] firstObject];
    }
    return @"";
}

-(NSArray *)sectionDataArrayAtIndex:(NSInteger)index {
    
    if(self.dataArray.count > 0){
        
        NSString *sectionKey = [self sectionTitleAtIndex:index];
        return [[self.dataArray objectAtIndex:index] objectForKey:sectionKey];
    }
    return @[];
}

@end