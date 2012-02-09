//
//  BookDetailViewController.h
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 2/9/12.
//  Copyright (c) 2012 Axel Rivera. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BookDetailViewController : UIViewController

@property (unsafe_unretained, nonatomic) IBOutlet UILabel *titleLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *lastUpdatedLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView *notesContainer;
@property (strong, nonatomic) NSString *bookTitle;
@property (strong, nonatomic) NSString *bookDescription;
@property (strong, nonatomic) NSString *bookLastUpdate;
@property (strong, nonatomic) NSString *bookNotes;

- (id)initWithTitle:(NSString *)title description:(NSString *)description lastUpdate:(NSString *)lastUpdate notes:(NSString *)notes;

@end
