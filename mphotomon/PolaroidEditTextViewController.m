//
//  PolaroidEditTextViewController.m
//  photoprint
//
//  Created by photoMac on 2015. 6. 30..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import "PolaroidEditTextViewController.h"
#import "Common.h"

#define kOFFSET_FOR_KEYBOARD 80.0

@interface PolaroidEditTextViewController ()

@end

@implementation PolaroidEditTextViewController

BOOL polaroid_moveup;
// [^ \\-,.\\?\\!_@()a-zA-Z0-9ㄱ-ㅎㅏ-ㅣ가-힣\n]
static NSString *pureTextRegexStr = @"[^ \\-,.\\?\\!_@()a-zA-Z0-9ㄱ-ㅎㅏ-ㅣ가각간갇갈갉갊감갑값갓갔강갖갗같갚갛개객갠갤갬갭갯갰갱갸갹갼걀걋걍걔걘걜거걱건걷걸걺검겁것겄겅겆겉겊겋게겐겔겜겝겟겠겡겨격겪견겯결겸겹겻겼경곁계곈곌곕곗고곡곤곧골곪곬곯곰곱곳공곶과곽관괄괆괌괍괏광괘괜괠괩괬괭괴괵괸괼굄굅굇굉교굔굘굡굣구국군굳굴굵굶굻굼굽굿궁궂궈궉권궐궜궝궤궷귀귁귄귈귐귑귓규균귤그극근귿글긁금급긋긍긔기긱긴긷길긺김깁깃깅깆깊까깍깎깐깔깖깜깝깟깠깡깥깨깩깬깰깸깹깻깼깽꺄꺅꺌꺼꺽꺾껀껄껌껍껏껐껑께껙껜껨껫껭껴껸껼꼇꼈꼍꼐꼬꼭꼰꼲꼴꼼꼽꼿꽁꽂꽃꽈꽉꽐꽜꽝꽤꽥꽹꾀꾄꾈꾐꾑꾕꾜꾸꾹꾼꿀꿇꿈꿉꿋꿍꿎꿔꿜꿨꿩꿰꿱꿴꿸뀀뀁뀄뀌뀐뀔뀜뀝뀨끄끅끈끊끌끎끓끔끕끗끙끝끼끽낀낄낌낍낏낑나낙낚난낟날낡낢남납낫났낭낮낯낱낳내낵낸낼냄냅냇냈냉냐냑냔냘냠냥너넉넋넌널넒넓넘넙넛넜넝넣네넥넨넬넴넵넷넸넹녀녁년녈념녑녔녕녘녜녠노녹논놀놂놈놉놋농높놓놔놘놜놨뇌뇐뇔뇜뇝뇟뇨뇩뇬뇰뇹뇻뇽누눅눈눋눌눔눕눗눙눠눴눼뉘뉜뉠뉨뉩뉴뉵뉼늄늅늉느늑는늘늙늚늠늡늣능늦늪늬늰늴니닉닌닐닒님닙닛닝닢다닥닦단닫달닭닮닯닳담답닷닸당닺닻닿대댁댄댈댐댑댓댔댕댜더덕덖던덛덜덞덟덤덥덧덩덫덮데덱덴델뎀뎁뎃뎄뎅뎌뎐뎔뎠뎡뎨뎬도독돈돋돌돎돐돔돕돗동돛돝돠돤돨돼됐되된될됨됩됫됴두둑둔둘둠둡둣둥둬뒀뒈뒝뒤뒨뒬뒵뒷뒹듀듄듈듐듕드득든듣들듦듬듭듯등듸디딕딘딛딜딤딥딧딨딩딪따딱딴딸땀땁땃땄땅땋때땍땐땔땜땝땟땠땡떠떡떤떨떪떫떰떱떳떴떵떻떼떽뗀뗄뗌뗍뗏뗐뗑뗘뗬또똑똔똘똥똬똴뙈뙤뙨뚜뚝뚠뚤뚫뚬뚱뛔뛰뛴뛸뜀뜁뜅뜨뜩뜬뜯뜰뜸뜹뜻띄띈띌띔띕띠띤띨띰띱띳띵라락란랄람랍랏랐랑랒랖랗래랙랜랠램랩랫랬랭랴략랸럇량러럭런럴럼럽럿렀렁렇레렉렌렐렘렙렛렝려력련렬렴렵렷렸령례롄롑롓로록론롤롬롭롯롱롸롼뢍뢨뢰뢴뢸룀룁룃룅료룐룔룝룟룡루룩룬룰룸룹룻룽뤄뤘뤠뤼뤽륀륄륌륏륑류륙륜률륨륩륫륭르륵른를름릅릇릉릊릍릎리릭린릴림립릿링마막만많맏말맑맒맘맙맛망맞맡맣매맥맨맬맴맵맷맸맹맺먀먁먈먕머먹먼멀멂멈멉멋멍멎멓메멕멘멜멤멥멧멨멩며멱면멸몃몄명몇몌모목몫몬몰몲몸몹못몽뫄뫈뫘뫙뫼묀묄묍묏묑묘묜묠묩묫무묵묶문묻물묽묾뭄뭅뭇뭉뭍뭏뭐뭔뭘뭡뭣뭬뮈뮌뮐뮤뮨뮬뮴뮷므믄믈믐믓미믹민믿밀밂밈밉밋밌밍및밑바박밖밗반받발밝밞밟밤밥밧방밭배백밴밸뱀뱁뱃뱄뱅뱉뱌뱍뱐뱝버벅번벋벌벎범법벗벙벚베벡벤벧벨벰벱벳벴벵벼벽변별볍볏볐병볕볘볜보복볶본볼봄봅봇봉봐봔봤봬뵀뵈뵉뵌뵐뵘뵙뵤뵨부북분붇불붉붊붐붑붓붕붙붚붜붤붰붸뷔뷕뷘뷜뷩뷰뷴뷸븀븃븅브븍븐블븜븝븟비빅빈빌빎빔빕빗빙빚빛빠빡빤빨빪빰빱빳빴빵빻빼빽뺀뺄뺌뺍뺏뺐뺑뺘뺙뺨뻐뻑뻔뻗뻘뻠뻣뻤뻥뻬뼁뼈뼉뼘뼙뼛뼜뼝뽀뽁뽄뽈뽐뽑뽕뾔뾰뿅뿌뿍뿐뿔뿜뿟뿡쀼쁑쁘쁜쁠쁨쁩삐삑삔삘삠삡삣삥사삭삯산삳살삵삶삼삽삿샀상샅새색샌샐샘샙샛샜생샤샥샨샬샴샵샷샹섀섄섈섐섕서석섞섟선섣설섦섧섬섭섯섰성섶세섹센셀셈셉셋셌셍셔셕션셜셤셥셧셨셩셰셴셸솅소속솎손솔솖솜솝솟송솥솨솩솬솰솽쇄쇈쇌쇔쇗쇘쇠쇤쇨쇰쇱쇳쇼쇽숀숄숌숍숏숑수숙순숟술숨숩숫숭숯숱숲숴쉈쉐쉑쉔쉘쉠쉥쉬쉭쉰쉴쉼쉽쉿슁슈슉슐슘슛슝스슥슨슬슭슴습슷승시식신싣실싫심십싯싱싶싸싹싻싼쌀쌈쌉쌌쌍쌓쌔쌕쌘쌜쌤쌥쌨쌩썅써썩썬썰썲썸썹썼썽쎄쎈쎌쏀쏘쏙쏜쏟쏠쏢쏨쏩쏭쏴쏵쏸쐈쐐쐤쐬쐰쐴쐼쐽쑈쑤쑥쑨쑬쑴쑵쑹쒀쒔쒜쒸쒼쓩쓰쓱쓴쓸쓺쓿씀씁씌씐씔씜씨씩씬씰씸씹씻씽아악안앉않알앍앎앓암압앗았앙앝앞애액앤앨앰앱앳앴앵야약얀얄얇얌얍얏양얕얗얘얜얠얩어억언얹얻얼얽얾엄업없엇었엉엊엌엎에엑엔엘엠엡엣엥여역엮연열엶엷염엽엾엿였영옅옆옇예옌옐옘옙옛옜오옥온올옭옮옰옳옴옵옷옹옻와왁완왈왐왑왓왔왕왜왝왠왬왯왱외왹왼욀욈욉욋욍요욕욘욜욤욥욧용우욱운울욹욺움웁웃웅워웍원월웜웝웠웡웨웩웬웰웸웹웽위윅윈윌윔윕윗윙유육윤율윰윱윳융윷으윽은을읊음읍읏응읒읓읔읕읖읗의읜읠읨읫이익인일읽읾잃임입잇있잉잊잎자작잔잖잗잘잚잠잡잣잤장잦재잭잰잴잼잽잿쟀쟁쟈쟉쟌쟎쟐쟘쟝쟤쟨쟬저적전절젊점접젓정젖제젝젠젤젬젭젯젱져젼졀졈졉졌졍졔조족존졸졺좀좁좃종좆좇좋좌좍좔좝좟좡좨좼좽죄죈죌죔죕죗죙죠죡죤죵주죽준줄줅줆줌줍줏중줘줬줴쥐쥑쥔쥘쥠쥡쥣쥬쥰쥴쥼즈즉즌즐즘즙즛증지직진짇질짊짐집짓징짖짙짚짜짝짠짢짤짧짬짭짯짰짱째짹짼쨀쨈쨉쨋쨌쨍쨔쨘쨩쩌쩍쩐쩔쩜쩝쩟쩠쩡쩨쩽쪄쪘쪼쪽쫀쫄쫌쫍쫏쫑쫓쫘쫙쫠쫬쫴쬈쬐쬔쬘쬠쬡쭁쭈쭉쭌쭐쭘쭙쭝쭤쭸쭹쮜쮸쯔쯤쯧쯩찌찍찐찔찜찝찡찢찧차착찬찮찰참찹찻찼창찾채책챈챌챔챕챗챘챙챠챤챦챨챰챵처척천철첨첩첫첬청체첵첸첼쳄쳅쳇쳉쳐쳔쳤쳬쳰촁초촉촌촐촘촙촛총촤촨촬촹최쵠쵤쵬쵭쵯쵱쵸춈추축춘출춤춥춧충춰췄췌췐취췬췰췸췹췻췽츄츈츌츔츙츠측츤츨츰츱츳층치칙친칟칠칡침칩칫칭카칵칸칼캄캅캇캉캐캑캔캘캠캡캣캤캥캬캭컁커컥컨컫컬컴컵컷컸컹케켁켄켈켐켑켓켕켜켠켤켬켭켯켰켱켸코콕콘콜콤콥콧콩콰콱콴콸쾀쾅쾌쾡쾨쾰쿄쿠쿡쿤쿨쿰쿱쿳쿵쿼퀀퀄퀑퀘퀭퀴퀵퀸퀼큄큅큇큉큐큔큘큠크큭큰클큼큽킁키킥킨킬킴킵킷킹타탁탄탈탉탐탑탓탔탕태택탠탤탬탭탯탰탱탸턍터턱턴털턺텀텁텃텄텅테텍텐텔템텝텟텡텨텬텼톄톈토톡톤톨톰톱톳통톺톼퇀퇘퇴퇸툇툉툐투툭툰툴툼툽툿퉁퉈퉜퉤튀튁튄튈튐튑튕튜튠튤튬튱트특튼튿틀틂틈틉틋틔틘틜틤틥티틱틴틸팀팁팃팅파팍팎판팔팖팜팝팟팠팡팥패팩팬팰팸팹팻팼팽퍄퍅퍼퍽펀펄펌펍펏펐펑페펙펜펠펨펩펫펭펴편펼폄폅폈평폐폘폡폣포폭폰폴폼폽폿퐁퐈퐝푀푄표푠푤푭푯푸푹푼푿풀풂품풉풋풍풔풩퓌퓐퓔퓜퓟퓨퓬퓰퓸퓻퓽프픈플픔픕픗피픽핀필핌핍핏핑하학한할핥함합핫항해핵핸핼햄햅햇했행햐향허헉헌헐헒험헙헛헝헤헥헨헬헴헵헷헹혀혁현혈혐협혓혔형혜혠혤혭호혹혼홀홅홈홉홋홍홑화확환활홧황홰홱홴횃횅회획횐횔횝횟횡효횬횰횹횻후훅훈훌훑훔훗훙훠훤훨훰훵훼훽휀휄휑휘휙휜휠휨휩휫휭휴휵휸휼흄흇흉흐흑흔흖흗흘흙흠흡흣흥흩희흰흴흼흽힁히힉힌힐힘힙힛힝\n]";

