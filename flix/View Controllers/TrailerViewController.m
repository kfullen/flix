//
//  TrailerViewController.m
//  flix
//
//  Created by kfullen on 6/30/19.
//  Copyright © 2019 kfullen. All rights reserved.
//

#import "TrailerViewController.h"
#import "UIImageView+AFNetworking.h"
#import "DetailsViewController.h"
#import <WebKit/WebKit.h>


@interface TrailerViewController ()
@property (weak, nonatomic) IBOutlet WKWebView *trailerWebView;

@end

@implementation TrailerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *movieId = self.trailerMovie[@"id"];
    NSString *apiKey = @"7230e97fd50e8192bb968d8ac1d2e0ef";
    NSString *urlString = [NSString stringWithFormat:@"https://api.themoviedb.org/3/movie/%@/videos?api_key=%@&language=en-US]",movieId,apiKey];
    NSLog(@"retrieving key: %@",urlString);
    
    // Convert the url String to a NSURL object.
    NSURL *url = [NSURL URLWithString:urlString];
    
    // Place the URL in a URL Request.
    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                         timeoutInterval:10.0];

    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
            
        }
        else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSLog(@"data is stored");
            
            // Store movies in a property to use elsewhere
            
            NSArray *results = dataDictionary[@"results"];
            NSDictionary *trailer = results[0];
            NSString *key = trailer[@"key"];
            NSString *videoURLString = [NSString stringWithFormat:@"https://www.youtube.com/watch?v=\%@",key];
            
            NSLog(@"printing video url: %@",videoURLString);
            
            NSURL *videoURL = [NSURL URLWithString:videoURLString];
            
            // Place the URL in a URL Request.
            NSURLRequest *videoRequest = [NSURLRequest requestWithURL:videoURL
        cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                 timeoutInterval:10.0];
            // Load Request into WebView.
            [self.trailerWebView loadRequest:videoRequest];
            
            
        }
        
    }];
    [task resume];
    
    
}
- (IBAction)dismissTrailerButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
