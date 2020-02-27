//
//  Define.h
//  PHOTOMON
//
//  Created by photoMac on 2015. 11. 26..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#ifndef Define_h
#define Define_h

#define PHOTOMON_TESTMODE

@import Photos;
#define PHOTO_KIT

#define GUIDE_PHOTO_SELECT      @"GuidePhotoSelect"
#define GUIDE_PHOTOBOOK_EDIT    @"GuidePhotobookEdit"
#define GUIDE_CALENDAR_EDIT     @"GuideCalendarEdit"
#define GUIDE_POLAROID_EDIT     @"GuidePolaroidEdit"
#define GUIDE_FRAME_EDIT        @"GuideFrameEdit"
#define GUIDE_MUG_EDIT          @"GuideMugEdit"
#define GUIDE_PHONECASE_EDIT    @"GuidePhonecaseEdit"
#define GUIDE_IDPHOTOS_CAMERA   @"GuideIDPhotosCamera"
#define GUIDE_BABY_EDIT         @"GuideBabyEdit"
#define GUIDE_CARD_EDIT         @"GuideCardEdit"
#define GUIDE_SINGLE_OPTION     @"GuideSingleOption"

#define PRODUCT_UNKNOWN   -1
#define PRODUCT_PHOTOPRINT 0
#define PRODUCT_PHOTOBOOK  1
#define PRODUCT_CALENDAR   2
#define PRODUCT_POLAROID   3
#define PRODUCT_FRAME      4
#define PRODUCT_MUG        5
#define PRODUCT_POSTCARD   6
#define PRODUCT_BABY       7
#define PRODUCT_PHONECASE  8
#define PRODUCT_CARD       9
#define PRODUCT_NAMESTICKER 10
#define PRODUCT_DESIGNPHOTO 11
#define PRODUCT_SINGLECARD  12
#define PRODUCT_MAGNET      13
#define PRODUCT_FANBOOK     14
#define PRODUCT_POSTER      15
#define PRODUCT_PAPERSLOGAN 16
#define PRODUCT_TRANSPARENTCARD 17
#define PRODUCT_DIVISIONSTICKER 18
#define PRODUCT_MONTHLYBABY 19
#define PRODUCT_IDPHOTO		20
#define PRODUCT_DDUKDDAK	21

#define CALENDAR_MONTH_MAX 14
#define CALENDAR_PAGE_MAX (CALENDAR_MONTH_MAX*2 + 2) // 14개월*2 + cover + epilog

#define PHOTO_POSITION_LOCAL 0
#define PHOTO_POSITION_INSTAGRAM 1
#define PHOTO_POSITION_FACEBOOK 2
#define PHOTO_POSITION_GOOGLEPHOTO 3
#define PHOTO_POSITION_KAKAOSTORY 4
#define PHOTO_POSITION_SMARTBOX 5

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// URL DEFINE

// 메인화면
#define URL_MAIN_BANNER  @"https://www.photomon.com/wapp/page/mainBanner_iOS.asp"
#define URL_MAIN_BUTTON01 @"http://m.photomon.com/mProduct/thumb/main_photobook_ios.jpg"
#define URL_MAIN_BUTTON02 @"http://m.photomon.com/mProduct/thumb/main_photoprint_ios.jpg"
#define URL_MAIN_BUTTON03 @"http://m.photomon.com/mProduct/thumb/main_calendar_ios.jpg"
#define URL_MAIN_BUTTON04 @"http://m.photomon.com/mProduct/thumb/main_frame_ios.jpg"
#define URL_MAIN_BUTTON05 @"http://m.photomon.com/mProduct/thumb/main_polaroid_ios.jpg"
#define URL_MAIN_BUTTON06 @"http://m.photomon.com/mProduct/thumb/main_gift_ios.jpg"
#define URL_MAIN_BUTTON07 @"http://m.photomon.com/mProduct/thumb/main_photoprint_ios.jpg"
#define URL_MAIN_BUTTON08 @"http://m.photomon.com/mProduct/thumb/main_baby_ios.jpg"
#define URL_MAIN_BUTTON09 @"http://m.photomon.com/mProduct/thumb/main_card_ios.jpg"
#define URL_MAIN_BUTTON10 @"http://m.photomon.com/mProduct/thumb/main_fancy_ios.jpg"
#define URL_MAIN_BUTTON11 @"http://m.photomon.com/mProduct/thumb/main_goods_760x446.jpg"

