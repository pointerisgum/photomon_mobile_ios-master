//
//  Photobook.h
//  PHOTOMON
//
//  Created by photoMac on 2015. 9. 4..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "PhotoPool.h"
#import "LayoutPool.h"
#import "BackgroundPool.h"
#import "PhotobookTheme.h"
#import "Instagram.h"
#import "PhotoContainer.h"

/*
 Korean (Mac OS)          0×80000003
 Korean (Windows, DOS) 0×80000422
 Korean (ISO 2022-KR)  0×80000840
 Korean (EUC)    0×80000940
 */
#define NSEUCKREncoding (-2147481280)

@interface MemorialDay : NSObject
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSString *date;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *lunar;
@property (strong, nonatomic) NSString *data;
@end

/*
// <text>
@interface Text : NSObject

@property (strong, nonatomic) NSString *gid;
@property (strong, nonatomic) NSString *fontname;
@property (assign) int fontsize;
@property (assign) BOOL italic;
@property (assign) BOOL bold;
@property (strong, nonatomic) UIColor *color;
@property (strong, nonatomic) NSString *halign;

@end
*/
// <imageinfo>
#pragma mark - Layer
@interface Layer : NSObject <NSCoding>

// ctg format
@property (assign) int AreaType; // 레이어 종류 0 -> 이미지레이어, 1 -> 스티커 레이어, 2 -> 텍스트 레이어 .......
@property (assign) int PageIndex; // 페이지 순서 ......................................................
@property (assign) int LayerIndex; // 레이어 순서 .....................................................
@property (assign) BOOL Edited; // 사용안함
@property (assign) BOOL RightContent; // 사용안함
@property (assign) int MaskX; // 코디 레이어 영역 x 좌표 ................................................
@property (assign) int MaskY;// 코디 레이어 영역 y 좌표 .................................................
@property (assign) int MaskW;// 코디 레이어 영역 width .................................................
@property (assign) int MaskH; // 코디 레이어 영역 height ...............................................
@property (assign) int MaskR;// 코디 레이어 영역 rotation ..............................................
@property (strong, nonatomic) NSString *MaskRotateflip; // 현재 사용안함
@property (assign) float MaskAlpha;// 현재 사용안함
@property (strong, nonatomic) NSString *MaskMonotone;// 현재 사용안함
@property (assign) BOOL MaskMultiply;// 현재 사용안함
@property (assign) float MaskContrast;// 현재 사용안함
@property (assign) float MaskBrightness;// 현재 사용안함
@property (assign) int X; // 현재 사용안함
@property (assign) int Y;// 현재 사용안함
@property (assign) int W;// 현재 사용안함
@property (assign) int H;// 현재 사용안함
@property (assign) int R;// 현재 사용안함
@property (assign) int ImageR;// 현재 이미지 편집시 rotate 에 사용됨 ......................................
@property (assign) int ColorMode; // 현재 사용안함
@property (assign) float Contrast;// 현재 사용안함
@property (assign) float Brightness;// 현재 사용안함
@property (assign) BOOL Flip;// 현재 사용안함
@property (assign) BOOL Flop;// 현재 사용안함
@property (assign) int Alpha;// icon, diagramfilename..
@property (assign) int Filter1;// 현재 사용안함
@property (assign) int Filter2;// 현재 사용안함
@property (assign) int Filter3;// 현재 사용안함
@property (assign) int Filter4;// 현재 사용안함
@property (assign) int Filter5;// 현재 사용안함
@property (strong, nonatomic) NSString *FrameFilename;// diagramfilename..
@property (strong, nonatomic) NSString *SkinFilename;// 마그넷
@property (assign) int FrameSize;// 현재 사용안함
@property (assign) int FrameColor;// 현재 사용안함
@property (assign) int FrameAlpha;// icon, diagramfilename..
@property (strong, nonatomic) NSString *Filename;// 갤러리 파일 url ...................................
@property (strong, nonatomic) NSString *ImageFilename;// 보관함폴더의 파일이름 ...........................
@property (strong, nonatomic) NSString *ImageEditname;// 편집용파일이름 ................................
@property (assign) int ImageOriWidth; // 원본 pixel .................................................
@property (assign) int ImageOriHeight;// 원본 pixel .................................................
@property (assign) int ImageCropX;// 편집용 crop 좌표 .................................................
@property (assign) int ImageCropY;// 편집용 crop 좌표 .................................................
@property (assign) int ImageCropW;// 편집용 crop 좌표 .................................................
@property (assign) int ImageCropH;// 편집용 crop 좌표 .................................................

