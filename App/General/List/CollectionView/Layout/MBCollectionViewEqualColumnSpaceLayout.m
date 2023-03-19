
#import "MBCollectionViewEqualColumnSpaceLayout.h"
#import <RFKit/UIView+RFAnimate.h>

@interface MBCollectionViewEqualColumnSpaceLayout ()
@end

@implementation MBCollectionViewEqualColumnSpaceLayout

- (void)setNumberOfColumns:(NSUInteger)numberOfColumns {
    if (_numberOfColumns == numberOfColumns) return;
    _numberOfColumns = numberOfColumns;
    [self invalidateLayout];
}

- (void)setLayoutStyle:(MBCollectionViewColumnLayoutStyle)layoutStyle {
    if (_layoutStyle == layoutStyle) return;
    _layoutStyle = layoutStyle;
    [self invalidateLayout];
}

- (void)prepareLayout {
    [super prepareLayout];
    NSUInteger columns = self.numberOfColumns;
    CGFloat itemSpace = 0;
    CGFloat insetSize = 0;
    
    switch (self.layoutStyle) {
        case MBCollectionViewColumnLayoutStyleCenter:
            itemSpace = floor((self.collectionView.width / columns - self.itemSize.width));
            insetSize = itemSpace / 2;
            break;
        case MBCollectionViewColumnLayoutStyleNoSectionInset:
            itemSpace = floor((self.collectionView.width - self.itemSize.width * columns) / (columns - 1));
            insetSize = 0;
            break;
        default:
            itemSpace = floor((self.collectionView.width - self.itemSize.width * columns) / (columns + 1));
            insetSize = itemSpace;
            break;
    }

    UIEdgeInsets inset = self.sectionInset;
    inset.left = insetSize;
    inset.right = insetSize;
    self.sectionInset = inset;
    if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        self.minimumLineSpacing = itemSpace;
    }
    else {
        self.minimumInteritemSpacing = itemSpace;
    }
    [self.collectionView invalidateIntrinsicContentSize];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    CGRect oldBounds = self.collectionView.bounds;
    if (CGRectGetWidth(oldBounds) != CGRectGetWidth(newBounds)) {
        return YES;
    }
    return [super shouldInvalidateLayoutForBoundsChange:newBounds];
}

@end
