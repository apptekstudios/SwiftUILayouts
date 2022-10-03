/*
ADAPTED FROM APPLE EXAMPLE

Abstract:
A custom horizontal stack that offers all its subviews the width of its largest subview.
*/

import SwiftUI

/// A custom horizontal stack that offers all its subviews the width of its
/// widest subview.
///
/// This custom layout arranges views horizontally, giving each the width needed
/// by the widest subview.
///
/// ![Three rectangles arranged in a horizontal line. Each rectangle contains
/// one smaller rectangle. The smaller rectangles have varying widths. Dashed
/// lines above each of the container rectangles show that the larger rectangles
/// all have the same width as each other.](voting-buttons)
///
/// The custom stack implements the protocol's two required methods. First,
/// ``sizeThatFits(proposal:subviews:cache:)`` reports the container's size,
/// given a set of subviews.
///
/// ```swift
/// let maxSize = maxSize(subviews: subviews)
/// let spacing = spacing(subviews: subviews)
/// let totalSpacing = spacing.reduce(0) { $0 + $1 }
///
/// return CGSize(
///     width: maxSize.width * CGFloat(subviews.count) + totalSpacing,
///     height: maxSize.height)
/// ```
///
/// This method combines the largest size in each dimension with the horizontal
/// spacing between subviews to find the container's total size. Then,
/// ``placeSubviews(in:proposal:subviews:cache:)`` tells each of the subviews
/// where to appear within the layout's bounds.
///
/// ```swift
/// let maxSize = maxSize(subviews: subviews)
/// let spacing = spacing(subviews: subviews)
///
/// let placementProposal = ProposedViewSize(width: maxSize.width, height: maxSize.height)
/// var nextX = bounds.minX + maxSize.width / 2
///
/// for index in subviews.indices {
///     subviews[index].place(
///         at: CGPoint(x: nextX, y: bounds.midY),
///         anchor: .center,
///         proposal: placementProposal)
///     nextX += maxSize.width + spacing[index]
/// }
/// ```
///
/// The method creates a single size proposal for the subviews, and then uses
/// that, along with a point that changes for each subview, to arrange the
/// subviews in a horizontal line with default spacing.
public struct EqualHStack: Layout {
    public init(spacing: Double? = nil, fillAvailable: Bool = false) {
        self.spacing = spacing
        self.fillAvailable = fillAvailable
    }
    
    var spacing: Double?
    var fillAvailable: Bool
    
    /// Returns a size that the layout container needs to arrange its subviews
    /// horizontally.
    /// - Tag: sizeThatFitsHorizontal
    public func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Void
    ) -> CGSize {
        guard !subviews.isEmpty else { return .zero }
        
        let spacing = spacing(subviews: subviews)
        let totalSpacing = spacing.reduce(0) { $0 + $1 }
        let maxSize = maxSize(subviews: subviews)
        
        if fillAvailable, let width = proposal.width {
            return CGSize(
                width: width,
                height: maxSize.height)
        } else {
            let sumWidth = subviews.reduce(into: Double.zero) { partialResult, subview in
                partialResult += calcSize(for: subview, targetSize: maxSize).width
            }
            
            return CGSize(
                width: sumWidth + totalSpacing,
                height: maxSize.height)
        }
    }

    /// Places the subviews in a horizontal stack.
    /// - Tag: placeSubviewsHorizontal
    public func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Void
    ) {
        guard !subviews.isEmpty else { return }

        let maxSize = maxSize(subviews: subviews)
        let spacing = spacing(subviews: subviews)
        var nextX = bounds.minX

        if fillAvailable, let width = proposal.width {
            let interim = subviews.indices.compactMap { index in
                InterimResult(subview: subviews[index], isNonExpandableWithWidth: isNonExpandableView(subviews[index]))
            }
            let nonExpandableSpace = interim.reduce(into: Double.zero) { partialResult, item in
                if let itemWidth = item.isNonExpandableWithWidth {
                    partialResult += itemWidth
                }
            }
            let expandableCount = interim.reduce(into: Int.zero) { partialResult, item in
                if item.isNonExpandableWithWidth == nil {
                    partialResult += 1
                }
            }
            let targetWidth = (expandableCount == .zero) ? 0 : (width - nonExpandableSpace) / Double(expandableCount)
            for index in subviews.indices {
                let size = calcSize(for: subviews[index], targetSize: CGSize(width: targetWidth, height: maxSize.height))
                let proposal = ProposedViewSize(size)
                subviews[index].place(
                    at: CGPoint(x: nextX + size.width/2, y: bounds.midY),
                    anchor: .center,
                    proposal: proposal)
                nextX += size.width + spacing[index]
            }
        } else {
            for index in subviews.indices {
                let size = calcSize(for: subviews[index], targetSize: maxSize)
                let proposal = ProposedViewSize(size)
                subviews[index].place(
                    at: CGPoint(x: nextX + size.width/2, y: bounds.midY),
                    anchor: .center,
                    proposal: proposal)
                nextX += size.width + spacing[index]
            }
        }
    }
    
    private func calcSize(for subview: LayoutSubview, targetSize: CGSize) -> CGSize {
        let actualSize = isNonExpandableView(subview) ?? targetSize.width
        return CGSize(width: actualSize, height: targetSize.height)
    }
    
    private func isNonExpandableView(_ subview: LayoutSubview) -> Double? {
        let itemMaxWidth = subview.sizeThatFits(.infinity).width
        return itemMaxWidth <= 1 ? itemMaxWidth : nil
    }

    /// Finds the largest ideal size of the subviews.
    private func maxSize(subviews: Subviews) -> CGSize {
        let subviewSizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let maxSize: CGSize = subviewSizes.reduce(.zero) { currentMax, subviewSize in
            CGSize(
                width: max(currentMax.width, subviewSize.width),
                height: max(currentMax.height, subviewSize.height))
        }

        return maxSize
    }

    /// Gets an array of preferred spacing sizes between subviews in the
    /// horizontal dimension.
    private func spacing(subviews: Subviews) -> [CGFloat] {
        subviews.indices.map { index in
            guard index < subviews.count - 1 else { return 0 }
            return spacing ?? subviews[index].spacing.distance(
                to: subviews[index + 1].spacing,
                along: .horizontal)
        }
    }
    
    public static var layoutProperties: LayoutProperties {
        var properties = LayoutProperties()
        properties.stackOrientation = .horizontal
        return properties
    }
    
    struct InterimResult {
        var subview: LayoutSubview
        var isNonExpandableWithWidth: Double?
    }
}
