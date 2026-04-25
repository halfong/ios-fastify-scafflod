import SwiftUI

// MARK: - FlowLayout Custom Layout (iOS 16+)
/// A custom SwiftUI layout that arranges its subviews in a flow, wrapping them to the next line
/// when they exceed the available width.
struct FlowLayout: Layout {
    var horizontalSpacing: CGFloat = 8
    var verticalSpacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        // Determine the available width for layout. If no width is proposed, use a large value.
        let containerWidth = proposal.width ?? .infinity

        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var totalWidth: CGFloat = 0 // To track the actual width used by the content

        // Iterate through each subview to calculate its size and position
        for index in subviews.indices {
            let subview = subviews[index]
            // Request the ideal size of the subview without any specific proposal
            let subviewSize = subview.sizeThatFits(.unspecified)

            // Check if adding this subview exceeds the container width
            if currentX + subviewSize.width > containerWidth && currentX > 0 {
                // If it exceeds and it's not the very first item on the line,
                // move to the next line.
                currentY += lineHeight + verticalSpacing
                currentX = 0 // Reset X position for the new line
                lineHeight = 0 // Reset line height for the new line
            }

            // Place the subview at the current X position
            currentX += subviewSize.width
            // Update the maximum height of the current line
            lineHeight = max(lineHeight, subviewSize.height)
            // Update the total width used, in case the last line is shorter than previous ones
            totalWidth = max(totalWidth, currentX)

            // Add horizontal spacing if it's not the last item in the entire layout
            if index < subviews.count - 1 {
                currentX += horizontalSpacing
            }
        }

        // Add the height of the last line to the total Y position
        currentY += lineHeight

        // Return the container width if available, otherwise return the content width
        let finalWidth = proposal.width != nil && proposal.width != .infinity 
            ? containerWidth 
            : totalWidth
        
        return CGSize(width: finalWidth, height: currentY)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        _ = bounds.width
        var currentX: CGFloat = bounds.minX
        var currentY: CGFloat = bounds.minY
        var lineHeight: CGFloat = 0

        for index in subviews.indices {
            let subview = subviews[index]
            let subviewSize = subview.sizeThatFits(.unspecified)

            if currentX + subviewSize.width > bounds.maxX && currentX > bounds.minX {
                currentY += lineHeight + verticalSpacing
                currentX = bounds.minX
                lineHeight = 0
            }

            // Place the subview at its calculated position
            subview.place(at: CGPoint(x: currentX, y: currentY), proposal: .unspecified)

            currentX += subviewSize.width
            lineHeight = max(lineHeight, subviewSize.height)

            if index < subviews.count - 1 {
                currentX += horizontalSpacing
            }
        }
    }
}
