//
//  UltravisualLayout.swift
//  RWDevCon
//
//  Created by Mic Pringle on 27/02/2015.
//  Copyright (c) 2015 Ray Wenderlich. All rights reserved.
//

import UIKit

/* The heights are declared as constants outside of the class so they can be easily referenced elsewhere */
struct UltravisualLayoutConstants {
    struct Cell {
        /* The height of the non-featured cell */
        static let standardHeight: CGFloat = 100
        /* The height of the first visible cell */
        static let featuredHeight: CGFloat = 280
    }
}

class UltravisualLayout: UICollectionViewFlowLayout {
  
    // MARK: Properties and Variables
      
    /* The amount the user needs to scroll before the featured cell changes */
    let dragOffset: CGFloat = 200.0
    
    var cache = [UICollectionViewLayoutAttributes]()
      
    /* Returns the item index of the currently featured cell */
    var featuredItemIndex: Int {
        get {
          /* Use max to make sure the featureItemIndex is never < 0 */
          return max(0, Int(collectionView!.contentOffset.y / dragOffset))
        }
    }
      
    /* Returns a value between 0 and 1 that represents how close the next cell is to becoming the featured cell */
    var nextItemPercentageOffset: CGFloat {
        get {
          return (collectionView!.contentOffset.y / dragOffset) - CGFloat(featuredItemIndex)
        }
    }
      
    /* Returns the width of the collection view */
    var width: CGFloat {
        get {
          return CGRectGetWidth(collectionView!.bounds)
        }
    }
      
    /* Returns the height of the collection view */
    var height: CGFloat {
        get {
          return CGRectGetHeight(collectionView!.bounds)
        }
    }
  
    /* Returns the number of items in the collection view */
    var numberOfItems: Int {
        get {
        return collectionView!.numberOfItemsInSection(0)
        }
        set {
            self.numberOfItems = newValue
        }
    }
  
    // MARK: UICollectionViewLayout
  
    /* Return the size of all the content in the collection view */
    override func collectionViewContentSize() -> CGSize {
        // 需要滚动numberOfItems - 1 个偏移量才可以把最后一个item移动到最上面
        let contentHeight = (CGFloat(numberOfItems - 1) * dragOffset) + height
        return CGSize(width: width, height: contentHeight)
    }
  
    override func prepareLayout() {
        super.prepareLayout()
    
        cache.removeAll(keepCapacity: false)

        let standardHeight = UltravisualLayoutConstants.Cell.standardHeight
        let featuredHeight = UltravisualLayoutConstants.Cell.featuredHeight
        
        var originY: CGFloat = 0
    
        for item in 0..<numberOfItems {
        
            var height = standardHeight
        
            let indexPath = NSIndexPath(forItem: item, inSection: 0)
            let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
            
            attributes.zIndex = item
            
            if item == featuredItemIndex {
                
                height = featuredHeight
                // 当 featuredItemIndex = featuredItemIndex + 1 时 临界点 (contentOffset.y变化)，下一张item的y位置应该是contentOffset.y，所以这里慢慢做滑动将图片上移
                originY = collectionView!.contentOffset.y - standardHeight * nextItemPercentageOffset
            }
            else if item == featuredItemIndex + 1 {
                let heightOffset = max(0, (featuredHeight - standardHeight) * nextItemPercentageOffset)
                height = standardHeight + heightOffset
                // 当 featureItemIndex = item 时 临界点 ，此item.y位置应该是contentOffset.y，但是item.y ＝ 上一个(originY + height = contentOffset.y - standardHeight * nextItemPercentageOffset + featuredItemIndex * nextItemPercentageOffset(这个percent可以添加上，因为已经马上就是1了)  )
                originY -= heightOffset
            }
        
            attributes.frame = CGRect(x: 0, y: originY, width: width, height: height)
            cache.append(attributes)
        
            originY += height
        }
    }
    
    /* Return all attributes in the cache whose frame intersects with the rect passed to the method */
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        for attributes in cache {
            if CGRectIntersectsRect(attributes.frame, rect) {
                layoutAttributes.append(attributes)
            }
        }
        return layoutAttributes
    }
  
    /* Return true so that the layout is continuously invalidated as the user scrolls */
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }
  
    override func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        let itemIndex = round(proposedContentOffset.y / dragOffset)
        return CGPoint(x: 0, y: itemIndex * dragOffset)
    }
}