// 기본정보 (버전,배송문구,이벤트)
#define URL_VERSIONINFO  @"http://m.photomon.com/version_event.asp"
#define URL_RECV_INFO @"http://www.photomon.com/admin/RecvInfo_utf8_db.asp"
#define URL_EVENT @"https://www.photomon.com/wapp/event/event_page.asp"

// 사진인화
#define URL_PRINT_UPLOADPATH @"https://www.photomon.com/xml/urlprint.asp?urltype=UPLOAD_HOST"
#define URL_PRINT_UPLOADNAME @"https://www.photomon.com/xml/urlprint.asp?urltype=UPLOAD_HOST_IMAGE"
#define URL_PRINT_SIZEINFO @"http://www.photomon.com/include/appinfo/sizeinfo.asp?mode=mIOS"
#define URL_PRINT_ORDERNUM @"https://www.photomon.com/xml/urlprint.asp?urltype=orderno"

// 포토북,캘린더,폴라로이드,기프트
#define URL_PRODUCT_DETAIL @"https://www.photomon.com/wapp/page/page.asp?key=&intnum=%@&seq=%@"
#define URL_PRODUCT_STICKER_PATH @"http://m.photomon.com/mproduct/sticker/edit/"
#define URL_PRODUCT_PAGESKIN_PATH @"http://m.photomon.com/mProduct/skin/edit/"
#define URL_PRODUCT_THUMB_PATH @"http://m.photomon.com/mproduct/skin/thumb/"
#define URL_PRODUCT_UPLOAD_SERVER @"http://www.photomon.com/admin/AppService/TplUploadInfo_app.asp?productcode=%@"
#define URL_PRODUCT_UPLOAD_PATH @"http://%@.photomon.com/upload/upload_flex.asp"
#define URL_PRODUCT_UPLOAD_CHECK @"http://%@.photomon.com/upload/upload_check.asp?product_id=%@"
#define URL_IDPHOTOS_PRODUCT @"http://m.photomon.com/mProduct/mobile_productinfo.asp"
#define URL_IDPHOTOS_THUMB_PATH @"http://m.photomon.com/mProduct/thumb/"

// 신규 달력 포맷
#define URL_CALENDAR_PAGESKIN_PATH @"http://tpl.photomon.com/Product/cal25/skins/"
#define URL_CALENDAR_THUMB_PATH @"http://tpl.photomon.com/Product/cal25/thumb/"
#define URL_CALENDAR_STICKER_PATH @"http://%@.photomon.com/Product/clipart20120430/edit/"
#define URL_CALENDAR_MEMORIAL_DAYS @"http://tpl.photomon.com/product/html5/calendar/memorial_days.asp"

#define URL_SINGLESTORE_SKIN_PATH @"http://%@.photomon.com/Product/singlestore/skins/"

//photobookV2 분산서버 path
#define URL_PHOTOBOOK_V2_SKIN_PATH @"http://%@.photomon.com/Product/photobook/skin/edit/"
#define URL_PHOTOBOOK_V2_CLIPART_PATH @"http://%@.photomon.com/Product/clipart20120430/edit/"

// 포토북 옵션 팝업
#define URL_PRODUCT_OPTION_POPUP @"https://www.photomon.com/wapp/page/popup.asp?osinfo=ios&intnum=%@&seq=%@&key=%@&uniquekey=%@" // SJYANG : 프리미엄북 옵션(형압) 안내 팝업 페이지

