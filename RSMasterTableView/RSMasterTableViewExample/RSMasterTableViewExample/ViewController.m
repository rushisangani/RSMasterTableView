//
//  ViewController.m
//  RSMasterTableViewExample
//
//  Created by Rushi Sangani on 12/06/16.
//  Copyright © 2016 Rushi Sangani. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureTableView];
}

#pragma mark- TableView Setup

-(void)configureTableView {
    
    __weak typeof(self) weakSelf = self;
    
    /* setup tableView */
    
    [self.tableView setupTableViewCellConfiguration:^(id cell, id object, NSIndexPath *indexPath) {
        [weakSelf setData:object forCell:cell atIndexPath:indexPath];
        
    } forCellIdentifier:@"cell"];
    
    
    /* enable pull to refresh */
    
    [self.tableView enablePullToRefreshWithActionHandler:^{
        [weakSelf fetchDataFromServer];
    }];
    
    /* enable infinte scrolling */
    
    [self.tableView enableInfiniteScrollingWithActionHandler:^{
        [weakSelf fetchDataFromServer];
    }];
    
    /* modify statIndex, records per page etc here */
    
    self.tableView.startIndex = 1;
    self.tableView.recordsPerPage = 20;
    self.tableView.noDataFoundMessage = @"No Records found";
}

#pragma mark- Set data in cell

-(void)setData:(id)data forCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.textLabel.text = [data valueForKey:@"name"];
}

-(void)fetchDataFromServer {
    
    /* send request here */
    
    id response = nil;  /* get response here */
    
    [self didGetResponseFromServer:response];
}

#pragma mark- Success

-(void)didGetResponseFromServer:(id)response {
 
    /* inform tableview about data array and total pages */
    
    NSMutableArray *array = response;
    NSUInteger totalDatacount = 100;    /* get total count from server */
    
    [self.tableView didCompleteFetchData:array withTotalCount:totalDatacount];
}

#pragma mark- Failure

-(void)didFailToGetData {
    
    /* inform tableview in failure */
    
    [self.tableView didFailToFetchdata];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
