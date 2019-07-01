//
//  MoviesViewController.m
//  flix
//
//  Created by kfullen on 6/26/19.
//  Copyright © 2019 kfullen. All rights reserved.
//

#import "MoviesViewController.h"
#import "MovieCell.h"
#import "UIImageView+AFNetworking.h"
#import "DetailsViewController.h"

@interface MoviesViewController () <UITableViewDataSource, UITableViewDelegate,UISearchBarDelegate>

@property (nonatomic,strong) NSArray *movies;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *movieActivityIndicator;
@property (strong, nonatomic) NSArray *filteredMovies;
@property (strong, nonatomic) IBOutlet UISearchBar *moviesSearchBar;

@end

@implementation MoviesViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.movieActivityIndicator startAnimating];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.moviesSearchBar.delegate = self;
    
    [self fetchMovies];
    
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchMovies) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    // Do any additional setup after loading the view.
}

- (void) fetchMovies {
    // Get the array of movies
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/movie/now_playing?api_key=7230e97fd50e8192bb968d8ac1d2e0ef"];
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
            
            self.filteredMovies = self.movies;
            
            // Reload your table view data
            [self.tableView reloadData];
            
            [self.movieActivityIndicator stopAnimating];
            
        }
        [self.refreshControl endRefreshing];
    }];
    [task resume];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:
    (NSInteger)section {
    return self.filteredMovies.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:
    (NSIndexPath *)indexPath {
    MovieCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MovieCell"];
    
    NSDictionary *movie = self.filteredMovies[indexPath.row];
    
    cell.titleLabel.text = movie[@"title"];
    cell.overviewLabel.text = movie[@"overview"];
    NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
    NSString *posterURLString = movie[@"poster_path"];
    NSString *fullURLString = [baseURLString stringByAppendingString:posterURLString];
    
    NSURL *posterURL = [NSURL URLWithString:fullURLString];
    cell.posterView.image = nil;
    [cell.posterView setImageWithURL:posterURL];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    return cell;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if (searchText.length != 0) {
        
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSDictionary *evaluatedObject, NSDictionary *bindings) {
            return [evaluatedObject[@"title"] containsString:searchText];
        }];
        self.filteredMovies = [self.movies filteredArrayUsingPredicate:predicate];
        
        
    }
    else {
        self.filteredMovies = self.movies;
    }
    
    [self.tableView reloadData];
    
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.moviesSearchBar.showsCancelButton = YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.moviesSearchBar.showsCancelButton = NO;
    self.moviesSearchBar.text = @"";
    [self.moviesSearchBar resignFirstResponder];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    UITableViewCell *tappedCell = sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
    NSDictionary *movie = self.filteredMovies[indexPath.row];
    DetailsViewController *detailsViewController = [segue destinationViewController];
    
    // Pass the selected object to the new view controller.
    detailsViewController.movie = movie;
}


@end