@property (assign) BOOL NotMove;// 현재 사용안함
@property (assign) BOOL NotDelete;// 현재 사용안함
@property (assign) BOOL NotEdit;// 현재 사용안함
@property (assign) BOOL Zorderlock;// 현재 사용안함
@property (assign) BOOL Require;// 현재 사용안함
@property (strong, nonatomic) NSString *ImageDescription;// 현재 사용안함
@property (strong, nonatomic) NSString *Grouping;// 현재 사용안함
@property (strong, nonatomic) NSString *Gid;// 텍스트영역의 경우 책등은 spine 으로 셋팅됨 ...................
@property (strong, nonatomic) NSString *Macro;// 현재 사용안함
@property (strong, nonatomic) NSString *Halign;// 텍스트 영역의 정렬 left, center, right ...............
@property (strong, nonatomic) NSString *VAlign;// 현재 사용안함
@property (assign) BOOL Writevertical;// 현재 사용안함
@property (assign) BOOL Movelock;// 현재 사용안함
@property (assign) BOOL Removelock;// 현재 사용안함
@property (assign) BOOL Resizelock;// 현재 사용안함
@property (assign) float LineGab;// 현재 사용안함
@property (assign) BOOL TextVisible;// 현재 사용안함
@property (strong, nonatomic) NSString *TextFontname;// 폰트이름 .....................................
@property (strong, nonatomic) NSString *TextFontUrl;// 폰트경로 .....................................
@property (assign) int TextFontsize;// 폰트크기 ......................................................
@property (assign) int TextFontcolor;// 폰트색상 .....................................................
@property (assign) BOOL TextBold; // 현재 사용안함
@property (assign) BOOL TextItalic;// 현재 사용안함
@property (strong, nonatomic) NSString *TextDescription;// 글 편집 내용 ..............................
@property (assign) int EditImageMaxSize; // 편집용 이미지의 최대 크기 pixel 수 (장축 기준) .................

@property (strong, nonatomic) UIColor *text_color;
@property (assign) BOOL is_lowres;

@property (strong, nonatomic) UIImage *edit_image;
@property (strong, nonatomic) NSString *str_positionSide;



// 신규 달력 포맷
@property (strong, nonatomic) NSString* Frameinfo;
@property (assign) int Type;
@property (strong, nonatomic) NSString* Align;
@property (strong, nonatomic) NSString* Fontname;
@property (assign) int Fontsize;
@property (strong, nonatomic) NSString* Fontcolor;
@property (strong, nonatomic) NSString* Holidaycolor;
@property (strong, nonatomic) NSString* Fonturl;
@property (strong, nonatomic) NSString* Calid;
@property (strong, nonatomic) NSString* Anniversary;


#pragma mark Layer Function

- (Layer *)copy;
- (NSData *)saveData;
- (void)loadData:(NSData *)data From:(int *)offset;

@end

// <pageinfo>
#pragma mark - Page
@interface Page : NSObject

// ctg format
@property (assign) BOOL IsCover; // 커버일 경우 true
@property (assign) BOOL IsPage; // 일반 페이지 일 경우 true
@property (assign) BOOL IsProlog; // 프롤로그 일 경우 true
@property (assign) BOOL IsEpilog; // 에필로그 일 경우 true , 현재는 셋팅값없음
@property (assign) BOOL IsProject; // 사용안함
@property (assign) BOOL IsXmlLoaded; // 사용안함
@property (assign) int PageWidth;  // 코디 호출시 셋팅한 page width
@property (assign) int PageHeight; // 코디 호출시 셋팅한 page height
@property (strong, nonatomic) NSString *PageFile;// 코디 호출시 셋팅한 page 배경 파일
@property (assign) int PageColorA; // 배경의 Alpha 색상
@property (assign) int PageColorR; // 배경의 Red 색상
@property (assign) int PageColorG; // 배경의 Green 색상
@property (assign) int PageColorB; // 배경의 Blue 색상

//photobook v2 only
@property (assign) CGRect cover_backrect;
@property (assign) CGRect cover_middlerect;
@property (assign) CGRect cover_frontrect;
@property (assign) CGRect page_leftrect;
@property (assign) CGRect page_rightrect;
@property (assign) int PageLeftWidth;  // 코디 호출시 셋팅한 page width
@property (assign) int PageMiddleWidth;  // 코디 호출시 셋팅한 page width
@property (assign) int PageRightWidth;  // 코디 호출시 셋팅한 page width
@property (strong, nonatomic) NSString *pageLayoutType;// xml상의 page layouttype
@property (strong, nonatomic) NSString *PageMiddleFile;// xml상의 covermiddle skinfilename
@property (strong, nonatomic) NSString *PageRightFile;// xml상의 page right skinfilename
@property (assign) int PageCenterColor; // Center 배경의 rgba 색상
@property (assign) int PageRightColor; // Right 배경의 rgba 색상

