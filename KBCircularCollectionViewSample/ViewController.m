//
//  ViewController.m
//  KBCircularCollectionViewSample
//
//  Created by Kiran Basavaraju on 12/6/17.
//  Copyright © 2017 Kiran Basavaraju. All rights reserved.
//

#import "ViewController.h"
#import "KBCircularCollectionView.h"
#import "KBCustomCollectionViewCell.h"

@interface ViewController ()<CircularCollectionViewDataSource,CircularCollectionViewDelegate>

@property (nonatomic, strong) NSMutableArray *contentArrray;
@property (weak, nonatomic) IBOutlet KBCircularCollectionView *circularCollectionView;
@end

@implementation ViewController

static NSString * const reuseIdentifier = @"Cell";

static NSString * const contentLabel = @"Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda.";

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.contentArrray = [NSMutableArray arrayWithObjects:contentLabel,contentLabel,contentLabel,contentLabel,contentLabel,contentLabel,contentLabel, nil];
    
    self.circularCollectionView.circularCollectionViewDataSource = self;
    self.circularCollectionView.circularCollectionViewDelegate = self;
    
    UINib *cellNib = [UINib nibWithNibName:@"KBCustomCollectionViewCell" bundle:nil];
    [self.circularCollectionView registerNib:cellNib
                  forCellWithReuseIdentifier:reuseIdentifier];
    
    self.circularCollectionView.collapsedHeight = 60.0;
    self.circularCollectionView.expandedHeight = 150.0;
    self.circularCollectionView.minimumLineSpacing = 32.0;
    [self.circularCollectionView reloadData];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
    
    // invalidate layout on rotation
    [self.circularCollectionView.collectionViewLayout invalidateLayout];
}

#pragma mark CircularCollectionViewDataSource methods

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)dequeueIndexPath
                     withUsableIndexPath:(NSIndexPath *)usableIndexPath
{
    KBCustomCollectionViewCell *cell = (KBCustomCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:dequeueIndexPath];
    cell.cellLabel.text = self.contentArrray[usableIndexPath.row];
    return cell;
}

- (NSInteger)numberOfItemsIncollectionView:(UICollectionView *)collectionView
{
    return self.contentArrray.count;
}

- (NSUInteger)collectionView:(UICollectionView *)collectionView heightOfCellForItemAtIndexPath:(NSIndexPath *)usableIndexPath withWidth:(NSUInteger)width
{
    NSAttributedString* labelString = [[NSAttributedString alloc] initWithString:self.contentArrray[usableIndexPath.row]
                                                                      attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17.0]}];
    CGRect cellRect = [labelString boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    
    return ceil(cellRect.size.height) ;
}

#pragma mark CircularCollectionViewDelegate methods

- (void) didSelectCellIn:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)usableIndexPath
{
    NSLog(@"CollectionView cell was selected");
}

@end
