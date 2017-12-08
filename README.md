# KBCircularCollectionView


Using KBCircularCollectionView

In order to use KBCircularCollectionView:

Make it the custom subclass of a UICollectionView component in your storyboard.
Set the CircularCollectionViewDataSource (not the standard UICollectionView dataSource) and implement the required functions.
Also their is option for your view controller to get informed when some user action happens on the collection view. CircularCollectionViewDelegate can
be used for this purpose.

CircularCollectionViewDataSource

The custom datasource is very similar to the standard UICollectionViewDataSource. There are 2 required and 1 optional methods to implement:

1. - (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
cellForItemAtIndexPath:(NSIndexPath *)dequeueIndexPath
withUsableIndexPath:(NSIndexPath *)usableIndexPath;

This function operates exactly the same as the regular cellForItemAtIndexPath, however, you should use dequeueIndexPath for dequeuing
your cell and usableIndexPath for your content.

2. - (NSInteger)numberOfItemsIncollectionView:(UICollectionView *)collectionView;
As with the standard UICollectionViewDatasource, simply return the number of cells of content you have.


3. - (NSUInteger)collectionView:(UICollectionView *)collectionView
heightOfCellForItemAtIndexPath:(NSIndexPath *)usableIndexPath
withWidth:(NSUInteger)width;

This is an optional method, if the height of the collectionview cell has dynamic height but fixed width, then method gives you the control
to specify the height of the particular cell based the datasource for that cell.
Future Support - We can modify this method so that you can tell the CircularCollectionViewDataSource about both height and width.

CircularCollectionViewDelegate

Currently CircularCollectionViewDelegate has just one method which will be called when cell is selected.
Future Support - Can extend the delegate to have more methods for different user actions

- (void) didSelectCellIn:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)usableIndexPath;

Other option in KBCircularCollectionView

- You can specify minimum line spacing between a collection view cell by setting 'minimumLineSpacing'. By default it will take the
value from the collection view's layout.
- KBCircularCollectionView supports expand and collapse of the cell when it is selected. If your cell size height is fixed and you know
the height of it then you can configure it. Use collapsedHeight and expandedHeight for collapsed cell height and expanded cell height respectively.
- If the height of your cell is dynamic and vary depending on the content in each cell then you can use the optional CircularCollectionViewDataSource
method to specify the cell's height. Please note this method will be called from FlowLayout's collectionView:layout:sizeForItemAtIndexPath: method.
The height you send will be provided to the flowlayout for it to layout the cells.




Current Support

You can use KBCircularCollectionView to scroll infinitely in a vertical direction with equally sized cells and dynamic height cells.

Future

We can improve KBCircularCollectionView to include horizontal scroll support.