- (void)viewDidLoad {
    [super viewDidLoad];

	polaroid_moveup = NO;
	_scrollview.scrollEnabled = NO;
	_textview.autocorrectionType = UITextAutocorrectionTypeNo;
	_stextview.autocorrectionType = UITextAutocorrectionTypeNo;

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

    [self.view addSubview:navBar];

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	_textview.delegate = self;
    _textview.layer.borderWidth = 1.0f;
    _textview.layer.borderColor = [[UIColor grayColor] CGColor];

	_stextview.delegate = self;
    _stextview.layer.borderWidth = 1.0f;
    _stextview.layer.borderColor = [[UIColor grayColor] CGColor];

	if(self.view.bounds.size.width >= 375.f) 
		_constraint_edittext_width.constant = _edittext_width * 1.5f + 0.65f;
	else 
		_constraint_edittext_width.constant = _edittext_width * 1.5f + 0.5732f;
    _constraint_edittext_width.constant = _edittext_width * 1.5f + 0.65f; // 0.57f ~ 0.65f
    _constraint_edittext_height.constant = _edittext_height * 1.5f;

    float fontsize = _fontsize;
	fontsize = fontsize * 2.34f * [Common info].photobook.edit_scale;
    [_textview setFont:[UIFont systemFontOfSize:fontsize]];
    _textview.text = _textcontents;
	_textview.textAlignment = _alignment;
    _textview.backgroundColor = [UIColor whiteColor];
	if(self.view.bounds.size.width >= 375.f) 
		_textview.textContainerInset = UIEdgeInsetsMake(_constraint_edittext_height.constant * 0.005f, _constraint_edittext_width.constant * 0.004f, 0, _constraint_edittext_width.constant * 0.004f);
	else 
		_textview.textContainerInset = UIEdgeInsetsMake(_constraint_edittext_height.constant * 0.005f, _constraint_edittext_width.constant * 0.002f, 0, _constraint_edittext_width.constant * 0.002f);

    _stextview.text = _textcontents;
	_stextview.textAlignment = _alignment;
    _stextview.backgroundColor = [UIColor whiteColor];
	_stextview.textContainerInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);

	[_textview becomeFirstResponder];

	UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapReceived:)];
    [tapGestureRecognizer setDelegate:self];
    [self.view addGestureRecognizer:tapGestureRecognizer];

	/*
	NSString* inserttext = @"안녕하셍";
	for(int i=0;i<[inserttext length];i++) {
		NSString* insertchar = [inserttext substringWithRange:NSMakeRange(i, 1)];
		NSString* ttext = [_textview.text stringByAppendingString:insertchar];
		if([self doesFit:_textview string:ttext range:NSMakeRange(0, [_textview.text length])] == YES) {
			_textview.text = ttext;
		}
	}
	*/
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

