//
//  SectionSelectionDelegate.h
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 12/31/11.
//  Copyright (c) 2011 Axel Rivera. All rights reserved.
//

#import <Foundation/Foundation.h>
#import	"Section.h"

@protocol SectionSelectionDelegate <NSObject>

- (void)sectionSelectionChanged:(Section *)section
					 dataSource:(NSArray *)data
				siblingSections:(NSArray *)siblings
			currentSiblingIndex:(NSInteger)index;
- (void)refreshCurrentSection;
- (void)clearCurrentSection;

@end
