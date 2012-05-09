//
//  BookDetailViewController.h
//  PuertoRicoLaw
//
//  Created by Axel Rivera on 2/9/12.
//  Copyright (c) 2012 Axel Rivera. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BookDetailViewControllerDelegate;

@interface BookDetailViewController : UIViewController

@property (unsafe_unretained, nonatomic) id <BookDetailViewControllerDelegate> delegate;
@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *descriptionLabel;
@property (strong, nonatomic) UILabel *lastUpdatedLabel;
@property (strong, nonatomic) UILabel *notesLabel;
@property (strong, nonatomic) NSString *bookTitle;
@property (strong, nonatomic) NSString *bookDescription;
@property (strong, nonatomic) NSString *bookLastUpdate;
@property (strong, nonatomic) NSString *bookNotes;

- (id)initWithTitle:(NSString *)title description:(NSString *)description lastUpdate:(NSString *)lastUpdate notes:(NSString *)notes;

@end

@protocol BookDetailViewControllerDelegate <NSObject>

- (void)detailsViewControllerDidFinish:(UIViewController *)controller;

@end