- (IBAction)onDone_AfterWorks:(id)sender {
    NSString *text = _textview.text;

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

- (IBAction)onDone:(id)sender {
    _textview.backgroundColor = [UIColor whiteColor];
    _stextview.backgroundColor = [UIColor whiteColor];

	// 2018.01.02 : SJYANG : EUCKR 인코딩으로 저장하여 '뜽' 같은 글자가 저장이 안됨
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    NSString *text = _textview.text;
	NSString *checkChar = [[Common info] checkEucKr:text];
	if(checkChar != nil) {
		[_textview resignFirstResponder];
		[_textview setBackgroundColor: [UIColor clearColor]];

		NSString *errorMsg = [NSString stringWithFormat:@"다음 글자는 입력하실 수 없는 글자입니다.\n[%@]", checkChar];
        [[Common info]alert:self Msg:errorMsg];
		return;
	}
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	NSError *error = nil;
	NSString* string = _textview.text;
	NSRegularExpression *pureTextRegex = [NSRegularExpression regularExpressionWithPattern:pureTextRegexStr options:NSRegularExpressionCaseInsensitive error:&error];
	NSUInteger match_count = [pureTextRegex numberOfMatchesInString:string options:0 range:NSMakeRange(0, string.length)];
	if (match_count > 0) {
        [[Common info]alert:self Title:@"입력하신 글자 중 사용하실 수 없는 글자(특수문자/이모티콘/깨진한글 등)가 있어, 해당 내용이 자동으로 편집되었으니 확인해 주시기 바랍니다." Msg:@"" completion:^{
            NSString *modifiedString = [pureTextRegex stringByReplacingMatchesInString:string options:0 range:NSMakeRange(0, [string length]) withTemplate:@""];
            
            self.stextview.text = self.textview.text = modifiedString;
            [self onDone_AfterWorks:nil];

        }];
		return;
	}
	[self onDone_AfterWorks:nil];
}

#pragma mark - UITextViewDelegate methods

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    _textview.backgroundColor = [UIColor whiteColor];
    _stextview.backgroundColor = [UIColor whiteColor];

	if(textView == _textview) {
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

		return [self doesFit:textView string:text range:range];
	}
	else {
		NSString* inserttext = text;
		for(int i=0;i<[inserttext length];i++) {
			NSString* insertchar = [inserttext substringWithRange:NSMakeRange(i, 1)];
			NSString* ttext = [_textview.text stringByAppendingString:insertchar];
			if([self doesFit:_textview string:ttext range:NSMakeRange(0, [_textview.text length])] == YES) {
				_textview.text = ttext;
			}
		}
	}
	return YES;
}