#ifdef PHOTOMON_TESTMODE

    #define URL_MAIN           @"http://m.photomon.com/mJson/test_mobile_home_ios.json"
//	#define URL_VERSIONINFO_V2 @"http://m.photomon.com/test_version.asp"
    #define URL_VERSIONINFO_V2 @"https://www.photomon.com/wapp/test_version.asp"
    #define URL_PHOTOBOOK_PRODUCT @"http://m.photomon.com/mproduct/mainxml/test_mobile_photobook_product_ios.xml"
    #define URL_PHOTOBOOK_PRODUCT_SUB @"http://m.photomon.com/mproduct/mainxml/test_mobile_photobook_product_sub.xml"
    #define URL_PHOTOBOOK_THEME @"http://m.photomon.com/mproduct/mainxml/test_mobile_photobook_theme.xml"
    //#define URL_PHOTOBOOK_THEME @"http://m.photomon.com/mProduct/mainxml/test_mobile_newPhotobook_Theme.asp?depth1=%@&depth2=%@&producttype=designphotobook"
    #define URL_PHOTOBOOK_EDIT @"http://m.photomon.com/mProduct/mainxml/test_mobile_photobook.xml"
    #define URL_PHOTOBOOK_LAYOUT @"http://m.photomon.com/mproduct/mainxml/test_mobile_photobook_layout.xml"
    #define URL_PHOTOBOOK_BACKGROUND @"http://m.photomon.com/mproduct/mainxml/test_mobile_photobook_background.xml"
    #define URL_CALENDAR_PRODUCT @"http://m.photomon.com/mproduct/mainxml/test_mobile_calendar_product.xml"
    #define URL_CALENDAR_THEME @"http://m.photomon.com/mproduct/mainxml/test_mobile_calendar_theme.xml"
    #define URL_CALENDAR_EDIT @"http://m.photomon.com/mProduct/mainxml/test_mobile_calendar.xml"
    #define URL_CALENDAR_LAYOUT @"http://m.photomon.com/mproduct/mainxml/test_mobile_calendar_layout.xml"
    #define URL_POLAROID_THEME @"http://m.photomon.com/mproduct/mainxml/test_mobile_polaroidset_theme.xml"
    #define URL_POLAROID_EDIT @"http://m.photomon.com/mProduct/mainxml/test_mobile_polaroidset.xml"
    #define URL_POLAROID_LAYOUT @"http://m.photomon.com/mproduct/mainxml/test_mobile_polaroidset_layout.xml"
    #define URL_FRAME_THEME @"http://m.photomon.com/mproduct/mainxml/test_mobile_frame_theme.xml"
    #define URL_GIFT_PRODUCT @"http://m.photomon.com/mproduct/mainxml/test_mobile_gift_product.xml"
    #define URL_GIFT_THEME @"http://m.photomon.com/mproduct/mainxml/test_mobile_gift_theme.xml"
    #define URL_GIFT_LAYOUT @"http://m.photomon.com/mproduct/mainxml/test_mobile_gift_layout.xml"
    #define URL_GIFT_EDIT @"http://m.photomon.com/mProduct/mainxml/test_mobile_gift.xml"
    #define URL_BABY_PRODUCT @"http://m.photomon.com/mproduct/mainxml/test_mobile_baby_product.xml"
    #define URL_BABY_THEME @"http://m.photomon.com/mproduct/mainxml/test_mobile_baby_theme.xml"
    #define URL_PHOTO_PRODUCT @"http://m.photomon.com/mproduct/mainxml/test_mobile_photo_product.xml"
    #define URL_CARD_PRODUCT @"http://m.photomon.com/mproduct/mainxml/test_mobile_card_product.xml"
    #define URL_CARD_THEME @"http://m.photomon.com/mproduct/mainxml/test_mobile_card_theme.xml"
    #define URL_CARD_EDIT @"http://m.photomon.com/mProduct/mainxml/test_mobile_card.xml"
    #define URL_FANCY_PRODUCT @"http://m.photomon.com/mproduct/mainxml/test_mobile_fancy_product.xml"
    #define URL_FANCY_THEME @"http://m.photomon.com/mproduct/mainxml/test_mobile_fancy_theme.xml"
    #define URL_DESIGNPHOTO_THEME @"http://m.photomon.com/mproduct/mainxml/test_mobile_designphoto_theme.xml"
    #define URL_DESIGNPHOTO_EDIT @"http://m.photomon.com/mproduct/mainxml/test_mobile_designphoto.xml"
    #define URL_DESIGNPHOTO_LAYOUT @"http://m.photomon.com/mproduct/mainxml/test_mobile_designphoto_layout.xml"
    #define URL_SINGLECARD_LAYOUT @"http://m.photomon.com/mproduct/mainxml/test_mobile_designphoto_layout_photocard.xml"
    #define URL_GOODS_PRODUCT @"http://m.photomon.com/mproduct/mainxml/test_mobile_goods_product.xml"
    #define URL_POSTER_THEME @"http://m.photomon.com/mproduct/mainxml/test_mobile_poster_theme.xml"
    #define URL_POSTER_EDIT @"http://m.photomon.com/mproduct/mainxml/test_mobile_poster.xml"
    #define URL_POSTER_LAYOUT @"http://m.photomon.com/mproduct/mainxml/test_mobile_poster_layout.xml"
    #define URL_FANCY_EDIT @"http://m.photomon.com/mproduct/mainxml/test_mobile_fancy.xml"
    #define URL_FANCY_LAYOUT @"http://m.photomon.com/mproduct/mainxml/test_mobile_fancy_layout.xml"
    #define URL_TRANSPARENTCARD_LAYOUT @"http://m.photomon.com/mProduct/mainxml/test_mobile_designphoto_layout.xml"
    #define URL_PHOTOBOOK_V2_STYLE @"http://m.photomon.com/mProduct/mainxml/test_mobile_photobook_style.asp?producttype=designphotobook"
    #define URL_PHOTOBOOK_V2_THEME @"http://m.photomon.com/mProduct/mainxml/test_mobile_newPhotobook_Theme.asp?depth1=%@&depth2=%@&producttype=designphotobook"
    #define URL_PHOTOBOOK_V2_CODY @"http://m.photomon.com/mProduct/mainxml/test_mobile_newPhotobook_cody.asp?depth1=%@&depth2=%@&productOption1=%@"
    #define URL_PHOTOBOOK_V2_BG @"http://m.photomon.com/mProduct/mainxml/test_mobile_newPhotobook_background.asp?depth1=%@&depth2=%@&pro ducttype=%@&backgroundtype=%@&productoption1=%@"
    #define URL_PHOTOBOOK_V2_LAYOUT @"http://m.photomon.com/mProduct/mainxml/test_mobile_newPhotobook_layout.asp?productoption1=%@&layouttype=%@"

