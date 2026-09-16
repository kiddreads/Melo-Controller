//
//  JoystickView.swift
//  Melo-Controller
//
//  Created by Stossy11 on 26/1/2026.
//

import SwiftUI

struct EditableJoystickView: View {
    let id: String
    let iscool: Bool
    var controller: any Controller
    @Binding var showBackground: Bool
    @Binding var layout: LayoutConfig
    var isEditing: Bool
    @Binding var selectedJoystick: String?
    @Binding var selectedButton: String?
    @GestureState private var dragOffset = CGSize.zero
    @AppStorage("On-ScreenControllerScale") var controllerScale: Double = 1.0
    @EnvironmentObject private var controllerBounds: ControllerBoundsModel
    @State private var currentFrame: CGRect = .zero
    @State private var isDragging = false

    private func trackFrame() -> some View {
        GeometryReader { proxy in
            Color.clear
                .onAppear { currentFrame = proxy.frame(in: .named(controllerCoordinateSpace)) }
                .onChange(of: proxy.frame(in: .named(controllerCoordinateSpace))) { newFrame in
                    currentFrame = newFrame
                    guard !isDragging else { return }
                    var offset = layout.joysticks[id]?.offset ?? .zero
                    if clampOffsetToContainer(frame: newFrame, containerSize: controllerBounds.containerSize, offset: &offset) {
                        layout.joysticks[id, default: JoystickLayout()].offset = offset
                    }
                }
        }
    }

    var body: some View {
        if isEditing {
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 160, height: 160)
                .overlay(
                    Text("Joystick")
                        .font(.caption)
                        .foregroundColor(.white)
                )
                .scaleEffect((layout.joysticks[id]?.scale ?? 1.0) * controllerScale)
                .border(selectedJoystick == id ? Color.green : Color.clear, width: 3)
                .offset(
                    x: (layout.joysticks[id]?.offset.width ?? 0) + dragOffset.width,
                    y: (layout.joysticks[id]?.offset.height ?? 0) + dragOffset.height
                )
                .background(trackFrame())
                .onTapGesture {
                    selectedJoystick = selectedJoystick == id ? nil : id
                    selectedButton = nil
                }
                .gesture(
                    DragGesture()
                        .updating($dragOffset) { value, state, _ in
                            state = value.translation
                            isDragging = true
                            selectedJoystick = id
                            selectedButton = nil
                        }
                        .onEnded { value in
                            var offset = layout.joysticks[id]?.offset ?? .zero
                            offset.width += value.translation.width
                            offset.height += value.translation.height
                            let draggedFrame = currentFrame.offsetBy(dx: value.translation.width, dy: value.translation.height)
                            clampOffsetToContainer(frame: draggedFrame, containerSize: controllerBounds.containerSize, offset: &offset)
                            layout.joysticks[id, default: JoystickLayout()].offset = offset
                            isDragging = false
                        }
                )
        } else {
            JoystickViewRepresentable(controller: controller, right: iscool, showBackground: $showBackground)
                .frame(width: 160, height: 160)
                .scaleEffect(layout.joysticks[id]?.scale ?? CGFloat(controllerScale))
                .offset(layout.joysticks[id]?.offset ?? .zero)
                .background(trackFrame())
        }
    }
}

