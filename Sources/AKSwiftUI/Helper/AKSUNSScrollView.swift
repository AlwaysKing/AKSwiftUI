//
//  AKSUNSScrollView.swift
//  AKSwiftUI
//
//  Created by alwaysking on 2025/5/23.
//

import AppKit
import SwiftUI

/// 自定义滚动条 NSView，绘制在固定的 6px 空间内
class AKSUTableScrollBar: NSView {
    enum Orientation {
        case vertical
        case horizontal
    }

    let orientation: Orientation
    var knobRatio: CGFloat = 0
    var scrollRatio: CGFloat = 0
    var onDrag: ((CGFloat) -> Void)?

    private var isDragging = false
    private var isHovering = false
    private var dragStartPoint: CGPoint = .zero
    private var dragStartRatio: CGFloat = 0

    /// 当前 knob 颜色：hover/拖拽 时实心，否则半透明
    private var knobColor: NSColor {
        if isDragging || isHovering {
            return NSColor.systemGray.withAlphaComponent(0.8)
        } else {
            return NSColor.systemGray.withAlphaComponent(0.3)
        }
    }

    init(orientation: Orientation) {
        self.orientation = orientation
        super.init(frame: .zero)

        // 开启 tracking area 以接收 mouseEntered/mouseExited
        updateTrackingAreas()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ dirtyRect: NSRect) {
        guard knobRatio > 0, knobRatio < 1.0 else { return }

        let color = knobColor

        switch orientation {
        case .vertical:
            let trackLength = bounds.height
            let knobLength = max(knobRatio * trackLength, 20)
            let knobOffset = (1.0 - scrollRatio) * (trackLength - knobLength)
            let drawRect = NSRect(x: (bounds.width - 4) / 2, y: knobOffset + 1, width: 4, height: knobLength - 2)
            color.setFill()
            NSBezierPath(roundedRect: drawRect, xRadius: 2, yRadius: 2).fill()

        case .horizontal:
            let trackLength = bounds.width
            let knobLength = max(knobRatio * trackLength, 20)
            let knobOffset = scrollRatio * (trackLength - knobLength)
            let drawRect = NSRect(x: knobOffset + 1, y: (bounds.height - 4) / 2, width: knobLength - 2, height: 4)
            color.setFill()
            NSBezierPath(roundedRect: drawRect, xRadius: 2, yRadius: 2).fill()
        }
    }

    // MARK: - Hover 检测

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        // 移除旧的
        for area in trackingAreas {
            removeTrackingArea(area)
        }
        // 添加新的
        let options: NSTrackingArea.Options = [.mouseEnteredAndExited, .activeAlways, .inVisibleRect]
        let area = NSTrackingArea(rect: bounds, options: options, owner: self, userInfo: nil)
        addTrackingArea(area)
    }

    override func mouseEntered(with event: NSEvent) {
        isHovering = true
        needsDisplay = true
    }

    override func mouseExited(with event: NSEvent) {
        isHovering = false
        needsDisplay = true
    }

    // MARK: - 拖拽

    override func mouseDown(with event: NSEvent) {
        guard knobRatio > 0, knobRatio < 1.0 else { return }
        isDragging = true
        needsDisplay = true
        dragStartPoint = convert(event.locationInWindow, from: nil)
        dragStartRatio = scrollRatio
    }

    override func mouseDragged(with event: NSEvent) {
        guard isDragging else { return }
        let currentPoint = convert(event.locationInWindow, from: nil)
        let trackLength: CGFloat
        let knobLength: CGFloat
        let delta: CGFloat

        switch orientation {
        case .vertical:
            trackLength = bounds.height
            knobLength = max(knobRatio * trackLength, 20)
            delta = dragStartPoint.y - currentPoint.y
        case .horizontal:
            trackLength = bounds.width
            knobLength = max(knobRatio * trackLength, 20)
            delta = currentPoint.x - dragStartPoint.x
        }

        let maxTravel = trackLength - knobLength
        guard maxTravel > 0 else { return }
        let newRatio = min(max(dragStartRatio + delta / maxTravel, 0), 1)
        onDrag?(newRatio)
    }

    override func mouseUp(with event: NSEvent) {
        isDragging = false
        needsDisplay = true
    }
}

