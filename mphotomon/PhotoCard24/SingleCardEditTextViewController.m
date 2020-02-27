//
//  CardEditTextViewController.m
//  photoprint
//
//  Created by photoMac on 2015. 6. 30..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import "SingleCardEditTextViewController.h"
#import "Common.h"

#define kOFFSET_FOR_KEYBOARD 80.0

@interface SingleCardEditTextViewController ()

@end

@implementation SingleCardEditTextViewController

BOOL moveup2;

- (void)viewDidLoad {
    [super viewDidLoad];

	moveup2 = NO;
	_scrollview.scrollEnabled = NO;

	_contentview.backgroundColor = [UIColor whiteColor];
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 44)];
    navBar.backgroundColor = [UIColor whiteColor];

    UINavigationItem *navItem = [[UINavigationItem alloc] init];
    navItem.title = @"텍스트 편집";

    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"취소" style:UIBarButtonItemStylePlain target:self action:@selector(onCancel:)];
    navItem.leftBarButtonItem = leftButton;

    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"완료" style:UIBarButtonItemStylePlain target:self action:@selector(onDone:)];
    navItem.rightBarButtonItem = rightButton;

    navBar.items = @[ navItem ];

	UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:nil];
	singleTap.cancelsTouchesInView = NO;
	[navBar addGestureRecognizer:singleTap]; 

	[self.view addSubview:navBar];

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	_textview.delegate = self;
    _textview.layer.borderWidth = 1.0f;
    _textview.layer.borderColor = [[UIColor grayColor] CGColor];

    _constraint_edittext_width.constant = _edittext_width;
    _constraint_edittext_height.constant = _edittext_height;

    float fontsize = _fontsize;
	fontsize = fontsize * 1.00f;
    [_textview setFont:[UIFont systemFontOfSize:fontsize]];
    _textview.text = _textcontents;
	_textview.textAlignment = _alignment;
    _textview.backgroundColor = [UIColor whiteColor];
	_textview.textContainerInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);

	[_textview becomeFirstResponder];

	UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapReceived:)];
    [tapGestureRecognizer setDelegate:self];
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)alignLeft:(id)sender {
	_alignment = NSTextAlignmentLeft;
	_textview.textAlignment = _alignment;
}

- (IBAction)alignCenter:(id)sender {
	_alignment = NSTextAlignmentCenter;
	_textview.textAlignment = _alignment;
}

- (IBAction)alignRight:(id)sender {
	_alignment = NSTextAlignmentRight;
	_textview.textAlignment = _alignment;
}

