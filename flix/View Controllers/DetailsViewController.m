//
//  DetailsViewController.m
//  flix
//
//  Created by kfullen on 6/27/19.
//  Copyright © 2019 kfullen. All rights reserved.
//

#import "DetailsViewController.h"
#import "TrailerViewController.h"
#import "UIImageView+AFNetworking.h"

@interface DetailsViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *DetailsImageView;
@property (weak, nonatomic) IBOutlet UIImageView *SmallDetailsImageView;
@property (weak, nonatomic) IBOutlet UILabel *DetailsTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *DetailsOverviewLabel;
@property (weak, nonatomic) IBOutlet UILabel *DetailsReleaseLabel;
@property (weak, nonatomic) IBOutlet UIButton *trailerButton;

@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *backdropBaseURLString = @"https://image.tmdb.org/t/p/w500";
    NSString *backdropURLString = self.movie[@"backdrop_path"];
    NSString *fullBackdropURLString = [backdropBaseURLString stringByAppendingString:backdropURLString];
    
    NSURL *backdropURL = [NSURL URLWithString:fullBackdropURLString];
    
    NSString *posterBaseURLString = @"https://image.tmdb.org/t/p/w500";
    NSString *posterURLString = self.movie[@"poster_path"];
    NSString *fullPosterURLString = [posterBaseURLString stringByAppendingString:posterURLString];
    
    NSURL *posterURL = [NSURL URLWithString:fullPosterURLString];
    
    self.DetailsImageView.image = nil;
    [self.DetailsImageView setImageWithURL:backdropURL];
    
    self.SmallDetailsImageView.image = nil;
    [self.SmallDetailsImageView setImageWithURL:posterURL];
    
    
    self.DetailsTitleLabel.text = self.movie[@"title"];
    self.DetailsOverviewLabel.text = self.movie[@"overview"];
    self.DetailsReleaseLabel.text = self.movie[@"release_date"];
    
    //[self.DetailsTitleLabel sizeToFit];
    [self.DetailsOverviewLabel sizeToFit];
    [self.DetailsReleaseLabel sizeToFit];
    
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    TrailerViewController *trailerViewController = [segue destinationViewController];
    
    // Pass the selected object to the new view controller.
    NSDictionary *trailerMovie = self.movie;
    trailerViewController.trailerMovie = trailerMovie;
    
    
}


@end
