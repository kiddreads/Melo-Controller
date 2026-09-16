//
//  ControllerBounds.swift
//  Melo-Controller
//
//  Tracks the play area so on-screen controls can be kept fully visible
//  when they are moved or resized (see On-ScreenControllerScale).
//

import SwiftUI

let controllerCoordinateSpace = "MeloControllerSpace"

final class ControllerBoundsModel: ObservableObject {
    @Published var containerSize: CGSize = .zero
}

/// Nudges `offset` (in place) so that `frame` stays fully inside `containerSize`.
/// Returns `true` if a correction was applied.
@discardableResult
func clampOffsetToContainer(frame: CGRect, containerSize: CGSize, offset: inout CGSize) -> Bool {
    guard containerSize.width > 0, containerSize.height > 0, frame != .zero else { return false }

    var dx: CGFloat = 0
    var dy: CGFloat = 0

    if frame.width >= containerSize.width {
        dx = (containerSize.width / 2) - frame.midX
    } else if frame.minX < 0 {
        dx = -frame.minX
    } else if frame.maxX > containerSize.width {
        dx = containerSize.width - frame.maxX
    }

    if frame.height >= containerSize.height {
        dy = (containerSize.height / 2) - frame.midY
    } else if frame.minY < 0 {
        dy = -frame.minY
    } else if frame.maxY > containerSize.height {
        dy = containerSize.height - frame.maxY
    }

    guard dx != 0 || dy != 0 else { return false }

    offset.width += dx
    offset.height += dy
    return true
}
