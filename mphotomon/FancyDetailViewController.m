//
//  FancyDetailViewController.m
//  PHOTOMON
//
//  Created by ios_dev on 2018. 1. 30..
//  Copyright © 2018년 maybeone. All rights reserved.
//

#import "FancyDetailViewController.h"
#import "ZoomViewController.h"
#import "WebpageViewController.h"
#import "PhotomonInfo.h"

@interface FancyDetailViewController ()

@end

@implementation FancyDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [Analysis log:@"FancyDetail"];
    _order_count.text = @"1";
    
    [self registerForKeyboardNotifications];
    _activeTextField = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [Analysis firAnalyticsWithScreenName:@"FancyDetail" ScreenClass:[self.classForCoder description]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [self setTitle:_selected_theme.theme_name];
    [self updateTheme];
}

- (void)updateTheme {
    if (_selected_theme != nil) {
        NSAssert(_selected_theme.book_infos.count > 0, @"fancy's book_info is not founded");
        _book_info = _selected_theme.book_infos[0]; // 1개 only.
        
        [[Common info].photobook initPhotobookInfo:_book_info ThemeInfo:_selected_theme];
    }
}

- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
}
- (void)keyboardWillShow:(NSNotification*)aNotification {
}
- (void)keyboardDidShow:(NSNotification*)aNotification {
    if (_activeTextField == nil) {
        return;
    }
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    _scrollview.contentInset = contentInsets;
    _scrollview.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, _activeTextField.frame.origin) ) {
        [_scrollview scrollRectToVisible:_activeTextField.frame animated:YES];
    }
}
- (void)keyboardWillHide:(NSNotification*)aNotification {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    _scrollview.contentInset = contentInsets;
    _scrollview.scrollIndicatorInsets = contentInsets;
}
- (void)keyboardDidHide:(NSNotification*)aNotification {
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    _activeTextField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    _activeTextField = nil;
    [self.view endEditing:YES];
}
//-(BOOL)textFieldShouldReturn:(UITextField*)textField {
//    if (textField.returnKeyType == UIReturnKeyNext) {
//        UIResponder *next = [textField.superview viewWithTag:textField.tag+1];
//        [next becomeFirstResponder];
//    } else if (textField.returnKeyType == UIReturnKeyDone) {
//        [textField resignFirstResponder];
//
//        [self signup:nil];
//    }
//    return NO; // We do not want UITextField to insert line-breaks.
//}

// 한글은 조합 과정이 있어서 이런식으로 처리하는게 잘 맞지 않는 듯. 그냥 주문시 체크하는 걸로..
//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
//    if (textField.text.length >= 4 && range.length == 0) {
//        return NO;
//    }
//    return YES;
//}

- (IBAction)popupDetail:(id)sender {
    ZoomViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ZoomPage"];
    vc.selected_theme = _selected_theme;
    vc.option_str = @"";
    vc.product_type = PRODUCT_NAMESTICKER;
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)popupMore:(id)sender {
    NSString *intnum = @"";
    NSString *seqnum = @"";

    BookInfo *bookinfo = _selected_theme.book_infos[0];
    NSString *product_code = bookinfo.productcode;
    //NSString *product_code = [Common info].photobook.ProductCode;
    if (product_code.length == 6) {
        intnum = [product_code substringWithRange:NSMakeRange(0, 3)];
        seqnum = [product_code substringWithRange:NSMakeRange(3, 3)];
    }
    
    NSString *url = [NSString stringWithFormat:URL_PRODUCT_DETAIL, intnum, seqnum];
    WebpageViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WebPage"];
    vc.url = url;
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)increaseCount:(id)sender {
    int cnt = [_order_count.text intValue] + 1;
    if (cnt > 9999) cnt = 9999;
    _order_count.text = [NSString stringWithFormat:@"%d", cnt];
}

- (IBAction)decreaseCount:(id)sender {
    int cnt = [_order_count.text intValue] - 1;
    if (cnt < 1) cnt = 1;
    _order_count.text = [NSString stringWithFormat:@"%d", cnt];
}

