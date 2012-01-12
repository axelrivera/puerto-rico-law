//
//  SectionContentViewController.h
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 12/21/11.
//  Copyright (c) 2011 Axel Rivera. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Section;
@class SectionManager;

@interface SectionContentViewController : UIViewController <UIWebViewDelegate>

@property (unsafe_unretained, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) SectionManager *manager;
@property (strong, nonatomic) NSString *contentStr;

- (id)initWithSection:(Section *)section siblingSections:(NSArray *)siblings currentSiblingIndex:(NSInteger)index;

- (NSString *)htmlStringForSection;
- (NSString *)htmlStringForEmail;
- (NSString *)pathForContentFile;
- (void)refresh;

@end
