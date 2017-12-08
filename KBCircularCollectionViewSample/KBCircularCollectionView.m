//
//  KBCircularCollectionView.m
//  KBCircularCollectionViewSample
//
//  Created by Kiran Basavaraju on 12/6/17.
//  Copyright © 2017 Kiran Basavaraju. All rights reserved.
//

#import "KBCircularCollectionView.h"

@interface KBCircularCollectionView()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (nonatomic, assign) NSInteger indexOffset;
@property (nonatomic,strong) NSMutableArray *cellExpandCollapseInfo;

@end

@implementation KBCircularCollectionView

-(instancetype)initWithCoder:(NSCoder *)coder
{
    if( self = [super initWithCoder:coder])
    {
        [self setupCellDimensions];
        self.delegate = self;
        self.dataSource = self;
        _shouldScrollVertically = YES;//Default value
        _cellExpandCollapseInfo = [NSMutableArray array];
    }
    return self;
}


-(void)setupCellDimensions
{
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionViewLayout;
    self.collapsedHeight = layout.itemSize.height;
    self.minimumLineSpacing = layout.minimumLineSpacing;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    if(self.shouldScrollVertically)
    {
        [self centerVerticalyIfNeeded];
    }
    else
    {
        //Future enhancements for horizontal scroll
        [self centerHorizontalyIfNeeded];
    }
    
}

/* Reference: https://developer.apple.com/videos/play/wwdc2011/104/
* Use the contentOffset to check if the current scroll distance is more than a quarter from the centre point
   of all the cells in either direction. This is arbitrary but works well.
* If it is, then we change the contentOffset back to the centre to prevent it reaching an end.
* We then work out how many cells need to be shifted and change the content array with a helper function.  I.e. shift the array indices by that many cells in either direction.
* We call reloadData to update the cells from our delegate and data source functions.
**/
- (void)centerVerticalyIfNeeded
{
    CGPoint currentOffset = self.contentOffset;
    CGFloat contentHeight = self.contentSize.height;
    CGFloat centerOffsetY = (contentHeight - self.bounds.size.height)/ 2.0;
    CGFloat distanceFromCenterY = fabs(currentOffset.y - centerOffsetY);
    
    if (distanceFromCenterY > contentHeight/4.0)
    {
        // Total cells (including partial cells) from centre
        NSInteger cellCount = distanceFromCenterY/(self.collapsedHeight+self.minimumLineSpacing);
        
        // Amount of cells to shift (whole number) - conditional statement due to nature of +ve or -ve cellcount
        NSInteger shiftCells = (cellCount > 0) ? floorf(cellCount) : ceil(cellCount);
        
        // Amount left over to correct for
        NSInteger offsetCorrection = (labs(cellCount % 1))*(self.collapsedHeight+self.minimumLineSpacing);
        
        // Scroll back to the centre of the view, offset by the correction to ensure it's not noticable
        // and decide if it needs to scrolled up or down
        if (self.contentOffset.y < centerOffsetY)
        {
            self.contentOffset = CGPointMake(currentOffset.x , centerOffsetY-offsetCorrection);
        }
        else if (self.contentOffset.y > centerOffsetY)
        {
            self.contentOffset = CGPointMake(currentOffset.x , centerOffsetY+offsetCorrection);
        }
        [self shiftContentArrayWithOffset:[self getCorrectedIndexFor:shiftCells]];
        [self reloadData];
    }
}

- (void)centerHorizontalyIfNeeded
{
    //Future Support
}

//This method returns the proper cell index so that we wont get array out of bounds
- (NSInteger) getCorrectedIndexFor:(NSInteger)indexToCorrect
{
    NSInteger numberOfCells = [self.circularCollectionViewDataSource numberOfItemsIncollectionView:self];
    if(indexToCorrect < numberOfCells && indexToCorrect >= 0)
    {
        return indexToCorrect;
    }
    else
    {
        NSInteger countIndex = (float)indexToCorrect/(float)numberOfCells;
        NSInteger flooredValue = floor(countIndex);
        NSInteger offset = numberOfCells*flooredValue;
        return indexToCorrect-offset;
    }
    return 0;
}

- (void)shiftContentArrayWithOffset:(NSInteger)offset
{
    self.indexOffset += offset;
}

#pragma mark - UICollectionViewDataSource Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger numberOfItems = [self.circularCollectionViewDataSource numberOfItemsIncollectionView:self];
    
    return 3 * numberOfItems;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger usableIndex = labs([self getCorrectedIndexFor:indexPath.row-self.indexOffset]);
    NSIndexPath *usableIndexPath = [NSIndexPath indexPathForRow:usableIndex inSection:0];
    
    return [self.circularCollectionViewDataSource collectionView:self
                                          cellForItemAtIndexPath:indexPath
                                             withUsableIndexPath:usableIndexPath];
    
}


#pragma mark - UICollectionViewDelegate Methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger usableIndex = labs([self getCorrectedIndexFor:indexPath.row-self.indexOffset]);
    
    if([self.cellExpandCollapseInfo containsObject:[NSNumber numberWithInteger:usableIndex]])
    {
        [self.cellExpandCollapseInfo removeObject:[NSNumber numberWithInteger:usableIndex]];
    }
    else
    {
        [self.cellExpandCollapseInfo addObject:[NSNumber numberWithInteger:usableIndex]];
    }
    
    [self.collectionViewLayout invalidateLayout];
    
    // Avoid retain cycles
    KBCustomCollectionViewCell *__weak cell = (KBCustomCollectionViewCell*)[self cellForItemAtIndexPath:indexPath];
    void (^animateChangeHeight)(void) = ^()
    {
        CGRect frame = cell.frame;
        frame.size.height = self.expandedHeight;
        cell.frame = frame;
    };

    // Animate
    [UIView transitionWithView:cell duration:0.1f options: UIViewAnimationOptionCurveLinear animations:animateChangeHeight completion:nil];
}

#pragma mark - UICollectionViewDelegateFlowLayout

/* Reference
 ** https://stackoverflow.com/questions/28161839/uicollectionview-dynamic-cell-height?rq=1
 ** https://janthielemann.de/ios-development/self-sizing-uicollectionviewcells-ios-10-swift-3/
 ** https://stackoverflow.com/questions/40129245/ios-10-11-uicollectionviewflowlayout-using-uicollectionviewflowlayoutautomaticsi
 */

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat collectionWidth = CGRectGetWidth(collectionView.bounds);
    CGFloat itemWidth = collectionWidth;
    CGFloat itemHeight = 88.0;//some random number to begin with, need to change this

    NSInteger usableIndex = labs([self getCorrectedIndexFor:indexPath.row-self.indexOffset]);
    if([self.cellExpandCollapseInfo containsObject:[NSNumber numberWithInteger:usableIndex]])
    {
        itemHeight = self.expandedHeight;
        if([self.circularCollectionViewDataSource respondsToSelector:@selector(collectionView: heightOfCellForItemAtIndexPath: withWidth:)])
        {
            itemHeight = [self.circularCollectionViewDataSource collectionView:collectionView
                                                heightOfCellForItemAtIndexPath:[NSIndexPath indexPathForRow:usableIndex inSection:0]
                                                                     withWidth:itemWidth];
        }
    }
    else
    {
        itemHeight = self.collapsedHeight;
    }
    
    return CGSizeMake(itemWidth, itemHeight);
}

- (CGFloat)collectionView:(__unused UICollectionView *)collectionView layout:(__unused UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(__unused NSInteger)section
{
    return self.minimumLineSpacing;
}


@end
