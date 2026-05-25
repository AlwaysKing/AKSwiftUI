//
//  AKSUNSTableView.swift
//  AKSwiftUI
//
//  Created by alwaysking on 2025/5/25.
//

import AppKit
import SwiftUI

// MARK: - Custom NSTableView

/// 自定义 NSTableView 子类，支持鼠标事件回调
class AKSUTableNSTableView: NSTableView {
    var onMouseDown: ((Int, NSPoint) -> Void)?
    var onMouseDragged: ((Int, NSPoint) -> Void)?
    var onMouseUp: (() -> Void)?
    var onRightMouseDown: ((Int, NSPoint, NSEvent) -> Void)?

    override func mouseDown(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        let row = self.row(at: point)
        if row >= 0 {
            onMouseDown?(row, point)
        }
        // 不调用 super，防止 NSTableView 内置选中高亮
        // 但需要手动启动事件跟踪循环以接收 mouseDragged/mouseUp
        let window = self.window
        let mask: NSEvent.EventTypeMask = [.leftMouseDragged, .leftMouseUp]
        var lastRow = row
        while true {
            guard let ev = window?.nextEvent(matching: mask) else { break }
            if ev.type == .leftMouseDragged {
                let p = convert(ev.locationInWindow, from: nil)
                let r = self.row(at: p)
                if r != lastRow {
                    lastRow = r
                    onMouseDragged?(r, p)
                }
            } else if ev.type == .leftMouseUp {
                onMouseUp?()
                break
            }
        }
    }

    override func rightMouseDown(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        let row = self.row(at: point)
        if row >= 0 {
            onRightMouseDown?(row, point, event)
        }
    }
}

// MARK: - Cell

/// 表格行 Cell，支持复用
/// 内部用 NSHostingView 渲染 SwiftUI 内容，自绘选中效果和斑马纹
class AKSUTableViewCell<Value: Identifiable>: NSTableCellView {
    private let hostingView = NSHostingView<AnyView>(rootView: AnyView(EmptyView()))
    private let splitLineView = NSView()

    private var leadingPadding: CGFloat = 0
    private var trailingPadding: CGFloat = 0

