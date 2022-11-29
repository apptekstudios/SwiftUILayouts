/*
ADAPTED FROM APPLE EXAMPLE

Abstract:
A custom horizontal stack that offers all its subviews the width of its largest subview.
*/

import SwiftUI

public struct CompressingHStack: Layout {
    public init(spacing: Double? = nil) {
        self.spacing = spacing
    }
    
    var spacing: Double?
    
    /// Returns a size that the layout container needs to arrange its subviews
    /// horizontally.
    /// - Tag: sizeThatFitsHorizontal
    public func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Void
    ) -> CGSize {
        guard !subviews.isEmpty else { return .zero }

        let maxSize = maxSize(subviews: subviews)
        let sizes = subviews.map { subview in
            calcSize(for: subview, targetSize: maxSize)
        }
        let spacing = spacing(subviews: subviews)
        let totalSpacing = spacing.reduce(0) { $0 + $1 }

        return CGSize(
            width: sizes.map(\.width).reduce(into: .zero, { $0 += $1}) + totalSpacing,
            height: sizes.map(\.height).max() ?? .zero)
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
    
    private func calcSize(for subview: LayoutSubview, targetSize: CGSize) -> CGSize {
        return subview.sizeThatFits(ProposedViewSize(width: nil, height: targetSize.height))
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
}