#else
    #define URL_MAIN           @"http://m.photomon.com/mJson/mobile_home_ios.json"

//	#define URL_VERSIONINFO_V2 @"http://m.photomon.com/version.asp"
    #define URL_VERSIONINFO_V2 @"https://www.photomon.com/wapp/version.asp"
    #define URL_PHOTOBOOK_PRODUCT @"http://m.photomon.com/mproduct/mainxml/mobile_photobook_product_ios.xml"
    #define URL_PHOTOBOOK_PRODUCT_SUB @"http://m.photomon.com/mproduct/mainxml/mobile_photobook_product_sub_ios.xml"
    #define URL_PHOTOBOOK_THEME @"http://m.photomon.com/mproduct/mainxml/mobile_photobook_theme_ios.xml"
    //#define URL_PHOTOBOOK_THEME @"http://m.photomon.com/mProduct/mainxml/mobile_newPhotobook_Theme.asp?depth1=%@&depth2=%@&producttype=designphotobook"
    #define URL_PHOTOBOOK_EDIT @"http://m.photomon.com/mProduct/mainxml/mobile_photobook_ios.xml"
    #define URL_PHOTOBOOK_LAYOUT @"http://m.photomon.com/mproduct/mainxml/mobile_photobook_layout_ios.xml"
    #define URL_PHOTOBOOK_BACKGROUND @"http://m.photomon.com/mproduct/mainxml/mobile_photobook_background_ios.xml"
    #define URL_CALENDAR_PRODUCT @"http://m.photomon.com/mproduct/mainxml/mobile_calendar_product_ios.xml"
    #define URL_CALENDAR_THEME @"http://m.photomon.com/mproduct/mainxml/mobile_calendar_theme_ios.xml"
    #define URL_CALENDAR_EDIT @"http://m.photomon.com/mProduct/mainxml/mobile_calendar_ios.xml"
    #define URL_CALENDAR_LAYOUT @"http://m.photomon.com/mproduct/mainxml/mobile_calendar_layout_ios.xml"
    //#define URL_POLAROID_LAYOUT @"http://m.photomon.com/mproduct/mainxml/mobile_polaroidset_layout.xml" // 기존
    #define URL_POLAROID_LAYOUT @"http://m.photomon.com/mproduct/mainxml/mobile_polaroidset_layout_ios.xml" // 규약대로 맞춤
    #define URL_POLAROID_THEME @"http://m.photomon.com/mproduct/mainxml/mobile_polaroidset_theme_ios.xml"
    #define URL_POLAROID_EDIT @"http://m.photomon.com/mProduct/mainxml/mobile_polaroidset_ios.xml"
    #define URL_FRAME_THEME @"http://m.photomon.com/mproduct/mainxml/mobile_frame_theme_ios.xml"
    #define URL_GIFT_PRODUCT @"http://m.photomon.com/mproduct/mainxml/mobile_gift_product_ios.xml"
    #define URL_GIFT_THEME @"http://m.photomon.com/mproduct/mainxml/mobile_gift_theme_ios.xml"
    #define URL_GIFT_LAYOUT @"http://m.photomon.com/mproduct/mainxml/mobile_gift_layout_ios.xml"
    #define URL_GIFT_EDIT @"http://m.photomon.com/mProduct/mainxml/mobile_gift_ios.xml"
    #define URL_BABY_PRODUCT @"http://m.photomon.com/mproduct/mainxml/mobile_baby_product_ios.xml"
    #define URL_BABY_THEME @"http://m.photomon.com/mproduct/mainxml/mobile_baby_theme_ios.xml"
    #define URL_PHOTO_PRODUCT @"http://m.photomon.com/mproduct/mainxml/mobile_photo_product_ios.xml"
    #define URL_CARD_PRODUCT @"http://m.photomon.com/mproduct/mainxml/mobile_card_product_ios.xml"
    #define URL_CARD_THEME @"http://m.photomon.com/mproduct/mainxml/mobile_card_theme_ios.xml"
    #define URL_CARD_EDIT @"http://m.photomon.com/mProduct/mainxml/mobile_card_ios.xml"
    #define URL_FANCY_PRODUCT @"http://m.photomon.com/mproduct/mainxml/mobile_fancy_product_ios.xml"
    #define URL_FANCY_THEME @"http://m.photomon.com/mproduct/mainxml/mobile_fancy_theme_ios.xml"
    #define URL_DESIGNPHOTO_THEME @"http://m.photomon.com/mproduct/mainxml/mobile_designphoto_theme_ios.xml"
    #define URL_DESIGNPHOTO_EDIT @"http://m.photomon.com/mproduct/mainxml/mobile_designphoto_ios.xml"
    #define URL_DESIGNPHOTO_LAYOUT @"http://m.photomon.com/mproduct/mainxml/mobile_designphoto_layout_ios.xml"
    #define URL_SINGLECARD_LAYOUT @"http://m.photomon.com/mproduct/mainxml/mobile_designphoto_layout_photocard_ios.xml"
    #define URL_GOODS_PRODUCT @"http://m.photomon.com/mproduct/mainxml/mobile_goods_product_ios.xml"
    #define URL_POSTER_THEME @"http://m.photomon.com/mproduct/mainxml/mobile_poster_theme_ios.xml"
    #define URL_POSTER_EDIT @"http://m.photomon.com/mproduct/mainxml/mobile_poster_ios.xml"
    #define URL_POSTER_LAYOUT @"http://m.photomon.com/mproduct/mainxml/mobile_poster_layout_ios.xml"
    #define URL_FANCY_EDIT @"http://m.photomon.com/mproduct/mainxml/mobile_fancy_ios.xml"
    #define URL_FANCY_LAYOUT @"http://m.photomon.com/mproduct/mainxml/mobile_fancy_layout_ios.xml"
    #define URL_TRANSPARENTCARD_LAYOUT @"http://m.photomon.com/mProduct/mainxml/mobile_designphoto_layout_ios.xml"
    #define URL_PHOTOBOOK_V2_STYLE @"http://m.photomon.com/mProduct/mainxml/mobile_photobook_style.asp?producttype=designphotobook"
    #define URL_PHOTOBOOK_V2_THEME @"http://m.photomon.com/mProduct/mainxml/mobile_newPhotobook_Theme.asp?depth1=%@&depth2=%@&producttype=designphotobook"
    #define URL_PHOTOBOOK_V2_CODY @"http://m.photomon.com/mProduct/mainxml/mobile_newPhotobook_cody.asp?depth1=%@&depth2=%@&productOption1=%@"
    #define URL_PHOTOBOOK_V2_BG @"http://m.photomon.com/mProduct/mainxml/mobile_newPhotobook_background.asp?depth1=%@&depth2=%@&pro ducttype=designphotobook&backgroundtype=%@&productoption1=%@"
    #define URL_PHOTOBOOK_V2_LAYOUT @"http://m.photomon.com/mProduct/mainxml/mobile_newPhotobook_layout.asp?productoption1=%@&layouttype=%@"
