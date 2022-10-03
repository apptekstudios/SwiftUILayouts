/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A custom vertical stack that offers all its subviews the width of its largest subview.
*/

import SwiftUI

/// A custom vertical stack that offers all its subviews the width of its
/// widest subview.
///
/// This custom layout behaves almost identically to the ``MyEqualWidthHStack``,
/// except that it arranges equal-width subviews in a vertical stack, rather
/// than a horizontal one. It also implements a cache.
///
/// ### Adding a cache
///
/// The methods of the
/// [`Layout`](https://developer.apple.com/documentation/swiftui/layout)
/// protocol take a bidirectional `cache`
/// parameter. The cache provides access to optional storage that's shared among
/// all the methods of a particular layout instance. To demonstrate the use of a
/// cache, this layout creates storage to share size and spacing calculations
/// between its ``sizeThatFits(proposal:subviews:cache:)``  and
/// ``placeSubviews(in:proposal:subviews:cache:)`` implementations.
///
/// First, the layout defines a ``CacheData`` type for the storage:
///
/// ```swift
/// struct CacheData {
///     let maxSize: CGSize
///     let spacing: [CGFloat]
///     let totalSpacing: CGFloat
/// }
/// ```
///
/// It then implements the protocol's optional ``makeCache(subviews:)``
/// method to do the calculations for a set of subviews, returning a value of
/// the type defined above.
///
/// ```swift
/// func makeCache(subviews: Subviews) -> CacheData {
///     let maxSize = maxSize(subviews: subviews)
///     let spacing = spacing(subviews: subviews)
///     let totalSpacing = spacing.reduce(0) { $0 + $1 }
///
///     return CacheData(
///         maxSize: maxSize,
///         spacing: spacing,
///         totalSpacing: totalSpacing)
/// }
/// ```
///
/// If the subviews change, SwiftUI calls the layout's
/// ``updateCache(_:subviews:)`` method. The default implementation of that
/// method calls ``makeCache(subviews:)`` again, which recalculates the data.
/// Then the ``sizeThatFits(proposal:subviews:cache:)`` and
/// ``placeSubviews(in:proposal:subviews:cache:)`` methods make
/// use of their `cache` parameter to retrieve the data. For example,
/// ``placeSubviews(in:proposal:subviews:cache:)`` reads the size and the
/// spacing array from the cache.
///
/// ```swift
/// let maxSize = cache.maxSize
/// let spacing = cache.spacing
/// ```
///
/// Contrast this with ``MyEqualWidthHStack``, which doesn't use a
/// cache, and instead calculates the size and spacing information every time
/// it needs that information.
///
/// > Note: Most simple layouts, including this one, don't
///   gain much efficiency from using a cache. You can profile your app
///   with Instruments to find out whether a particular layout type actually
///   benefits from a cache.
public struct EqualVStack: Layout {
    public init(spacing: Double? = nil) {
        self.spacing = spacing
    }
    
    var spacing: Double?
    
    /// Returns a size that the layout container needs to arrange its subviews
    /// vertically with equal widths.
    public func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout CacheData
    ) -> CGSize {
        guard !subviews.isEmpty else { return .zero }

        // Load size and spacing information from the cache.
        let maxSize = cache.maxSize
        let totalSpacing = cache.totalSpacing

        return CGSize(
            width: maxSize.width,
            height: maxSize.height * CGFloat(subviews.count) + totalSpacing)
    }

    /// Places the subviews in a vertical stack.
    /// - Tag: placeSubviewsVertical
    public func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout CacheData
    ) {
        guard !subviews.isEmpty else { return }

        // Load size and spacing information from the cache.
        let maxSize = cache.maxSize
        let spacing = cache.spacing

        let placementProposal = ProposedViewSize(width: maxSize.width, height: bounds.height)
        var nextY = bounds.minY + maxSize.height / 2

        for index in subviews.indices {
            subviews[index].place(
                at: CGPoint(x: bounds.midX, y: nextY),
                anchor: .center,
                proposal: placementProposal)
            nextY += maxSize.height + spacing[index]
        }
    }

    /// A type that stores cached data.
    /// - Tag: CacheData
    public struct CacheData {
        let maxSize: CGSize
        let spacing: [CGFloat]
        let totalSpacing: CGFloat
    }

    /// Creates a cache for a given set of subviews.
    ///
    /// When the subviews change, SwiftUI calls the ``updateCache(_:subviews:)``
    /// method. The ``EqualVStack`` layout relies on the default
    /// implementation of that method, which just calls this method again
    /// to recreate the cache.
    /// - Tag: makeCache
    public func makeCache(subviews: Subviews) -> CacheData {
        let maxSize = maxSize(subviews: subviews)
        let spacing = spacing(subviews: subviews)
        let totalSpacing = spacing.reduce(0) { $0 + $1 }

        return CacheData(
            maxSize: maxSize,
            spacing: spacing,
            totalSpacing: totalSpacing)
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
    /// vertical dimension.
    private func spacing(subviews: Subviews) -> [CGFloat] {
        subviews.indices.map { index in
            guard index < subviews.count - 1 else { return 0 }

            return spacing ?? subviews[index].spacing.distance(
                to: subviews[index + 1].spacing,
                along: .vertical)
        }
    }
    public static var layoutProperties: LayoutProperties {
        var properties = LayoutProperties()
        properties.stackOrientation = .vertical
        return properties
    }
}