- (IBAction)onCancel:(id) sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)onDone:(id)sender {
    NSString *text = _textview.text;

	// 2017.12.30 : SJYANG : EUCKR 인코딩으로 저장하여 '뜽' 같은 글자가 저장이 안됨
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	NSString *checkChar = [[Common info] checkEucKr:text];
	if(checkChar != nil) {
		[_textview resignFirstResponder];
		[_textview setBackgroundColor: [UIColor clearColor]];

		NSString *errorMsg = [NSString stringWithFormat:@"다음 글자는 입력하실 수 없는 글자입니다.\n[%@]", checkChar];
        
        [[Common info]alert:self Title:errorMsg Msg:@"" completion:nil];

		return;
	}
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	while([text rangeOfString:@"  "].length > 0) {
		text = [text stringByReplacingOccurrencesOfString:@"  " withString:@" "];
	}

	_textview.text = text;

	NSMutableString *edittext = [NSMutableString stringWithString:text];
	int cnt = 0;
    if (text != nil){
        float currentLineY = -1;
        int currentLineIndex = -1;
        for (int charIndex = 0; charIndex < [text length]; charIndex++){
            UITextPosition *charTextPositionStart = [_textview positionFromPosition:_textview.beginningOfDocument offset:charIndex];
            UITextPosition *charTextPositionEnd = [_textview positionFromPosition:charTextPositionStart offset:+1];
            UITextRange *range = [_textview textRangeFromPosition:charTextPositionStart toPosition:charTextPositionEnd];
            CGRect rectOfChar = [_textview firstRectForRange:range];
            if ((int)rectOfChar.origin.y > (int)currentLineY){
                currentLineY = rectOfChar.origin.y;
                currentLineIndex++;
				NSString *srch = [edittext substringWithRange:NSMakeRange(charIndex + cnt - 1, 1)];
			    if(![srch isEqualToString:@"\n"]) {
					[edittext insertString:@"\n" atIndex:charIndex + cnt];
					cnt++;
				}				
			}
        }
    }
	NSString *imedittext = [edittext copy];

    [_delegate editTextDone:_textview.text withFmtText:imedittext withAlignment:_alignment];
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - UITextViewDelegate methods

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if (text.length == 0)
        return YES;

    if ( (range.location > 0 && [text length] > 0 &&
          [[NSCharacterSet whitespaceCharacterSet] characterIsMember:[text characterAtIndex:0]] &&
          [[NSCharacterSet whitespaceCharacterSet] characterIsMember:[[textView text] characterAtIndex:range.location - 1]]) ) {
        textView.text = [textView.text stringByReplacingCharactersInRange:range withString:@""];
        textView.text = [textView.text stringByReplacingOccurrencesOfString:@"  " withString:@" "];

        //textView.selectedRange = NSMakeRange(range.location+1, 0);
        textView.selectedRange = NSMakeRange(range.location, 0);

        return NO;
    }

    NSString *expr = @"[^ \\-,.\\?\\!_@()a-zA-Z0-9ㄱ-ㅎㅏ-ㅣ가-힣\n]";
    NSRegularExpression *reg_expr = [NSRegularExpression regularExpressionWithPattern:expr options:0 error:nil];
    NSUInteger match_count = [reg_expr numberOfMatchesInString:text options:0 range:NSMakeRange(0, text.length)];
    if (match_count > 0) {
        return NO;
    }

	// 2017.12.29 : SJYANG : EUCKR 인코딩으로 저장하여 '뜽' 같은 글자가 저장이 안됨
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	/*
    @try {
		NSString *val = text;
		NSData *sub_data = [val dataUsingEncoding:NSEUCKREncoding];
		NSString *len = [NSString stringWithFormat:@"%-12lu", (unsigned long)sub_data.length];

		NSLog(@"text : %@ / len : %ld", text, sub_data.length);

		NSUInteger encoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingEUC_KR);
		const char *eucKRString = [text cStringUsingEncoding:encoding];
		NSString *encodedString = [NSString stringWithUTF8String:eucKRString];
		if(encodedString == nil) {
			NSLog(@"걸림1");
			return NO;
		}
		NSLog(@"encodedString : %@", encodedString);
    }
    @catch(NSException *exception) 
	{
		NSLog(@"걸림2");
        return NO;
	}
	*/


	// 이게 제일 잘됨
	/*
    @try {
		const char *euckr_text = [_textview.text cStringUsingEncoding:-2147481280];
		if(euckr_text != nil)
			NSLog(@"strlen(euckr_text) : %d", strlen(euckr_text));
		else {
			NSLog(@"걸림1");
			return NO;
		}
		//NSData *tdata = [NSData dataWithBytes:euckr_text length:strlen(euckr_text)];
	}
    @catch(NSException *exception) 
	{
		NSLog(@"걸림2");
        return NO;
	}
	*/


	/*
	const char *euckr_text = [_textview.text cStringUsingEncoding:-2147481280];
	//const char* utf8_text = [text cStringUsingEncoding:4];
	NSData *tdata = [NSData dataWithBytes:euckr_text length:strlen(euckr_text)];
	//NSString *conv_text = [[NSString alloc] initWithBytes:[tdata bytes] length:[tdata length] encoding:4];
	//NSString *conv_text = [[NSString alloc] initWithBytes:[tdata bytes] length:[tdata length] encoding:-2147481280];
	NSString *conv_text = [NSString stringWithUTF8String:euckr_text];
	NSLog(@"conv_text : %@", conv_text);
	*/
	/*
	if (![conv_text isEqualToString:text])
		return NO;
	*/

	//NSString *euckr_text = [[NSString alloc] initWithData:text encoding:NSEUCKREncoding];
	/*
	if (![euckr_text isEqualToString:text])
		return NO;
	*/
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	return [self doesFit:textView string:text range:range];
}

