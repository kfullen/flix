//
//  MovieCell.h
//  flix
//
//  Created by kfullen on 6/26/19.
//  Copyright © 2019 kfullen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MovieCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *overviewLabel;
@property (weak, nonatomic) IBOutlet UIImageView *posterView;

@end

NS_ASSUME_NONNULL_END