#endif

//월간 포토몬
#define URL_MONTHLY_BABY_MAIN_URL @"http://m.photomon.com/wview/monthly_baby/index.asp?osinfo=ios"
#define URL_MONTHLY_CART_URL @"http://m.photomon.com/wview/monthly_baby/apply_modify_form.asp?osinfo=ios"
#define URL_GET_UPLOAD_SERVER_BY_SVCMODE @"http://www.photomon.com/include/Appinfo/Uploadinfo_Print_html5.asp?svcmode=%@"
#define URL_GET_SUBSCRIPTION_INFO @"http://m.photomon.com/wview/monthly_baby/api/upload_status.asp"
#define URL_MONTHLY_ORDER_COMPLETE @"https://m.photomon.com/wview/monthly_baby/ordercomplete.asp"
#define URL_MONTHLY_ADDPRODUCT_LIST @"http://www.photomon.com/include/Appinfo/AddProduct_html5.asp?editmode=monthlybaby"
#define URL_MONTHLY_ADD_CARD @"http://m.photomon.com/wview/monthly_baby/orderaddcart.asp"
#define URL_MONTHLY_COVER_THUMBNAIL	@"http://tplx.photomon.com"

//뚝딱 서비스
#define URL_DDUKDDAK_PRODUCT @"http://m.photomon.com/wview/ddudak/api/ddudak_info.json"
#define URL_DDUKDDAK_SIAN_LIST @"http://www.photomon.com/wapp/member/sianlist.asp"
#define URL_DDUKDDAK_SIAN_DETAIL @"http://www.photomon.com/membernew/mViewSian.asp?bidx=%@"