- (float)doesFit:(UITextView*)textView string:(NSString *)myString range:(NSRange) range;
{
    float viewHeight = textView.frame.size.height;
    float width = textView.textContainer.size.width;

    NSMutableAttributedString *atrs = [[NSMutableAttributedString alloc] initWithAttributedString:textView.textStorage];
    [atrs replaceCharactersInRange:range withString:myString];

    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:atrs];
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize: CGSizeMake(width, FLT_MAX)];
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];

    [layoutManager addTextContainer:textContainer];
    [textStorage addLayoutManager:layoutManager];
    float textHeight = [layoutManager usedRectForTextContainer:textContainer].size.height;

    NSLog(@"textHeight : %f", textHeight);
    NSLog(@"viewHeight : %f", (viewHeight));

	/*
    if (textHeight >= viewHeight - 1) {
        NSLog(@" textHeight >= viewHeight - 1");
        return NO;
    } else
        return YES;
	*/
//    textHeight = textHeight + 3;
    
    if (viewHeight < 25) {
        viewHeight = 25;
    }
    
    if (textHeight >= (viewHeight)) {
        NSLog(@" textHeight >= viewHeight - 1");
        return NO;
    } else
        return YES;
}

- (void)textViewDidChange:(UITextView *)textview{
	NSLog(@"textViewDidChange:");
}


- (void)textViewDidChangeSelection:(UITextView *)textview{
    NSLog(@"textViewDidChangeSelection:");
}


- (BOOL)textViewShouldBeginEditing:(UITextView *)textview{
    NSLog(@"textViewShouldBeginEditing:");
    return YES;
}


- (void)textViewDidBeginEditing:(UITextView *)textview {
    NSLog(@"textViewDidBeginEditing:");
    //textview.backgroundColor = [UIColor greenColor];
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textview{
    NSLog(@"textViewShouldEndEditing:");
    textview.backgroundColor = [UIColor grayColor];
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textview{
    NSLog(@"textViewDidEndEditing:");
}

-(void)tapReceived:(UITapGestureRecognizer *)tapGestureRecognizer
{
   [self.view endEditing:YES];
    _textview.backgroundColor = [UIColor whiteColor];
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

-(void)keyboardWillShow {
    // Animate the current view out of the way
	if(_fontsize*3 < _edittext_height) {
		if (!moveup2)
			[self setViewMovedUp:YES];
		else
			[self setViewMovedUp:NO];
	}
}

-(void)keyboardWillHide {
	if( _fontsize*3 < _edittext_height ) {
		if (!moveup2)
			[self setViewMovedUp:YES];
		else
			[self setViewMovedUp:NO];
	}
}


-(void)textFieldDidBeginEditing:(UITextField *)sender
{
	if(!moveup2 && _fontsize*3 < _edittext_height)
	{
		[self setViewMovedUp:YES];
	}
}

//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovedUp:(BOOL)movedUp
{
	CGFloat scrollx = kOFFSET_FOR_KEYBOARD - (self.view.bounds.size.height - (20 + 38 + 38 + _edittext_height + 8 + 8 + 180));
	if(scrollx < 0 ) scrollx = 0;

	//_constraint_contentview_bottomspace.constant = 667;

	moveup2 = movedUp;
    if (movedUp) {
		_scrollview.scrollEnabled = YES;
		_constraint_contentview_height.constant = self.view.bounds.size.height + 20 + 38 + 38 + 8 + 8 + 80 + scrollx;
		[_scrollview setContentOffset:CGPointMake(0, scrollx) animated:YES];
	}
	else {
		[_scrollview setContentOffset:CGPointMake(0, 0) animated:YES];
		_scrollview.scrollEnabled = NO;
	}
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                         selector:@selector(keyboardWillShow)
                                             name:UIKeyboardWillShowNotification
                                           object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                         selector:@selector(keyboardWillHide)
                                             name:UIKeyboardWillHideNotification
                                           object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                             name:UIKeyboardWillShowNotification
                                           object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                             name:UIKeyboardWillHideNotification
                                           object:nil];
}
@end
