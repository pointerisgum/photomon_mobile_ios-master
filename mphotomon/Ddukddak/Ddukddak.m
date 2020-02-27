//
//  Ddukddak.m
//  PHOTOMON
//
//  Created by 곽세욱 on 03/10/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import "Ddukddak.h"
#import "Common.h"
#import "DdukddakLandscapeWebViewController.h"

@implementation DdukddakOptionDetail
@end

@implementation DdukddakOption
@end

@implementation DdukddakLayoutCount
@end

@implementation DdukddakAddCartReturn
@end

#pragma mark - Ddukddak base

@implementation Ddukddak

// thread safe singleton
+ (Ddukddak *)inst {
	static dispatch_once_t pred;
	static Ddukddak *instance = nil;
	dispatch_once(&pred, ^{
		instance = [[Ddukddak alloc] init];
	});
	return instance;
}

+(void) ShowDraft:(UIViewController *)rootView BID:(NSString *)bid {
	[Ddukddak inst];
	
	UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Ddukddak" bundle:nil];
	DdukddakLandscapeWebViewController *vc = [sb instantiateViewControllerWithIdentifier:@"DdukddakLandscapeWebView"];
	vc.url = [NSString stringWithFormat:URL_DDUKDDAK_SIAN_DETAIL, bid];
	
	[rootView presentViewController:vc animated:YES completion:nil];
}

+(BOOL) LoadProduct {
	return [[self inst] loadProduct];
}

-(BOOL) loadProduct {
	
	NSError *error;
	NSData *retData = [[Common info] downloadSyncWithURL:[NSURL URLWithString:URL_DDUKDDAK_PRODUCT]];
	if (retData != nil) {
		NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:retData options:kNilOptions error:&error];
		
		NSString *priceStr = [jsonData objectForKey:@"price"];
		if (priceStr) {
			_price = [priceStr intValue];
		}
		
		_mainImg = [jsonData objectForKey:@"main_img"];
		_photobookDesignListURL = [jsonData objectForKey:@"designlist_url"];
		_layflatDesignListURL = [jsonData objectForKey:@"layflatlist_url"];
		_themeInfoURL = [jsonData objectForKey:@"themeinfo_url"];
		_layoutCountURL = [jsonData objectForKey:@"layoutcnt_url"];
		_addCartURL = [jsonData objectForKey:@"addcart_url"];
		
		_arrange = [DdukddakOption new];
		{
			NSDictionary *optionJson = [jsonData objectForKey:@"edit_option_select"];
			if (optionJson) {
				_arrange.desc = [optionJson objectForKey:@"option_desc"];
				NSArray *optionArray = [optionJson objectForKey:@"option_array"];
				
				_arrange.details = [NSMutableArray<DdukddakOptionDetail *> new];
				
				if (optionArray) {
					for(NSDictionary *option in optionArray) {
						DdukddakOptionDetail *detail = [DdukddakOptionDetail new];
						detail.thumb = [option objectForKey:@"thumb"];
						detail.title = [option objectForKey:@"title"];
						detail.desc = [option objectForKey:@"desc"];
						detail.sendValue = [option objectForKey:@"sendvalue"];
						
						[_arrange.details addObject:detail];
					}
				}
			}
		}
		
		_size = [DdukddakOption new];
		{
			NSDictionary *optionJson = [jsonData objectForKey:@"edit_option_size"];
			if (optionJson) {
				_size.desc = [optionJson objectForKey:@"option_desc"];
				NSArray *optionArray = [optionJson objectForKey:@"option_array"];
				
				_size.details = [NSMutableArray<DdukddakOptionDetail *> new];
				
				if (optionArray) {
					for(NSDictionary *option in optionArray) {
						DdukddakOptionDetail *detail = [DdukddakOptionDetail new];
						detail.thumb = [option objectForKey:@"thumb"];
						detail.title = [option objectForKey:@"title"];
						detail.desc = [option objectForKey:@"desc"];
						detail.sendValue = [option objectForKey:@"sendvalue"];
						
						[_size.details addObject:detail];
					}
				}
			}
		}
		
		_deco = [DdukddakOption new];
		{
			NSDictionary *optionJson = [jsonData objectForKey:@"edit_option_deco"];
			if (optionJson) {
				_deco.desc = [optionJson objectForKey:@"option_desc"];
				NSArray *optionArray = [optionJson objectForKey:@"option_array"];
				
				_deco.details = [NSMutableArray<DdukddakOptionDetail *> new];
				
				if (optionArray) {
					for(NSDictionary *option in optionArray) {
						DdukddakOptionDetail *detail = [DdukddakOptionDetail new];
						detail.thumb = [option objectForKey:@"thumb"];
						detail.title = [option objectForKey:@"title"];
						detail.desc = [option objectForKey:@"desc"];
						detail.sendValue = [option objectForKey:@"sendvalue"];
						
						[_deco.details addObject:detail];
					}
				}
			}
		}
		return YES;
	}
	
	return NO;
}