    init() {
        super.init(frame: .zero)

        // SwiftUI 内容层（渲染所有视觉效果 + 文字）
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(hostingView)

        // 分割线
        splitLineView.translatesAutoresizingMaskIntoConstraints = false
        splitLineView.isHidden = true
        addSubview(splitLineView)

        NSLayoutConstraint.activate([
            hostingView.topAnchor.constraint(equalTo: topAnchor),
            hostingView.bottomAnchor.constraint(equalTo: bottomAnchor),
            hostingView.leadingAnchor.constraint(equalTo: leadingAnchor),
            hostingView.trailingAnchor.constraint(equalTo: trailingAnchor),

            splitLineView.leadingAnchor.constraint(equalTo: leadingAnchor),
            splitLineView.trailingAnchor.constraint(equalTo: trailingAnchor),
            splitLineView.bottomAnchor.constraint(equalTo: bottomAnchor),
            splitLineView.heightAnchor.constraint(equalToConstant: 1),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(
        row: Int,
        item: AKSUTableRowItem<Value>?,
        columns: [AKSUTableColumnItem<Value>],
        endPadding: CGFloat,
        isSelected: Bool,
        isRightSelected: Bool,
        selectionColor: NSColor,
        selectionFirst: Bool,
        selectionLast: Bool,
        multSelection: Bool,
        scrollBarWidth: CGFloat,
        bgColor: NSColor,
        splitColor: NSColor,
        splitline: Bool,
        splitlineColor: NSColor
    ) {
        leadingPadding = scrollBarWidth + 3
        trailingPadding = 3

        let isLight = row % 2 != 0
        let selColor = Color(nsColor: selectionColor)
        let cornerRadius = AKSUAppearance.cornerRadius

        // 文字内容（背景行传 nil 时不渲染文字）
        let textContent = HStack(spacing: 1) {
            if let item = item {
                ForEach(columns) { header in
                    HStack {
                        header.itemBuilder(item.value).first
                    }
                    .frame(width: header.width)
                    .foregroundColor(isSelected ? .aksuWhite : nil)
                }
            }
            if endPadding > 0 {
                Spacer()
                    .frame(width: endPadding)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)

        // 分层：文字 → 选中背景 → 斑马纹背景
        let content = textContent
            .overlay(alignment: .leading) {
                if isRightSelected {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(isSelected ? .aksuWhite : selColor, lineWidth: 1.5)
                        .padding(.leading, scrollBarWidth + (isSelected ? 6 : 4))
                        .padding(.trailing, isSelected ? 6 : 4)
                        .padding(.vertical, isSelected ? 3 : 2)
                }
            }
            // 选中效果层（用 .background 闭包，和右键边框用 .overlay 一样的原理）
            .background {
                if isSelected {
                    if !multSelection {
                        // 纯单选模式
                        ZStack {
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .fill(selColor)
                                .padding(.leading, scrollBarWidth + 3)
                                .padding(.trailing, 3)
                        }
                    } else if selectionFirst && selectionLast {
                        // 多选模式但只选中了一行（first == last）
                        ZStack {
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .fill(selColor)
                                .padding(.leading, scrollBarWidth + 3)
                                .padding(.trailing, 3)
                        }
                    } else if selectionFirst && !selectionLast {
                        ZStack {
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .fill(selColor)
                                .padding(.leading, scrollBarWidth + 3)
                                .padding(.trailing, 3)
                            VStack {
                                Spacer()
                                Rectangle()
                                    .fill(selColor)
                                    .frame(height: 7)
                                    .padding(.leading, scrollBarWidth + 3)
                                    .padding(.trailing, 3)
                            }
                        }
                    } else if selectionLast && !selectionFirst {
                        ZStack {
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .fill(selColor)
                                .padding(.leading, scrollBarWidth + 3)
                                .padding(.trailing, 3)
                            VStack {
                                Rectangle()
                                    .fill(selColor)
                                    .frame(height: 7)
                                    .padding(.leading, scrollBarWidth + 3)
                                    .padding(.trailing, 3)
                                Spacer()
                            }
                        }
                    } else {
                        Rectangle()
                            .fill(selColor)
                            .padding(.leading, scrollBarWidth + 3)
                            .padding(.trailing, 3)
                    }
                }
            }
            // 斑马纹背景层
            .background {
                VStack(spacing: 0) {
                    if isLight {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(Color(nsColor: splitColor))
                    } else {
                        Rectangle().fill(Color(nsColor: bgColor))
                    }
                    if splitline {
                        Rectangle()
                            .fill(Color(nsColor: splitlineColor))
                            .frame(height: 1)
                    }
                }
                .padding(.leading, scrollBarWidth + 6)
                .padding(.trailing, scrollBarWidth + 2)
            }

        hostingView.rootView = AnyView(content)

        // 分割线：由 SwiftUI 层的 .background 渲染（有 padding），隐藏 NSView 层的全宽 splitLineView
        splitLineView.isHidden = true
    }
}

// MARK: - 选中效果层

/// 自绘选中效果的 NSView
class AKSUTableViewSelectionLayer: NSView {
    private var isSelected = false
    private var isRightSelected = false
    private var selectionColor: NSColor = .clear
    private var selectionFirst = false
    private var selectionLast = false
    private var multSelection = false
    private var leadingPadding: CGFloat = 0
    private var trailingPadding: CGFloat = 0
    private var cornerRadius: CGFloat = 4

    func configure(
        isSelected: Bool,
        isRightSelected: Bool,
        selectionColor: NSColor,
        selectionFirst: Bool,
        selectionLast: Bool,
        multSelection: Bool,
        leadingPadding: CGFloat,
        trailingPadding: CGFloat,
        cornerRadius: CGFloat
    ) {
        self.isSelected = isSelected
        self.isRightSelected = isRightSelected
        self.selectionColor = selectionColor
        self.selectionFirst = selectionFirst
        self.selectionLast = selectionLast
        self.multSelection = multSelection
        self.leadingPadding = leadingPadding
        self.trailingPadding = trailingPadding
        self.cornerRadius = cornerRadius
        needsDisplay = true
    }

    override func draw(_ dirtyRect: NSRect) {
        if isSelected {
            drawSelection()
        }
        if isRightSelected {
            drawRightSelectionBorder()
        }
    }

    private func drawSelection() {
        let rect = NSRect(
            x: leadingPadding,
            y: 0,
            width: bounds.width - leadingPadding - trailingPadding,
            height: bounds.height
        )

        selectionColor.setFill()

        if !multSelection {
            // 单选：四周圆角
            let path = NSBezierPath(roundedRect: rect, xRadius: cornerRadius, yRadius: cornerRadius)
            path.fill()
        } else if selectionFirst && !selectionLast {
            // 多选首行：顶部圆角 + 底部 7px 延伸
            let mainRect = NSRect(x: rect.minX, y: 0, width: rect.width, height: rect.height - 7)
            let bottomRect = NSRect(x: rect.minX, y: 0, width: rect.width, height: 7)

            let path = NSBezierPath(roundedRect: mainRect, xRadius: cornerRadius, yRadius: cornerRadius)
            path.fill()
            bottomRect.fill()
        } else if selectionLast && !selectionFirst {
            // 多选末行：底部圆角 + 顶部 7px 延伸
            let topRect = NSRect(x: rect.minX, y: rect.maxY - 7, width: rect.width, height: 7)
            let mainRect = NSRect(x: rect.minX, y: rect.minY, width: rect.width, height: rect.height)

            topRect.fill()
            let path = NSBezierPath(roundedRect: mainRect, xRadius: cornerRadius, yRadius: cornerRadius)
            path.fill()
        } else {
            // 多选中间行：无圆角
            rect.fill()
        }
    }

    private func drawRightSelectionBorder() {
        let hPad: CGFloat = isSelected ? 6 : 4
        let vPad: CGFloat = isSelected ? 3 : 2
        let borderColor: NSColor = isSelected ? .white : selectionColor

        let rect = NSRect(
            x: leadingPadding + hPad - 4,
            y: vPad - 2,
            width: bounds.width - leadingPadding - trailingPadding - hPad + 8,
            height: bounds.height - (vPad - 2) * 2
        )

        borderColor.setStroke()
        let path = NSBezierPath(roundedRect: rect, xRadius: cornerRadius, yRadius: cornerRadius)
        path.lineWidth = 1.5
        path.stroke()
    }
}

// MARK: - Coordinator

class AKSUNSTableViewCoordinator<Value: Identifiable & Equatable>: NSObject, NSTableViewDataSource, NSTableViewDelegate {
    var parent: AKSUNSTableView<Value>

    init(_ parent: AKSUNSTableView<Value>) {
        self.parent = parent
    }

    // MARK: DataSource

    func numberOfRows(in tableView: NSTableView) -> Int {
        return parent.rowStorage.rows.count + parent.extraBackgroundRows
    }

    // MARK: Delegate

    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return false // 禁用 NSTableView 内置选中，由 SwiftUI 自定义选中效果处理
    }

    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        if row < parent.rowStorage.rows.count {
            return parent.resolveRowHeight(parent.rowStorage.rows[row].value) ?? 25
        }
        // 背景行高度
        return parent.resolveBackgroundRowHeight()
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cellIdentifier = NSUserInterfaceItemIdentifier("AKSUTableViewCell")

        let cell = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? AKSUTableViewCell<Value>
            ?? AKSUTableViewCell<Value>()

        // 将 cell 标记为复用
        cell.identifier = cellIdentifier

        if row < parent.rowStorage.rows.count {
            let item = parent.rowStorage.rows[row]
            let isSelected = parent.rowStorage.isSelected(id: item.value.id)
            let isRightSelected = parent.rowStorage.isRightSelected(id: item.value.id)
            let isSelectionFirst = parent.rowStorage.selectionFirst == item.value.id
            let isSelectionLast = parent.rowStorage.selectionLast == item.value.id

            cell.configure(
                row: row,
                item: item,
                columns: parent.columnStorage.columns,
                endPadding: parent.endPadding,
                isSelected: isSelected,
                isRightSelected: isRightSelected,
                selectionColor: parent.selectionColor.nsColor,
                selectionFirst: isSelectionFirst,
                selectionLast: isSelectionLast,
                multSelection: parent.multSelection,
                scrollBarWidth: parent.scrollBarWidth,
                bgColor: parent.contentBgColor.nsColor,
                splitColor: parent.splitColor.nsColor,
                splitline: parent.splitline,
                splitlineColor: parent.splitlineColor.nsColor
            )
        } else {
            // 背景行
            let bgIndex = row - parent.rowStorage.rows.count
            let isLight = (parent.backgroundColorIndex + bgIndex) % 2 != 0

            let emptyItem: AKSUTableRowItem<Value>? = nil

            cell.configure(
                row: row,
                item: emptyItem,
                columns: parent.columnStorage.columns,
                endPadding: parent.endPadding,
                isSelected: false,
                isRightSelected: false,
                selectionColor: .clear,
                selectionFirst: false,
                selectionLast: false,
                multSelection: false,
                scrollBarWidth: parent.scrollBarWidth,
                bgColor: isLight ? parent.splitColor.nsColor : parent.contentBgColor.nsColor,
                splitColor: parent.splitColor.nsColor,
                splitline: parent.splitline,
                splitlineColor: parent.splitlineColor.nsColor
            )
        }

        return cell
    }

    func tableView(_ tableView: NSTableView, didClick tableColumn: NSTableColumn) {
        // 列头点击（暂不处理）
    }

    // 右键由 AKSUTableNSTableView 的回调处理，不再使用 delegate 方法
}

// MARK: - AKSUTableView (NSViewRepresentable)

struct AKSUNSTableView<Value: Identifiable & Equatable>: NSViewRepresentable {
    @Binding var data: [Value]
    let columnStorage: AKSUTableColumnStorage<Value>
    let rowStorage: AKSUTableRowStorage<Value>

    let endPadding: CGFloat
    let scrollBarWidth: CGFloat
    let backgroundColorIndex: Int
    let headerBgColor: Color
    let contentBgColor: Color
    let selectionColor: Color
    let splitColor: Color
    let splitlineColor: Color
    let splitline: Bool
    let multSelection: Bool
    let selection: (([Value]) -> Void)?
    let rightClick: ((Value, String, NSEvent?) -> Void)?
    let defaultRowHeight: CGFloat?
    let getRowHeight: ((Value?) -> CGFloat?)?

    // 刷新标记：当 selection 等状态变化时，外部 toggle 此值强制 updateNSView 调用
    var refreshId: Bool = false

    // 回调
    var onScrollChanged: ((CGFloat, CGFloat) -> Void)?
    var onVisibleSizeChanged: ((CGSize) -> Void)?

    // 背景行数量（由外部计算传入）
    var extraBackgroundRows: Int = 0

    // 鼠标事件回调
    var onMouseDown: ((Int, NSPoint) -> Void)?
    var onMouseDragged: ((Int, NSPoint) -> Void)?
    var onMouseUp: (() -> Void)?
    var onRightClick: ((Int, NSPoint, NSEvent) -> Void)?

    func makeCoordinator() -> AKSUNSTableViewCoordinator<Value> {
        AKSUNSTableViewCoordinator(self)
    }

    func makeNSView(context: Context) -> NSView {
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = false
        scrollView.hasHorizontalScroller = false
        scrollView.borderType = .noBorder

        let tableView = AKSUTableNSTableView()
        tableView.style = .plain
        tableView.rowSizeStyle = .custom
        tableView.usesAlternatingRowBackgroundColors = false
        tableView.headerView = nil
        tableView.backgroundColor = contentBgColor.nsColor
        tableView.selectionHighlightStyle = .none
        tableView.dataSource = context.coordinator
        tableView.delegate = context.coordinator
        tableView.columnAutoresizingStyle = .noColumnAutoresizing
        tableView.usesAutomaticRowHeights = false
        tableView.intercellSpacing = NSSize(width: 0, height: 0)

        // 鼠标事件回调
        tableView.onMouseDown = { [weak coordinator = context.coordinator] row, point in
            coordinator?.parent.onMouseDown?(row, point)
        }
        tableView.onMouseDragged = { [weak coordinator = context.coordinator] row, point in
            coordinator?.parent.onMouseDragged?(row, point)
        }
        tableView.onMouseUp = { [weak coordinator = context.coordinator] in
            coordinator?.parent.onMouseUp?()
        }
        tableView.onRightMouseDown = { [weak coordinator = context.coordinator] row, point, event in
            coordinator?.parent.onRightClick?(row, point, event)
        }

        // 只用一个 NSTableColumn 横跨整行，cell 内部用 HStack 渲染所有 SwiftUI 列
        let totalWidth = calculateTotalContentWidth()
        let singleColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("AKSUTableSingleColumn"))
        singleColumn.width = totalWidth
        singleColumn.resizingMask = .autoresizingMask
        tableView.addTableColumn(singleColumn)

        scrollView.documentView = tableView

        context.coordinator.parent = self

        // 添加自定义滚动条
        let wrapper = NSView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        wrapper.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: wrapper.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor),
        ])

        // 垂直滚动条
        let vBar = AKSUTableScrollBar(orientation: .vertical)
        vBar.translatesAutoresizingMaskIntoConstraints = false
        wrapper.addSubview(vBar)
        NSLayoutConstraint.activate([
            vBar.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor),
            vBar.topAnchor.constraint(equalTo: wrapper.topAnchor),
            vBar.widthAnchor.constraint(equalToConstant: 6),
            vBar.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor),
        ])
        scrollView.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor, constant: -6).isActive = true

        // 水平滚动条
        let hBar = AKSUTableScrollBar(orientation: .horizontal)
        hBar.translatesAutoresizingMaskIntoConstraints = false
        wrapper.addSubview(hBar)
        NSLayoutConstraint.activate([
            hBar.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor),
            hBar.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor),
            hBar.heightAnchor.constraint(equalToConstant: 6),
            hBar.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor),
        ])
        scrollView.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor, constant: -6).isActive = true

        // 滚动条拖拽
        vBar.onDrag = { [weak scrollView] ratio in
            guard let sv = scrollView else { return }
            let clipH = sv.contentView.bounds.height
            let docH = sv.documentView?.frame.height ?? 0
            let maxScroll = docH - clipH
            sv.contentView.scroll(to: CGPoint(x: sv.contentView.bounds.origin.x, y: ratio * maxScroll))
            sv.reflectScrolledClipView(sv.contentView)
        }
        hBar.onDrag = { [weak scrollView] ratio in
            guard let sv = scrollView else { return }
            let clipW = sv.contentView.bounds.width
            let docW = sv.documentView?.frame.width ?? 0
            let maxScroll = docW - clipW
            sv.contentView.scroll(to: CGPoint(x: ratio * maxScroll, y: sv.contentView.bounds.origin.y))
            sv.reflectScrolledClipView(sv.contentView)
        }

        // 滚动追踪（在 vBar/hBar 之后创建，以便捕获引用）
        scrollView.contentView.postsBoundsChangedNotifications = true
        let observer = NotificationCenter.default.addObserver(
            forName: NSView.boundsDidChangeNotification,
            object: scrollView.contentView,
            queue: nil
        ) { [weak coordinator = context.coordinator, weak vBar, weak hBar, weak scrollView] notification in
            guard let clipView = notification.object as? NSClipView else { return }
            let bounds = clipView.bounds
            let docFrame = scrollView?.documentView?.frame ?? .zero

            // 实时更新垂直滚动条位置
            if let vBar = vBar {
                let visibleH = bounds.height
                let contentH = docFrame.height
                if contentH > 0 {
                    vBar.knobRatio = visibleH / contentH
                    let maxScrollY = contentH - visibleH
                    vBar.scrollRatio = maxScrollY > 0 ? min(max(bounds.origin.y / maxScrollY, 0), 1) : 0
                }
                vBar.needsDisplay = true
            }

            // 实时更新水平滚动条位置
            if let hBar = hBar {
                let visibleW = bounds.width
                let contentW = docFrame.width
                if contentW > 0 {
                    hBar.knobRatio = visibleW / contentW
                    let maxScrollX = contentW - visibleW
                    hBar.scrollRatio = maxScrollX > 0 ? min(max(bounds.origin.x / maxScrollX, 0), 1) : 0
                }
                hBar.needsDisplay = true
            }

            // 通知 SwiftUI 层同步 header
            DispatchQueue.main.async {
                coordinator?.parent.onScrollChanged?(bounds.origin.y, bounds.origin.x)
                coordinator?.parent.onVisibleSizeChanged?(bounds.size)
            }
        }

        // 存储引用
        objc_setAssociatedObject(wrapper, &_aksvScrollViewKey, scrollView, .OBJC_ASSOCIATION_RETAIN)
        objc_setAssociatedObject(wrapper, &_aksvTableViewKey, tableView, .OBJC_ASSOCIATION_RETAIN)
        objc_setAssociatedObject(wrapper, &_aksvVBarKey, vBar, .OBJC_ASSOCIATION_RETAIN)
        objc_setAssociatedObject(wrapper, &_aksvHBarKey, hBar, .OBJC_ASSOCIATION_RETAIN)
        objc_setAssociatedObject(wrapper, &_aksvScrollObserverKey, observer, .OBJC_ASSOCIATION_RETAIN)

        return wrapper
    }

    func updateNSView(_ wrapper: NSView, context: Context) {
        guard let scrollView = objc_getAssociatedObject(wrapper, &_aksvScrollViewKey) as? NSScrollView,
              let tableView = objc_getAssociatedObject(wrapper, &_aksvTableViewKey) as? AKSUTableNSTableView,
              let vBar = objc_getAssociatedObject(wrapper, &_aksvVBarKey) as? AKSUTableScrollBar,
              let hBar = objc_getAssociatedObject(wrapper, &_aksvHBarKey) as? AKSUTableScrollBar
        else { return }

        context.coordinator.parent = self

        // 同步单列宽度：endPadding >= 0 表示内容不需要水平滚动，精确填满可见区域
        let totalWidth = calculateTotalContentWidth()
        let clipWidth = scrollView.contentView.bounds.width
        let columnWidth: CGFloat
        if endPadding >= 0 {
            // 内容能放下，精确填满可见区域（clipWidth 为 0 时用 totalWidth 回退）
            columnWidth = clipWidth > 0 ? clipWidth : totalWidth
        } else {
            // 列被拖宽导致内容超出，允许水平滚动
            columnWidth = totalWidth
        }
        if tableView.tableColumns.count > 0 {
            let tc = tableView.tableColumns[0]
            if abs(tc.width - columnWidth) > 0.5 {
                tc.width = columnWidth
            }
        }

        // 刷新数据
        tableView.reloadData()

        // 更新滚动条
        let clipBounds = scrollView.contentView.bounds
        let docFrame = tableView.frame

        let visibleH = clipBounds.height
        let contentH = docFrame.height
        if contentH > 0 {
            vBar.knobRatio = visibleH / contentH
            let maxScrollY = contentH - visibleH
            vBar.scrollRatio = maxScrollY > 0 ? min(max(clipBounds.origin.y / maxScrollY, 0), 1) : 0
        }
        vBar.needsDisplay = true

        let visibleW = clipBounds.width
        let contentW = docFrame.width
        if contentW > 0 {
            hBar.knobRatio = visibleW / contentW
            let maxScrollX = contentW - visibleW
            hBar.scrollRatio = maxScrollX > 0 ? min(max(clipBounds.origin.x / maxScrollX, 0), 1) : 0
        }
        hBar.needsDisplay = true
    }

    func resolveRowHeight(_ value: Value?) -> CGFloat? {
        if let getRowHeight = getRowHeight {
            return getRowHeight(value)
        }
        return defaultRowHeight
    }

    func resolveBackgroundRowHeight() -> CGFloat {
        return resolveRowHeight(nil) ?? 25
    }

    /// 计算所有 SwiftUI 列的总宽度（含间距 + endPadding）
    private func calculateTotalContentWidth() -> CGFloat {
        var totalWidth: CGFloat = 0
        for col in columnStorage.columns {
            totalWidth += col.width
        }
        totalWidth += CGFloat(max(columnStorage.columns.count - 1, 0)) // spacing
        totalWidth += max(endPadding, 0)
        return totalWidth
    }
}

// MARK: - Color → NSColor

extension Color {
    var nsColor: NSColor {
        NSColor(self)
    }
}

// MARK: - Associated Object Keys (non-generic)

private var _aksvScrollViewKey: UInt8 = 0
private var _aksvTableViewKey: UInt8 = 0
private var _aksvVBarKey: UInt8 = 0
private var _aksvHBarKey: UInt8 = 0
private var _aksvScrollObserverKey: UInt8 = 0