// calendar only
@property (strong, nonatomic) NSString *CalendarCommonLayoutType;
@property (assign) int CalendarYear;
@property (assign) int CalendarMonth;
@property (strong, nonatomic) NSString *Datefile;

// inner data
@property (assign) int idx;
@property (strong, nonatomic) NSMutableArray *layers;

#pragma mark Page Function

- (Page *)copy;
- (int)getImageLayerCount;
- (Layer *)point2Layer:(CGPoint)point;
- (Layer *)point2LayerViewPoint:(CGPoint)viewPoint scaleFactor:(CGFloat)scale_factor;

- (NSData *)saveData;
- (void)loadData:(NSData *)data From:(int *)offset;

@end

//
#pragma mark - PhotobookDelegate
@protocol PhotobookDelegate <NSObject>
@optional
- (void)photobookProcess:(int)count TotalCount:(int)total_count;
- (void)photobookError;
@end


#pragma mark - Photobook
@interface Photobook : NSObject <NSXMLParserDelegate>

// ctg format
@property (strong, nonatomic) NSString *BasketName; // 보관함 이름 - 최초 생성된 년월일시분초로 기록.
@property (strong, nonatomic) NSString *ProductId; // 주문서내 생산코드 - 년월일12자리 + 랜덤3자리 + 제작코드(6자리), ex)151005133150-992300201, 저장/업로드마다 리셋됨
@property (strong, nonatomic) NSString *ProductCode; // 상품 코드 ex -> 300201
@property (strong, nonatomic) NSString *ProductOption1; // 상품선택시 받은값 ex -> 8x8_mobile
@property (strong, nonatomic) NSString *ProductOption2; // 상품의 최초 시작 페이지 수  ex) 21
@property (strong, nonatomic) NSString *ExistCover; // 사용안함 ("Y^50026835546^N“ - 가운데값은 session id 값)
@property (strong, nonatomic) NSString *DefaultCover; // 사용안함 (따라하기 정보)
@property (strong, nonatomic) NSString *ThemeName; // 선택한 테마  depth1 ex -> simple
@property (strong, nonatomic) NSString *DefaultStyle; // 선택한 테마  depth2 ex -> WhiteMode
@property (strong, nonatomic) NSString *ThemeHangulName; // 선택한 테마 이름
@property (strong, nonatomic) NSString *ProductName; // 사용안함
@property (strong, nonatomic) NSString *ProductType; // 사용안함 //new photobook use
@property (strong, nonatomic) NSString *ProductTypeXML; // new photobook use
@property (strong, nonatomic) NSString *ProductSize; // 8x8 선택한 포토북 사이즈
@property (assign) int ProductPrice; // 가격
@property (assign) int DefaultProductPrice; // 최초 포토북 시작 가격
@property (assign) int PricePerPage; // 페이지당 가격
@property (assign) int MinPage; // 상품선택시 받은 최소페이지 수 ex -> 21
@property (assign) int MaxPage; // 상품선택시 받은 최대 페이지 수 ex -> 21
@property (strong, nonatomic) NSString *CallStyles; // 사용안함
@property (strong, nonatomic) NSString *Page_PoolLayout; // 사용안함
@property (strong, nonatomic) NSString *Page_PoolSkin;// 사용안함
@property (strong, nonatomic) NSString *Cover_PoolLayout;// 사용안함
@property (strong, nonatomic) NSString *Cover_PoolSkin;// 사용안함
@property (strong, nonatomic) NSString *AddParams;// 사용안함
@property (strong, nonatomic) NSString *ScodixParams;// 사용안함
@property (assign) BOOL Edited;// 보관함에서 편집완료 편집중 상태
@property (assign) int TotalPageCount;// 현재 페이지 수 (커버 제외)

@property (strong, nonatomic) NSString *Size;
@property (strong, nonatomic) NSString *Color;