- (IBAction)doneClick:(id)sender {
    NSString *param1 = @"";
    NSString *param2 = @"";

    NSString *confirm_msg = @"";
    if (_selected_theme.sel_options && _selected_theme.sel_options.count > 0) {
        if (_selected_theme.sel_options.count == 1) {
            if (_input_string.text.length <= 0 || _input_string.text.length > 4) {
                [[Common info] alert:self Msg:[NSString stringWithFormat:@"%@의 입력 내용을 확인해 주세요.", _input_title.text]];
                return;
            }
            else {
                NSString *checkChar = [[Common info] checkEucKr:_input_string.text];
                if (checkChar != nil) {
                    [[Common info] alert:self Msg:[NSString stringWithFormat:@"다음 글자는 입력하실 수 없는 글자입니다.\n[%@]", checkChar]];
                    return;
                }
            }
            confirm_msg = [NSString stringWithFormat:@"n%@: %@", _input_title.text, _input_string.text];
            param1 = _input_string.text;
        }
        else if (_selected_theme.sel_options.count == 2) {
            if (_input_string.text.length <= 0 || _input_string.text.length > 7) {
                [[Common info] alert:self Msg:[NSString stringWithFormat:@"%@의 입력 내용을 확인해 주세요.", _input_title.text]];
                return;
            }
            else {
                NSString *checkChar = [[Common info] checkEucKr:_input_string.text];
                if (checkChar != nil) {
                    [[Common info] alert:self Msg:[NSString stringWithFormat:@"다음 글자는 입력하실 수 없는 글자입니다.\n[%@]", checkChar]];
                    return;
                }
                
                if (_input_string2.text.length <= 0 || _input_string2.text.length > 4) {
                    [[Common info] alert:self Msg:[NSString stringWithFormat:@"%@의 입력 내용을 확인해 주세요.", _input_title2.text]];
                    return;
                }
                else {
                    NSString *checkChar = [[Common info] checkEucKr:_input_string2.text];
                    if (checkChar != nil) {
                        [[Common info] alert:self Msg:[NSString stringWithFormat:@"다음 글자는 입력하실 수 없는 글자입니다.\n[%@]", checkChar]];
                        return;
                    }
                }
            }
            confirm_msg = [NSString stringWithFormat:@"%@: %@\n%@: %@", _input_title.text, _input_string.text, _input_title2.text, _input_string2.text];
            param1 = _input_string.text;
            param2 = _input_string2.text;
        }
    }
    //MAcheck
    [[Common info]alert:self Title:@"주문 하시겠습니까?" Msg:confirm_msg okCompletion:^{
        [self addCart:self.order_count.text price:self.book_info.discount name_1:param1 name_2:param2];

    } cancelCompletion:^{
        
    } okTitle:@"주문" cancelTitle:@"취소"];
}