/// NSScrollView 封装 + 自定义滚动条
/// showsScrollBars = false 时直接返回 NSScrollView（用于 header，保持正确的 intrinsicContentSize）
/// showsScrollBars = true 时用 wrapper NSView 包住 NSScrollView + 滚动条（用于 content）
struct AKSUNSScrollView<Content: View>: NSViewRepresentable {
    /// 内部使用的滚动条宽度（实际布局值）
    private let _barWidth: CGFloat = 6

    let axes: Axis.Set
    @Binding var scrollPosition: CGPoint
    @Binding var contentSize: CGSize
    @Binding var visibleSize: CGSize
    @Binding var scrollBarWidth: CGFloat
    var showsScrollBars: Bool = true
    var onScrollChanged: ((CGFloat, CGFloat) -> Void)?
    let content: () -> Content

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> NSView {
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = false
        scrollView.hasHorizontalScroller = false
        scrollView.borderType = .noBorder

        // 将滚动条宽度同步给外部
        DispatchQueue.main.async {
            self.scrollBarWidth = self._barWidth
        }

        // NSHostingView — 手动管理 frame
        let hostingView = NSHostingView(rootView: content())
        hostingView.translatesAutoresizingMaskIntoConstraints = true
        scrollView.documentView = hostingView

        // 滚动追踪
        scrollView.contentView.postsBoundsChangedNotifications = true
        let scrollObserver = NotificationCenter.default.addObserver(
            forName: NSView.boundsDidChangeNotification,
            object: scrollView.contentView,
            queue: nil
        ) { [weak coordinator = context.coordinator] notification in
            guard let coordinator, !coordinator.isUpdating else { return }
            guard let clipView = notification.object as? NSClipView else { return }
            let bounds = clipView.bounds
            coordinator.updateBars()
            let offsetY = bounds.origin.y
            let offsetX = bounds.origin.x
            DispatchQueue.main.async {
                coordinator.onScrollChanged?(offsetY, offsetX)
            }
        }
        context.coordinator.scrollObserver = scrollObserver
        context.coordinator.scrollView = scrollView

        if !showsScrollBars {
            // Header 等场景：直接返回 NSScrollView，保持正确的 intrinsicContentSize
            return scrollView
        }

        // Content 场景：wrapper 包住 NSScrollView + 滚动条
        let wrapper = NSView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        wrapper.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: wrapper.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor),
        ])

        // 垂直滚动条
        if axes.contains(.vertical) {
            let vBar = AKSUTableScrollBar(orientation: .vertical)
            vBar.translatesAutoresizingMaskIntoConstraints = false
            wrapper.addSubview(vBar)
            NSLayoutConstraint.activate([
                vBar.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor),
                vBar.topAnchor.constraint(equalTo: wrapper.topAnchor),
                vBar.widthAnchor.constraint(equalToConstant: _barWidth),
                vBar.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor),
            ])
            scrollView.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor, constant: -_barWidth).isActive = true

            vBar.onDrag = { [weak scrollView] ratio in
                guard let sv = scrollView else { return }
                let clipH = sv.contentView.bounds.height
                let docH = sv.documentView?.frame.height ?? 0
                let maxScroll = docH - clipH
                sv.contentView.scroll(to: CGPoint(x: sv.contentView.bounds.origin.x, y: ratio * maxScroll))
                sv.reflectScrolledClipView(sv.contentView)
            }
            context.coordinator.verticalBar = vBar
        } else {
            scrollView.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor).isActive = true
        }

        // 水平滚动条
        if axes.contains(.horizontal) {
            let hBar = AKSUTableScrollBar(orientation: .horizontal)
            hBar.translatesAutoresizingMaskIntoConstraints = false
            wrapper.addSubview(hBar)
            NSLayoutConstraint.activate([
                hBar.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor),
                hBar.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor),
                hBar.heightAnchor.constraint(equalToConstant: _barWidth),
                hBar.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor),
            ])
            scrollView.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor, constant: -_barWidth).isActive = true

            hBar.onDrag = { [weak scrollView] ratio in
                guard let sv = scrollView else { return }
                let clipW = sv.contentView.bounds.width
                let docW = sv.documentView?.frame.width ?? 0
                let maxScroll = docW - clipW
                sv.contentView.scroll(to: CGPoint(x: ratio * maxScroll, y: sv.contentView.bounds.origin.y))
                sv.reflectScrolledClipView(sv.contentView)
            }
            context.coordinator.horizontalBar = hBar
        } else {
            scrollView.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor).isActive = true
        }

        return wrapper
    }

    func updateNSView(_ view: NSView, context: Context) {
        let scrollView: NSScrollView
        if let sv = view as? NSScrollView {
            scrollView = sv
        } else {
            guard let sv = view.subviews.first(where: { $0 is NSScrollView }) as? NSScrollView else { return }
            scrollView = sv
        }
        context.coordinator.scrollView = scrollView

        guard let hostingView = scrollView.documentView as? NSHostingView<Content> else { return }

        hostingView.rootView = content()
        hostingView.invalidateIntrinsicContentSize()
        hostingView.layoutSubtreeIfNeeded()

        // 手动设置 hostingView frame
        let clipSize = scrollView.contentView.bounds.size
        let fittingSize = hostingView.fittingSize
        // 宽度容差 2px：SwiftUI 布局引擎浮点舍入可能导致 fittingSize 比 clipSize 大 1px，
        // 这不是真正的水平溢出，不应触发水平滚动条
        let contentW = (fittingSize.width > clipSize.width && fittingSize.width - clipSize.width <= 2.0) ? clipSize.width : fittingSize.width
        let contentH = (fittingSize.height > clipSize.height && fittingSize.height - clipSize.height <= 2.0) ? clipSize.height : fittingSize.height
        hostingView.frame = NSRect(
            x: 0, y: 0,
            width: max(clipSize.width, contentW),
            height: max(clipSize.height, contentH)
        )

        context.coordinator.isUpdating = true
        scrollView.layoutSubtreeIfNeeded()
        DispatchQueue.main.async { [weak coordinator = context.coordinator] in
            coordinator?.isUpdating = false
        }

        let docSize = hostingView.frame.size
        let visSize = scrollView.contentView.bounds.size

        DispatchQueue.main.async {
            self.contentSize = docSize
            self.visibleSize = visSize
        }

        let currentOrigin = scrollView.contentView.bounds.origin
        if abs(scrollPosition.x - currentOrigin.x) > 0.5 || abs(scrollPosition.y - currentOrigin.y) > 0.5 {
            scrollView.contentView.scroll(to: scrollPosition)
            scrollView.reflectScrolledClipView(scrollView.contentView)
        }

        context.coordinator.updateBars()
        context.coordinator.onScrollChanged = onScrollChanged
    }

    class Coordinator: NSObject {
        var onScrollChanged: ((CGFloat, CGFloat) -> Void)?
        var scrollObserver: NSObjectProtocol?
        weak var scrollView: NSScrollView?
        weak var verticalBar: AKSUTableScrollBar?
        weak var horizontalBar: AKSUTableScrollBar?
        var isUpdating = false

        func updateBars() {
            guard let scrollView else { return }
            let clipBounds = scrollView.contentView.bounds
            let docFrame = scrollView.documentView?.frame ?? .zero

            if let vBar = verticalBar {
                let visibleH = clipBounds.height
                let contentH = docFrame.height
                if contentH > 0 {
                    vBar.knobRatio = visibleH / contentH
                    let maxScrollY = contentH - visibleH
                    vBar.scrollRatio = maxScrollY > 0 ? min(max(clipBounds.origin.y / maxScrollY, 0), 1) : 0
                }
                vBar.needsDisplay = true
            }

            if let hBar = horizontalBar {
                let visibleW = clipBounds.width
                let contentW = docFrame.width
                if contentW > 0 {
                    hBar.knobRatio = visibleW / contentW
                    let maxScrollX = contentW - visibleW
                    hBar.scrollRatio = maxScrollX > 0 ? min(max(clipBounds.origin.x / maxScrollX, 0), 1) : 0
                }
                hBar.needsDisplay = true
            }
        }

        deinit {
            if let observer = scrollObserver {
                NotificationCenter.default.removeObserver(observer)
            }
        }
    }
}