@property (strong, nonatomic) NSString *AddVal1;
@property (strong, nonatomic) NSString *AddVal2;
@property (strong, nonatomic) NSString *AddVal3;
@property (strong, nonatomic) NSString *AddVal4;
@property (strong, nonatomic) NSString *AddVal5;
@property (strong, nonatomic) NSString *AddVal6;
@property (strong, nonatomic) NSString *AddVal7;
@property (strong, nonatomic) NSString *AddVal8;
@property (strong, nonatomic) NSString *AddVal9;
@property (strong, nonatomic) NSString *AddVal10;
@property (strong, nonatomic) NSString *AddVal11;
@property (strong, nonatomic) NSString *AddVal12;
@property (strong, nonatomic) NSString *AddVal13;
@property (strong, nonatomic) NSString *AddVal14;
@property (strong, nonatomic) NSString *AddVal15;

@property (strong, nonatomic) NSString *tmpAddVal6;
@property (strong, nonatomic) NSString *tmpAddVal10;
@property (strong, nonatomic) NSString *tmpAddVal11;
@property (strong, nonatomic) NSString *tmpAddVal12;
@property (strong, nonatomic) NSString *tmpAddVal13;
@property (strong, nonatomic) NSString *tmpAddVal14;

@property (assign) int realPageMarginX;
@property (assign) int realPageWidth;
@property (assign) int realPageHeight;
@property (assign) float pageViewWidth;
@property (assign) float pageViewHeight;
@property (assign) BOOL useTitleHint;

// inner data
@property (assign) int product_type; // photobook or calendar (ProductCode에 기반한 정보)
@property (assign) CGRect page_rect;
@property (assign) CGRect working_rect;
@property (assign) int minpictures;  // 현재는 캘린더만 사용함.
@property (assign) int start_year;   // calendar only
@property (assign) int start_month;  // calendar only
@property (assign) int monthCount;  // calendar only
@property (assign) BOOL isDouble;  // calendar only
@property (assign) BOOL showSpring;  // calendar only
@property (assign) int neededPageCount;  // calendar only

@property (strong, nonatomic) NSString *base_folder;
@property (strong, nonatomic) NSMutableArray *thumbs;
@property (strong, nonatomic) id<PhotobookDelegate> delegate;

@property (assign) CGFloat scale_factor;
@property (assign) CGFloat edit_scale;
@property (assign) CGFloat widthScale;
@property (assign) CGFloat heightScale;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *skin_url;
@property (strong, nonatomic) UIImage *page_bkimage_photobook;
@property (strong, nonatomic) UIImage *page_bkimage_calendar;
@property (strong, nonatomic) UIImage *page_bkimage_calendar2;
@property (strong, nonatomic) UIImage *page_pattern_calendar;
@property (strong, nonatomic) UIImage *page_bkimage_polaroid;
@property (strong, nonatomic) UIImage *warning_image;
@property (strong, nonatomic) UIImage *cover_grad_image;
@property (strong, nonatomic) UIImage *inner_grad_image;
@property (strong, nonatomic) UIImage *cover_banner_image;
@property (strong, nonatomic) UIImage *blank_banner_image;
@property (strong, nonatomic) UIImage *blank_rvs_banner_image; // SJYANG : 프리미엄북 에필로그 역(reverse) blank 이미지
@property (strong, nonatomic) UIImage *thumb_captured_image;
@property (strong, nonatomic) UIImage *thumb_captured_image_1;
@property (strong, nonatomic) UIImage *thumb_captured_image_2;
@property (strong, nonatomic) UIImage *thumb_captured_image_3;
@property (strong, nonatomic) UIImage *thumb_captured_image_4;

// 신규 달력 포맷
@property (assign) CGFloat FONT_SIZE_RATIO;
@property (strong, nonatomic) NSMutableArray *memorialDays;
@property (strong, nonatomic) NSMutableDictionary *holidays;
@property (strong, nonatomic) NSMutableDictionary *memorials;
@property (strong, nonatomic) NSMutableDictionary *fonts;
@property (strong, nonatomic) NSMutableArray *fontUrls;


//
@property (strong, nonatomic) NSMutableArray *pages;

//photobookV2용 depth1,depth2 key
@property (strong, nonatomic) NSString *depth1_key;
@property (strong, nonatomic) NSString *depth2_key;


#pragma mark Photobook Function

- (void)clear;
- (void)dumpLog;
- (int)productType:(NSString *)productCode;

- (void)initPhotobookInfo:(BookInfo *)bookinfo ThemeInfo:(Theme *)theme;
- (BOOL)initPhotobookPages;
- (BOOL)initPhotobookPagesLocal;
- (void)fillPhotobookPages;
- (void)loadPhotobookPages;

