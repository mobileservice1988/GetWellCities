//
//  CenterCollectionCellFlowLayout.swift
//  Copyright © 2016 Get Well Company. All rights reserved.
//

import UIKit

class CenterCollectionCellFlowLayout: UICollectionViewFlowLayout {
    
    override func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        if let collectionView = self.collectionView {
            let collectionViewBounds = collectionView.bounds
            let halfWidth = collectionViewBounds.size.width * 0.5;
            let proposedContentOffsetCenterX = proposedContentOffset.x + halfWidth;
            if let attributesForVisibleCells = self.layoutAttributesForElementsInRect(collectionViewBounds) {
                var candidateAttributes : UICollectionViewLayoutAttributes?
                for attributes in attributesForVisibleCells {
                    if attributes.representedElementCategory != .Cell {
                        continue
                    }
                    if let candidateAttrs = candidateAttributes {
                        let a = attributes.center.x - proposedContentOffsetCenterX
                        let b = candidateAttrs.center.x - proposedContentOffsetCenterX
                        if fabsf(Float(a)) < fabsf(Float(b)) {
                            candidateAttributes = attributes;
                        }
                    }
                    else {
                        candidateAttributes = attributes;
                        continue;
                    }
                }
                if(proposedContentOffset.x == -(collectionView.contentInset.left)) {
                    return proposedContentOffset
                }
                return CGPoint(x: floor(candidateAttributes!.center.x - halfWidth), y: proposedContentOffset.y)
            }
        }
        return super.targetContentOffsetForProposedContentOffset(proposedContentOffset)
    }
}
