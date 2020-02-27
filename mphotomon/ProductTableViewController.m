//
//  ProductTableViewController.m
//  photoprint
//
//  Created by photoMac on 2015. 6. 25..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import "ProductTableViewController.h"
//#import "PhotomonInfo.h"
#import "Common.h"

@interface ProductTableViewController () <UITableViewDelegate, SelectPhotoDelegate>

@end

@implementation ProductTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // 딥링크 관련 코드
    if([Common info].deeplink_url != nil) {
        if ( [[Common info].deeplink_url rangeOfString:@"mobile_print"].location != NSNotFound ) {
            [self.navigationController setNavigationBarHidden:NO animated:NO];
            [Common info].deeplink_url= nil;
		}
    }

	[Analysis log:@"PhotoPrintSelectSize"];
    
    //[[PhotomonInfo sharedInfo] loadProductInfo];
    [[Common info].photoprint initPhotoprintInfo];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [Analysis firAnalyticsWithScreenName:@"PhotoPrintSelectSize" ScreenClass:[self.classForCoder description]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

	self.navigationItem.leftBarButtonItem = nil;   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [Common info].photoprint.types.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProductCell" forIndexPath:indexPath];
    
    UILabel *typelabel = (UILabel *)[cell viewWithTag:101];
    UILabel *sizelabel = (UILabel *)[cell viewWithTag:102];
    UILabel *pricelabel = (UILabel *)[cell viewWithTag:103];
    UILabel *dclabel = (UILabel *)[cell viewWithTag:104];
    
    typelabel.text = [Common info].photoprint.types[indexPath.row];
    sizelabel.text = [Common info].photoprint.sizes[indexPath.row];
    pricelabel.text = [NSString stringWithFormat:@"%@원 >", [Common info].photoprint.prices[indexPath.row]];
    dclabel.text = [NSString stringWithFormat:@"%@원", [Common info].photoprint.discounts[indexPath.row]];

    UIImageView *imageview = (UIImageView *)[cell viewWithTag:100];
    NSString *image_name = [NSString stringWithFormat:@"product_%@", typelabel.text];
    imageview.image = [UIImage imageNamed:image_name];
    
    UILabel *msglabel = (UILabel *)[tableView viewWithTag:105];
    msglabel.text = [[Common info].connection productMsg:0];
    //msglabel.numberOfLines = 0;
    //[msglabel sizeToFit];
    
    return cell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
//    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    //[PhotomonInfo sharedInfo].selectedProductType = [PhotomonInfo sharedInfo].productTypes[indexPath.row];
//    [Common info].photoprint.sel_type = [Common info].photoprint.types[indexPath.row];
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[Common info].photoprint.sel_type = [Common info].photoprint.types[indexPath.row];
	[Common info].photobook.product_type = PRODUCT_PHOTOPRINT;
	[[Common info] selectPhoto:self Singlemode:NO MinPictures:0 Param:@"1024"];
}

#pragma mark - SelectPhotoDelegate methods
- (void)selectPhotoDone:(BOOL)is_singlemode {
	//PhotoDetailSegue
	_progressView = [[ProgressView alloc]initWithTitle:@"사진인화 구성 중"];
	
	if (_thread) {
		[_thread cancel];
		_thread = nil;
	}
	
	_thread = [[NSThread alloc] initWithTarget:self selector:@selector(doingThread) object:nil];
	[_thread start];
}

- (void)doingThread {
	
	[_progressView manageProgress:0.0f];
	
	for (int i = 0; i < [PhotoContainer inst].selectCount; i++) {
		PhotoItem *photoItem = [[PhotoContainer inst] getSelectedItem:i];
		[photoItem downloadToMemory];
		[[Common info].photoprint addPhoto:photoItem];
		[_progressView manageProgress:(i + 1.0f) / [PhotoContainer inst].selectCount];
	}
	
	[self performSelectorOnMainThread:@selector(doneThread) withObject:nil waitUntilDone:NO];
}

- (void)doneThread {
	
	[[PhotoContainer inst] initialize];
	
	[_progressView endProgress];
	
	[self performSegueWithIdentifier:@"PhotoDetailSegue" sender:self];
}

- (void)selectPhotoCancel:(BOOL)is_singlemode {
	if (is_singlemode) {
	}
	else {
//		[self.navigationController popViewControllerAnimated:NO];
	}
//	[self clearSelectedInfo];
}

@end