- (BOOL)initPhotobookV2CodyPages:(int)type paramDepth1Key:(NSString*)depth1 paramDepth2Key:(NSString*)depth2 paramProductOption1:(NSString*)productoption1;

- (void)setBookTitle:(NSString *)title;
- (InstaPhoto *)pickInstaPhoto:(NSInteger)index;
- (Photo *)pickPhoto:(NSInteger)index;
- (BOOL)addPhotoFromInstagram:(InstaPhoto *)photo Layer:(Layer *)layer PickIndex:(int)pick_index;
- (BOOL)addPhoto:(Photo *)photo Layer:(Layer *)layer PickIndex:(int)pick_index;
- (void)deletePhoto:(Layer *)layer;

- (int)getImageLayerCount;
- (BOOL)validateDuplicate:(NSString *)filename PageIdx:(int)page_idx LayerIdx:(int)layer_idx;
- (BOOL)checkDuplicate;

- (Layer *)getLayer:(NSInteger)index FromPoint:(CGPoint)point;
- (Layer *)getLayerOfPaperSlogan:(NSInteger)index FromPoint:(CGPoint)point;
- (Layer *)getLayerOfPolaroidTextArea:(NSInteger)index FromPoint:(CGPoint)point;
- (BOOL)changeLayout:(NSInteger)index From:(Layout *)layout;
- (BOOL)changeLayout:(NSInteger)index From:(Layout *)selected_layout SelectLR:(NSString*)selectLRstr;
- (BOOL)changeBackground:(NSInteger)index From:(Background *)background;
- (BOOL)changeBackground:(NSInteger)index From:(Background *)background SelectLR:(NSString*)selectLRstr;

- (BOOL)canPageAdd;
- (BOOL)insertPage:(NSInteger)index FromDefaultPage:(Page *)default_page;
- (BOOL)deletePage:(NSInteger)index;
- (BOOL)composePage:(NSInteger)index ParentView:(UIImageView *)parentview IncludeBg:(BOOL)include_bg IsEdit:(BOOL)is_edit;
- (BOOL)composePaperSloganPage:(NSInteger)index ParentView:(UIImageView *)parentview IncludeBg:(BOOL)include_bg IsEdit:(BOOL)is_edit IsThumbnail:(BOOL)is_thumbnail;

- (void)makeThumb:(int)index ToFile1:(NSString *)file1 ToFile2:(NSString *)file2 IncludeBg:(BOOL)include_bg;
- (void)makeThumb:(int)index ToFile:(NSString *)file IncludeBg:(BOOL)include_bg;
- (void)makePureThumb:(int)index ToFile:(NSString *)file;

- (BOOL)isUV;
- (int)getTotalPageCount; // 커버제외(-2) 프롤로그제외(-1)
- (int)getTotalPrice;

- (BOOL)isEditComplete;
- (BOOL)isEditCompleteWithPageCount:(int) pageCount;
- (NSData *)saveData;
- (void)saveFile;
- (void)saveFileWithPageCount:(int) pageCount;
- (BOOL)loadData:(NSData *)data IsHeaderOnly:(BOOL)is_headerOnly;

- (NSString *)migrationBasketName:(NSString *)basketname FromProductID:(NSString *)product_id;
- (void)clearAddVal;

- (BOOL)isValid;

- (UIImage *)imageWithBorderAndRoundCornersWithImage:(UIImage *)image lineWidth:(CGFloat)lineWidth cornerRadius:(CGFloat)cornerRadius;
- (UIImage *)imageWithRoundedCornersSize:(CGFloat)cornerRadius usingImage:(UIImage *)original;

- (UIImage*)outlineMaskBitmap:(UIImage*)myImage withR:(int)dstColorR withG:(int)dstColorG withB:(int)dstColorB withA:(int)dstColorA;
- (UIImage*)maskImage:(UIImage*)myImage;

#pragma mark - PhotoContainer
- (BOOL)addPhotoNew:(PhotoItem *)photo Layer:(Layer *)layer PickIndex:(int)pick_index;
//- (BOOL)addPhoto:(SocialItem *)photo Layer:(Layer *)layer PickIndex:(int)pick_index;

#pragma mark - PhotobookV2
- (UIColor *)colorWithRGBAInteger:(NSUInteger)RGBAInteger;
- (NSUInteger)rgbaIntegerWithColor:(NSUInteger)red green:(NSUInteger)green blue:(NSUInteger)blue alpha:(NSUInteger)alpha;

@end
