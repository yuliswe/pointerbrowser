//
//  WebPDF.h
//  Pointer
//
//  Created by Yu Li on 2019-03-15.
//  Copyright © 2019 Yu Li. All rights reserved.
//

#import <Quartz/Quartz.h>

NS_ASSUME_NONNULL_BEGIN

@class WebUI;
@interface WebPDF : PDFView
@property WebUI* webUI;
@property NSMutableDictionary<id, NSTouch*>* touches;
@property NSArray<PDFSelection*>* current_find_highlights;
@property int current_find_index;
@property NSString* current_find_text;
- (instancetype)initWithWebUI:(WebUI*)parent;
- (void)findHighlightAll:(NSString*)text;
- (void)findClear;
- (void)findScrollToNextHighlight;
- (void)findScrollToPreviousHighlight;
@end

NS_ASSUME_NONNULL_END