// 장바구니
#define URL_CART_SESSION @"https://www.photomon.com/xml/mCart_session.asp?uniquekey=%@"
#define URL_CART_LIST @"https://www.photomon.com/xml/mOrderCart_ios.asp?userid=%@&cart_session=%@&uniquekey=%@"
#define URL_CART_ADD @"https://www.photomon.com/xml/mAddCart_ok.asp?userid=%@&orderno=%@&cart_session=%@&osinfo=ios&uniquekey=%@"
#define URL_CART_ADD_PHOTOBOOK @"http://www.photomon.com/StoryAlbum/TplEditor/add_cart_ok.asp?osinfo=ios&uniquekey=%@&" // calendar도 동일
#define URL_CART_ADD_POLAROID @"https://www.photomon.com/wapp/cart/add_cart_polaroid.asp?osinfo=ios&uniquekey=%@&" // postcard 동일
#define URL_CART_ADD_FRAME @"https://www.photomon.com/wapp/cart/add_cart_frame.asp?osinfo=ios&uniquekey=%@&" // mug 동일
#define URL_CART_ADD_IDPHOTOS @"https://www.photomon.com/xml/mAddCart_ok_identity.asp?osinfo=ios&uniquekey=%@&"
#define URL_CART_ADD_BABY @"https://www.photomon.com/wapp/cart/add_cart_standing.asp?osinfo=ios&uniquekey=%@&"
#define COMMON_URL_CART_ADD_WITH_EDIT  @"https://www.photomon.com/wapp/cart/add_cart_tpl.asp?osinfo=ios&uniquekey=%@&"
#define COMMON_URL_CART_ADD_WITH_EDIT2 @"https://www.photomon.com/wapp/cart/add_cart_store.asp"