-(void)scrollTextViewToBottom:(UITextView *)textView {
    _textview.backgroundColor = [UIColor whiteColor];
    _stextview.backgroundColor = [UIColor whiteColor];

     if(textView.text.length > 0 ) {
        NSRange bottom = NSMakeRange(textView.text.length -1, 1);
        [textView scrollRangeToVisible:bottom];
     }
}

- (float)doesFit:(UITextView*)textView string:(NSString *)myString range:(NSRange) range;
{
    _textview.backgroundColor = [UIColor whiteColor];
    _stextview.backgroundColor = [UIColor whiteColor];

	if(textView == _textview) {
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

		[self scrollTextViewToBottom:textView];
		[textView layoutIfNeeded];

		NSLog(@"textHeight : %f", textHeight);
		NSLog(@"viewHeight : %f", viewHeight);
		// TODO : 반드시 수정!!
		// 여기를 바꿔주면 되는데, 2줄이면 _fontSize 의 3배가 되어야 함
		if (textHeight >= viewHeight) {
			NSLog(@"textHeight >= viewHeight - 1");
			return NO;
		} else
			return YES;
	}
	return YES;
}

- (void)textViewDidChange:(UITextView *)textview{
    _textview.backgroundColor = [UIColor whiteColor];
    _stextview.backgroundColor = [UIColor whiteColor];

	NSLog(@"textViewDidChange:");
	if(textview == _textview) {
		_stextview.text = _textview.text;
	}
	else if(textview == _stextview) {
		NSString* inserttext = _stextview.text;
		if([self doesFit:_textview string:inserttext range:NSMakeRange(0, [_textview.text length])] == YES) {
			_textview.text = inserttext;
		}
	}
}


- (void)textViewDidChangeSelection:(UITextView *)textview{
    NSLog(@"textViewDidChangeSelection:");
}


- (BOOL)textViewShouldBeginEditing:(UITextView *)textview{
    NSLog(@"textViewShouldBeginEditing:");
    return YES;
}


- (void)textViewDidBeginEditing:(UITextView *)textview {
    _textview.backgroundColor = [UIColor whiteColor];
    _stextview.backgroundColor = [UIColor whiteColor];

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
    _stextview.backgroundColor = [UIColor whiteColor];
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
		if (!polaroid_moveup)
			[self setViewMovedUp:YES];
		else
			[self setViewMovedUp:NO];
	}
}

-(void)keyboardWillHide {
	if( _fontsize*3 < _edittext_height ) {
		if (!polaroid_moveup)
			[self setViewMovedUp:YES];
		else
			[self setViewMovedUp:NO];
	}
}


-(void)textFieldDidBeginEditing:(UITextField *)sender
{
	if(!polaroid_moveup && _fontsize*3 < _edittext_height)
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

	polaroid_moveup = movedUp;
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