+(void) LoadLayoutCounts:(NSInteger)totalSaveCount {
	
	[[Ddukddak inst] loadLayoutCounts:totalSaveCount];
	
}

-(void) loadLayoutCounts:(NSInteger)totalSaveCount {
	
	NSError *error;
	
	NSURL *url = [Common buildQueryURL:_layoutCountURL query:@[
	[NSURLQueryItem queryItemWithName:@"totSaveCount" value:[NSString stringWithFormat:@"%ld", (long)totalSaveCount]]
	,[NSURLQueryItem queryItemWithName:@"booktype" value:_productSelectedIdx == 0 ? @"designphotobook" : @"layflat"]
	  ]];
	NSData *retData = [[Common info] downloadSyncWithURL:url];
	
	if (_layoutCounts == nil)
		_layoutCounts = [NSMutableArray<DdukddakLayoutCount *> new];
	
	[_layoutCounts removeAllObjects];
	
	if (retData != nil) {
		NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:retData options:kNilOptions error:&error];

		{
			NSDictionary *optionJson = [jsonData objectForKey:@"s_size"];
			if (optionJson) {
				DdukddakLayoutCount *cnt = [DdukddakLayoutCount new];
				cnt.pageCount = [[optionJson objectForKey:@"page_count"] integerValue];
				cnt.layoutCount = [[optionJson objectForKey:@"layout_count"] integerValue];
				
				[_layoutCounts addObject:cnt];
			}
		}
		
		{
			NSDictionary *optionJson = [jsonData objectForKey:@"m_size"];
			if (optionJson) {
				DdukddakLayoutCount *cnt = [DdukddakLayoutCount new];
				cnt.pageCount = [[optionJson objectForKey:@"page_count"] integerValue];
				cnt.layoutCount = [[optionJson objectForKey:@"layout_count"] integerValue];
				
				[_layoutCounts addObject:cnt];
			}
		}
		
		{
			NSDictionary *optionJson = [jsonData objectForKey:@"l_size"];
			if (optionJson) {
				DdukddakLayoutCount *cnt = [DdukddakLayoutCount new];
				cnt.pageCount = [[optionJson objectForKey:@"page_count"] integerValue];
				cnt.layoutCount = [[optionJson objectForKey:@"layout_count"] integerValue];
				
				[_layoutCounts addObject:cnt];
			}
		}
	}
	
}

+(DdukddakAddCartReturn *) AddToCart {
	
	return [[Ddukddak inst] addToCart];
}

-(DdukddakAddCartReturn *) addToCart {
	
	// make request
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
	[request setHTTPShouldHandleCookies:NO];
	[request setTimeoutInterval:60.0f];
	[request setHTTPMethod:@"POST"];
	
	NSString *body = @"";
	
	// prepare params
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	
	[params setObject:[Common info].user.mUserid forKey:@"userid"];
	switch (_productSelectedIdx) {
		case 0:
			[params setObject:@"design" forKey:@"booktype"];
			break;
			
		case 1:
			[params setObject:@"layflat" forKey:@"booktype"];
			break;
	}
	
	[params setObject:_arrange.details[_arrangeSelectedIdx].sendValue forKey:@"classification"];
	[params setObject:[NSString stringWithFormat:@"%ld", (long)_layoutCounts[_sizeSelectedIdx].layoutCount] forKey:@"layout"]; // 변경 필요
	[params setObject:_deco.details[_decoSelectedIdx].sendValue forKey:@"deco"];
	
	[params setObject:_selectedTheme.theme1_id forKey:@"theme_depth1"];
	[params setObject:_selectedTheme.theme2_id forKey:@"theme_depth2"];
	[params setObject:[NSString stringWithFormat:@"%ld", (long)_layoutCounts[_sizeSelectedIdx].pageCount] forKey:@"makemaxpage"];
	[params setObject:_selSize forKey:@"size"];
	[params setObject:_selCover forKey:@"covertype"];
	[params setObject:_selCoating forKey:@"coating"];
	
	[params setObject:[NSString stringWithFormat:@"%ld", (long)_totSaveCount] forKey:@"totSaveCount"];
	
	[params setObject:@"ios" forKey:@"osinfo"];
	
	// add params
	if (params != nil) {
		
		for (NSString *param in params) {
			NSString *paramStr = [NSString stringWithFormat:@"%@=%@", param, [params objectForKey:param]];
			if (body.length > 0) {
				body = [body stringByAppendingString:@"&"];
			}
			body = [body stringByAppendingString:paramStr];
		}
	}
	
	[request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
	
	[request setURL:[Common buildQueryURL:_addCartURL query:@[]]];
	
	NSURLResponse *response = nil;
    NSError *error = nil;
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	
    if (error) {
        NSLog(@"** download error: %@", error);
        return nil;
    }
	
	NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
	DdukddakAddCartReturn *ret = [DdukddakAddCartReturn new];
	ret.code = [jsonData objectForKey:@"code"];
	ret.msg = [jsonData objectForKey:@"msg"];
	ret.moveURL = [jsonData objectForKey:@"moveurl"];
	
	return ret;
}

@end