#define URL_CART_DELETE @"https://www.photomon.com/xml/mOrderCartdel.asp?cart_idx=%@"
#define URL_CART_PREVIEW_PRINT @"https://www.photomon.com/xml/mOrderCartPrintingPreview.asp?orderno=%@"
#define URL_CART_PREVIEW_BOOK  @"https://www.photomon.com/xml/mOrderCartPrintingPreview.asp?g_class=%@"
#define URL_CART_QUANTITY_PRINT @"https://www.photomon.com/xml/mAddCart_Modify_File.asp?orderno=%@&idx=%@&cnt=%@"
#define URL_CART_QUANTITY_BOOK  @"https://www.photomon.com/xml/mAddCart_Modify_identity.asp?cart_idx=%@&price=%@&pkgcnt=%@"
#define URL_CART_PRICE_PRINT @"https://www.photomon.com/xml/mAddCart_Modify.asp?orderno=%@&price=%@"

#define URL_CHECK_DISCONTINUED_PRODUCT @"http://www.photomon.com/admin/AppService/StoreCheck_utf8.asp?intnum=%@&seq=%@&osinfo=ios&totalpagecount=%d&uniquekey=%@"

// 배송, 결제, 쿠폰
#define URL_DELIVERY_POST @"https://www.photomon.com/xml/mP_OID.asp"
#define URL_DELIVERY_ADDRESS @"https://www.photomon.com/xml/mPostAddr5.asp?postsearch=%@"
#define URL_PAYMENT_CARD @"https://mobile.inicis.com/smart/wcard/"
#define URL_PAYMENT_MOBILE @"https://mobile.inicis.com/smart/mobile/"
#define URL_PAYMENT_VBANK @"http://m.photomon.com/mOrder/orderpay_step2_vbnk.asp"
#define URL_PAYMENT_NEXT @"https://www.photomon.com/mobile/mOrder/P_NEXT_URL.asp"
#define URL_PAYMENT_NOTI @"https://www.photomon.com/mobile/mOrder/P_NOTI_URL.asp"
#define URL_PAYMENT_RETURN @"https://www.photomon.com/mobile/mOrder/orderPay_step3.asp"
#define URL_COUPON_LIST @"https://www.photomon.com/xml/mcoupon.asp?userid=%@&intnum=%@&seq=%@&cartidx=%@&osinfo=ios&uniquekey=%@"
#define URL_COUPON_ADD @"http://m.photomon.com/morder/couponinsert.asp?newcouponno=%@&userid=%@"

