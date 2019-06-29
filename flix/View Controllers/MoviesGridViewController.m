//
//  MoviesGridViewController.m
//  flix
//
//  Created by kfullen on 6/27/19.
//  Copyright © 2019 kfullen. All rights reserved.
//

#import "MoviesGridViewController.h"
#import "MoviesCollectionViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "DetailsViewController.h"

@interface MoviesGridViewController () <UICollectionViewDataSource, UICollectionViewDelegate,UISearchBarDelegate>
@property (nonatomic,strong) NSArray *movies;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UISearchBar *moviesGridSearchBar;
@property (strong, nonatomic) NSArray *gridFilteredMovies;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *gridActivityIndicator;



@end

@implementation MoviesGridViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.gridActivityIndicator startAnimating];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.moviesGridSearchBar.delegate = self;
    
    [self fetchMovies];
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *) self.collectionView.collectionViewLayout;
    
    layout.minimumInteritemSpacing = 3;
    layout.minimumLineSpacing = 3;
    CGFloat postersPerLine = 3;
    CGFloat itemWidth = (self.collectionView.frame.size.width - layout.minimumLineSpacing * (postersPerLine - 1)) / postersPerLine;
    CGFloat itemHeight = itemWidth * 1.5;
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
}

- (void) fetchMovies {
    // Get the array of movies
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/movie/429617/similar?api_key=7230e97fd50e8192bb968d8ac1d2e0ef&language=en-US&page=1"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Can't load movies"
                                                                           message:@"Network is down"
                                                                    preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Try Again"
                                                                   style:UIAlertActionStyleCancel
                                                                 handler:^(UIAlertAction * _Nonnull action)
                                           {
                                               // handle cancel response here. Doing nothing will dismiss the view.
                                               [self fetchMovies];
                                               
                                           }];
            
            [alert addAction:cancelAction];
            
            [self presentViewController:alert animated:YES completion:^{
                // optional code for what happens after the alert controller has finished presenting
            }];
            
        }
        else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            
            // Store movies in a property to use elsewhere
            self.movies = dataDictionary[@"results"];
            
            self.gridFilteredMovies = self.movies;
            
            // Reload your table view data
            [self.collectionView reloadData];
            
            [self.gridActivityIndicator stopAnimating];
        }
       
    }];
    [task resume];
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    MoviesCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MoviesCollectionViewCell" forIndexPath:indexPath];
    
    NSDictionary *movie = self.gridFilteredMovies[indexPath.item];
    NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
    NSString *posterURLString = movie[@"poster_path"];
    NSString *fullURLString = [baseURLString stringByAppendingString:posterURLString];
    
    NSURL *posterURL = [NSURL URLWithString:fullURLString];
    NSURLRequest *request = [NSURLRequest requestWithURL:posterURL];
    
    [cell.moviesCollectionPosterView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *imageRequest, NSHTTPURLResponse *imageResponse, UIImage *image) {
            if (imageResponse) {
                NSLog(@"Image was NOT cached, fade in image");
                cell.moviesCollectionPosterView.alpha = 0.0;
                cell.moviesCollectionPosterView.image = image;
                
                //Animate UIImageView back to alpha 1 over 0.3sec
                [UIView animateWithDuration:1.0 animations:^{
                    cell.moviesCollectionPosterView.alpha = 1.0;
                }];
            }
            else {
                NSLog(@"Image was cached so just update the image");
                cell.moviesCollectionPosterView.image = image;
            }
        }
                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse * response, NSError *error) {
                                                            // do something for the failure condition
                                                        }];
                                                        
    //cell.moviesCollectionPosterView.image = nil;
    //[cell.moviesCollectionPosterView setImageWithURL:posterURL];
    
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.gridFilteredMovies.count;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if (searchText.length != 0) {
        
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSDictionary *evaluatedObject, NSDictionary *bindings) {
            return [evaluatedObject[@"title"] containsString:searchText];
        }];
        self.gridFilteredMovies = [self.movies filteredArrayUsingPredicate:predicate];
        
    }
    else {
        self.gridFilteredMovies = self.movies;
    }
    
    [self.collectionView reloadData];
    
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.moviesGridSearchBar.showsCancelButton = YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.moviesGridSearchBar.showsCancelButton = NO;
    self.moviesGridSearchBar.text = @"";
    [self.moviesGridSearchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.moviesGridSearchBar resignFirstResponder];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UICollectionViewCell *tappedCell = sender;
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:tappedCell];
    NSDictionary *movie = self.gridFilteredMovies[indexPath.item];
    
    DetailsViewController *detailsViewController = [segue destinationViewController];
    detailsViewController.movie = movie;
}




@end