- (void)addCart:(NSString *)pkgcnt price:(NSString *)discount name_1:(NSString *)name1 name_2:(NSString *)name2 {
    BookInfo *bookinfo = _selected_theme.book_infos[0];
    if (bookinfo) {
        NSString *user_id = [Common info].user.mUserid;
        NSString *cart_session = [PhotomonInfo sharedInfo].cartSession;
        NSString *product_code = bookinfo.productcode;
        NSString *intnum = @"";
        NSString *seqnum = @"";
        if (product_code.length == 6) {
            intnum = [product_code substringWithRange:NSMakeRange(0, 3)];
            seqnum = [product_code substringWithRange:NSMakeRange(3, 3)];
        }

        // prepare params
        NSMutableArray *params = [[NSMutableArray alloc] init];
        [params addObject: [NSString stringWithFormat:@"userid=%@", user_id]];
        [params addObject: [NSString stringWithFormat:@"cart_session=%@", cart_session]];
        [params addObject: [NSString stringWithFormat:@"Product_code=%@", product_code]];
        [params addObject: [NSString stringWithFormat:@"intnum=%@", intnum]];
        [params addObject: [NSString stringWithFormat:@"seq=%@", seqnum]];
        [params addObject: [NSString stringWithFormat:@"pkgcnt=%@", pkgcnt]];
        [params addObject: [NSString stringWithFormat:@"pkgamount=%@", discount]];
        [params addObject: [NSString stringWithFormat:@"ordermemo=%@", @"ios"]];
        [params addObject: [NSString stringWithFormat:@"name01=%@", name1]];
        [params addObject: [NSString stringWithFormat:@"name02=%@", name2]];
        [params addObject: [NSString stringWithFormat:@"osinfo=%@", @"ios"]];
        [params addObject: [NSString stringWithFormat:@"uniquekey=%@", [Common info].device_uuid]];

        NSString *result_params = [params componentsJoinedByString:@"&"];
        NSString *encoded_params = [result_params stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSData *data = [encoded_params dataUsingEncoding:NSUTF8StringEncoding];
        NSString *data_len = [NSString stringWithFormat:@"%lu", (unsigned long)data.length];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
        [request setHTTPShouldHandleCookies:NO];
        [request setTimeoutInterval:60.0f];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:data];
        [request setValue:data_len forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        
        [request setURL:[NSURL URLWithString:COMMON_URL_CART_ADD_WITH_EDIT2]];
        
        NSData *ret_val = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        if (ret_val != nil) {
            NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
            NSLog(@">> post_fancy: %@", data);
            
            if ([data isEqualToString:@"ok"]) {
                [self.navigationController dismissViewControllerAnimated:NO completion:^{
                    [[Common info].main_controller onCartviaExternalController];
                }];
            }
            else {
                NSLog(@"not ok. fancy.");
            }
        }
    }
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (_selected_theme) {
        _page_control.numberOfPages = _selected_theme.preview_thumbs.count;
        return _selected_theme.preview_thumbs.count;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FancyNameStickerDetailCell" forIndexPath:indexPath];
    
    if (_selected_theme != nil) {
        
        NSString *thumbname = _selected_theme.preview_thumbs[indexPath.row];
        NSString *fullpath = [NSString stringWithFormat:@"%@%@", [Common info].photobook_theme.thumb_url, thumbname];
        //NSLog(@"thumb~:%@", fullpath);

        NSString *url = [fullpath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[Common info] downloadAsyncWithURL:[NSURL URLWithString:url] completionBlock:^(BOOL succeeded, NSData *imageData) {
         if (succeeded) {
             UIImageView *imageview = (UIImageView *)[cell viewWithTag:100];
             imageview.image = [UIImage imageWithData:imageData];
         }
         else {
             NSLog(@"theme-detail's thumbnail_image is not downloaded.");
         }
        }];
        
        // 페이지라벨
        UILabel *page_label = (UILabel *)[cell viewWithTag:500];
        page_label.text = @"";
        
        // 가격
        NSString *price = [[Common info] toCurrencyString:[_book_info.price intValue]];
        NSString *discount = [[Common info] toCurrencyString:[_book_info.discount intValue]];
        _price.text = [NSString stringWithFormat:@"%@원", price];
        _discount.text = [NSString stringWithFormat:@"%@원", discount];
        
        // 사이즈.
        _size_desc.text = _book_info.cm;
        
        // 주문 정보.
        if (_selected_theme.sel_options && _selected_theme.sel_options.count > 0) {
            if (_selected_theme.sel_options.count == 1) {
                SelectOption *item = _selected_theme.sel_options[0];
                _input_title.text = item.comment;
                _input_string.placeholder = @"예시)홍길동";
                _input_desc.text = @"인쇄될 내용을 입력해 주세요.\n최대 4글자까지 가능합니다.";
                
                _input_title2.hidden = YES;
                _input_string2.hidden = YES;
                _input_desc2.hidden = YES;
            }
            else if (_selected_theme.sel_options.count == 2) {
                SelectOption *item = _selected_theme.sel_options[0];
                _input_title.text = item.comment;
                _input_string.placeholder = @"예시)포토몬초등학교";
                _input_desc.text = @"인쇄될 내용을 입력해 주세요.\n최대 7글자까지 가능합니다.";
                
                SelectOption *item2 = _selected_theme.sel_options[1];
                _input_title2.text = item2.comment;
                _input_string2.placeholder = @"예시)홍길동";
                _input_desc2.text = @"인쇄될 내용을 입력해 주세요.\n최대 4글자까지 가능합니다.";
            }
        }

        // 배송 메시지
        NSString *productmsg = [[Common info].connection productMsg:6];
        if (productmsg.length > 0) {
            NSString *temp_msg = [NSString stringWithFormat:@"D+3(토,일 제외)(%.0f만원 이상 무료)", (float)([Common info].connection.delivery_free_cost / 10000)];
            productmsg = [productmsg stringByReplacingOccurrencesOfString:@"입니다." withString:@"."];
            productmsg = [NSString stringWithFormat:@"%@%@", productmsg, temp_msg];
            _deliverymsg.text = productmsg;
            _deliverymsg.numberOfLines = 0;
            [_deliverymsg sizeToFit];
        }
    }
    return cell;
}

#pragma mark <UICollectionViewDelegate>

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat spacing = 0.0f;
    CGFloat width = _collection_view.bounds.size.width - spacing*2;
    CGFloat height = width / 2.0f + 16;
    
    return CGSizeMake(width, height);
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = _collection_view.frame.size.width;
    int page = floor((_collection_view.contentOffset.x - pageWidth/2) / pageWidth) + 1;
    
    _page_control.currentPage = page;
}

@end