// 회원
#define URL_USER_SIGNUP @"https://www.photomon.com/wapp/xml/mjoin_form_ok.asp?username=%@&emailaddr=%@&userpw=%@&cellnum=%@&mailchk=%@&smschk=%@&birth1=%@&birth2=%@&birth3=%@&gender=%@"
#define URL_USER_LOGIN @"https://www.photomon.com/wapp/xml/mlogin.asp?userid=%@&userpw=%@&sns=%@&osinfo=ios&uniquekey=%@&logintype=login"
#define URL_USER_INFO_UPDATE @"https://www.photomon.com/wapp/xml/mlogin.asp?userid=%@&osinfo=ios&logintype=myinfo"
#define URL_USER_SOCIAL_LOGIN @"https://www.photomon.com/wapp/xml/mlogin.asp?userid=%@&sns=%@&logintype=login&osinfo=ios"
#define URL_USER_SOCIAL_LOGIN_WEBVIEW @"https://www.photomon.com/wapp/xml/sns_login.asp?snstype=%@&osinfo=ios"
#define URL_USER_LOGOUT @"https://www.photomon.com/member/mlogout_ok.asp"
#define URL_ID_CHECK @"https://www.photomon.com/xml/mOverlapID.asp?userid=%@"
#define URL_EMAIL_CHECK @"https://www.photomon.com/xml/mOverlapEmail.asp?EmailAddr=%@"
#define URL_ID_FIND @"https://www.photomon.com/wapp/xml/mcheckid.asp?username=%@&emailaddr=%@"
#define URL_PW_FIND @"https://www.photomon.com/wapp/xml/mcheckpass.asp?username=%@&emailaddr=%@&userid=%@"

// 주문조회
#define URL_ORDER_LIST @"https://www.photomon.com/xml/mOrderDeliveryInfo.asp?userid=%@&cart_session=%@&uniquekey=%@"
#define URL_ORDER_VIEW @"https://www.photomon.com/xml/mOrderResult.asp?tuid=%@"
#define URL_ORDER_DETAIL @"https://www.photomon.com/xml/mOrderDeliveryFileInfo.asp?tuid=%@"
#define URL_ORDER_LIST_NOMEMBER @"https://www.photomon.com/wapp/xml/mNoNloginorder.asp?username=%@&EmailAddr=%@"


// 이용문의/목록
#define URL_QNA_LIST @"https://www.photomon.com/xml/mQnaList.asp?userid=%@"
#define URL_QNA_VIEW @"https://www.photomon.com/xml/mQnaListView.asp?board_idx=%@"
#define URL_QNA_WRITE @"https://www.photomon.com/xml/mQnawrite.asp?subject=%@&category=%@&content=%@&userid=%@&username=%@&scrid=%@&osinfo=ios&uniquekey=%@"
#define URL_QNA_DELETE @"https://www.photomon.com/xml/mQnadelete.asp?userid=%@&board_idx=%@"

// 공지사항
#define URL_NOTICE_LIST @"https://www.photomon.com/xml/mNotice.asp"
#define URL_NOTICE_VIEW @"https://www.photomon.com/xml/mNotice_content.asp?idx=%@"

// 카카오톡
#define URL_KAKAO_INSTALL @"https://itunes.apple.com/kr/app/id362057947"

// 구글 Sign In
#define GOOGLE_SIGNIN_CLIENT_ID @"220145448268-3f76mlvp4l6mcg3dae79url420sipvb9.apps.googleusercontent.com"

// 약관
#define URL_PROVISION_LAW @"https://www.photomon.com/wapp/page/page.asp?key=photomon_law"
#define URL_PROVISION_PRIVACY @"https://www.photomon.com/wapp/page/page.asp?key=photomon_privacy"
#define URL_PROVISION_AUTHORITY @"https://www.photomon.com/wapp/page/page.asp?key=app_authority"




#endif /* Define_h */
