# RSMasterTableView

A powerful **UITableView** with inbuilt **PullToRefresh** and **Load More** (Infinite Scrolling) functionality. RSMasterTableView is built upon [SVPullToRefresh] (https://github.com/samvermette/SVPullToRefresh) for PullToRefresh and Infinite Scrolling.

**RSMasterTableView** can be used a normal tableView as well as with **PullToRefresh** and **Infinite Scrolling**. No need to write complex code to manage data and paging structure.


## Features

- Enable PullToRefresh and Infinite Scrolling using single method.
- Manage Paging in TableView internally by calling simple methods.


## How To Use

### Enable PullToRefresh

```objective-c
[self.tableView enablePullToRefreshWithActionHandler:^{
    
    /* Make your API call here */
    [self fetchDataFromServer];
}];
```

### Enable Load More (Infinite Scrolling)

```objective-c
[self.tableView enableInfiniteScrollingWithActionHandler:^{

    /* Make your API call here */
    [self fetchDataFromServer];
}];
```

## Usage

```objective-c
#pragma mark- TableView Setup

-(void)configureTableView {

    /* setup tableView */

    [self.tableView setupTableViewCellConfiguration:^(id cell, id object, NSIndexPath *indexPath) {
        
        /* set data to TableView cell */

    } forCellIdentifier:@"cell"];

    /* enable Infinite Scrolling */

    [self.tableView enableInfiniteScrollingWithActionHandler:^{

        /* Make your API call here */
        [self fetchDataFromServer];
    }];

    /* modify statIndex, records per page etc */

    self.tableView.startIndex = 1;
    self.tableView.recordsPerPage = 20;
    self.tableView.noDataFoundMessage = @"No Records found";
}

-(void)fetchDataFromServer {

    /* send request here */

    id response;  /* get response here */

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

```


## License

RSMasterTableView is released under the MIT license. See LICENSE for details.
