//
//  AKSUTable.swift
//  AKSwiftUI
//
//  基于 NSTableView 的高性能表格组件
//

import SwiftUI

public struct AKSUTable<Value: Identifiable & Equatable>: View {
    @Binding var data: [Value]
    @State var _initColumns: [AKSUTableColumnItem<Value>]

    @StateObject var columnStorage = AKSUTableColumnStorage<Value>()
    @StateObject var rowStorage = AKSUTableRowStorage<Value>()

    @State var tableSize: CGSize = CGSize.zero
    @State var titleSize: CGSize = CGSize.zero
    @State var endPinding: CGFloat = 0.0

    @State var refreshUI: Bool = false

    @State private var scrollOffsetX: CGFloat = 0.0
    @State private var scrollBarWidth: CGFloat = 0
    @State private var contentVisibleSize: CGSize = .zero
    @State private var measuredDataHeight: CGFloat = 0.0

    // 选择
    @State private var selectionStartRow: Int? = nil
    @State private var isDraggingSelection = false

    let headerBgColor: Color
    let contentBgColor: Color
    let selectionColor: Color
    let splitColor: Color
    let splitlineColor: Color
    let headerSplitColor: Color
    let headerDividerColor: Color

    let splitline: Bool
    let multSelection: Bool
    let realtimeSelection: Bool
    let selection: (([Value]) -> Void)?
    let rightClick: ((Value, String, NSEvent?) -> Void)?
    let defaultRowHeight: CGFloat?
    let getRowHeight: ((Value?) -> CGFloat?)?

    public init(data: Binding<[Value]>, defaultRowHeight: CGFloat? = nil, headerBgColor: Color = .aksuTextBackground, headerSplitColor: Color = .aksuDivider, headerDividerColor: Color = .aksuDivider, contentBgColor: Color = .aksuTextBackground, selectionColor: Color = .aksuPrimary, splitColor: Color = .aksuGrayMask, splitline: Bool = false, splitlineColor: Color = .aksuGrayMask, multSelection: Bool = false, realtimeSelection: Bool = false, @AKSUTableColumnBuilder<Value> columns: () -> [AKSUTableColumn<Value>], selection: (([Value]) -> Void)? = nil, rightClick: ((Value, String, NSEvent?) -> Void)? = nil, getRowHeight: ((Value?) -> CGFloat?)? = nil) {
        self._data = data
        self._initColumns = columns().map { AKSUTableColumnItem(builder: $0) }
        self.headerBgColor = headerBgColor
        self.contentBgColor = contentBgColor
        self.selection = selection
        self.rightClick = rightClick
        self.multSelection = multSelection
        self.realtimeSelection = realtimeSelection
        self.selectionColor = selectionColor
        self.defaultRowHeight = defaultRowHeight
        self.getRowHeight = getRowHeight
        self.splitColor = splitColor
        self.splitline = splitline
        self.splitlineColor = splitlineColor
        self.headerSplitColor = headerSplitColor
        self.headerDividerColor = headerDividerColor
    }

    public var body: some View {
        // 为了主动刷新界面
        if refreshUI || !refreshUI {}
        VStack(spacing: 0) {
            // header
            VStack(spacing: 0) {
                ScrollView([.horizontal], showsIndicators: false) {
                    HStack(spacing: 0) {
                        ForEach(columnStorage.columns) { header in
                            HStack {
                                header.headerBuilder().first
                            }
                            .frame(width: header.width)

                            ZStack {}
                                .frame(width: 8, height: max(titleSize.height - 10, 10))
                                .background(headerSplitColor)
                                .padding(.horizontal, -3.5)
                                .padding(.vertical, 4)
                                .mask {
                                    Rectangle().frame(width: 1)
                                }
                                .onHover { isHovering in
                                    if isHovering {
                                        NSCursor.resizeLeftRight.push()
                                    } else {
                                        NSCursor.pop()
                                    }
                                }
                                .gesture(DragGesture().onChanged { value in
                                    var newWidth = header.width + value.location.x
                                    if let max = header.maxWidth {
                                        newWidth = min(newWidth, max)
                                    }
                                    newWidth = max(newWidth, header.minWidth)
                                    if newWidth != header.width {
                                        endPinding += (header.width - newWidth)
                                        header.width = newWidth
                                        refreshUI.toggle()
                                    }
                                })
                        }

                        if endPinding > 0 {
                            ZStack {}
                                .frame(width: endPinding, height: 1)
                        }
                    }
                    .offset(x: data.count == 0 ? 0 : scrollOffsetX)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.trailing, scrollBarWidth)
                .background(headerBgColor)

                ZStack {}
                    .frame(maxWidth: .infinity)
                    .frame(height: 1)
                    .background(headerDividerColor)
            }
            .background {
                GeometryReader { geometry in
                    Color.clear.onAppear {
                        titleSize = geometry.size
                    }.onChange(of: geometry.size) { _ in
                        titleSize = geometry.size
                    }
                }
            }

            // Content — NSTableView 渲染
            AKSUNSTableView(
                data: $data,
                columnStorage: columnStorage,
                rowStorage: rowStorage,
                endPadding: endPinding,
                scrollBarWidth: scrollBarWidth,
                backgroundColorIndex: rowStorage.rows.count,
                headerBgColor: headerBgColor,
                contentBgColor: contentBgColor,
                selectionColor: selectionColor,
                splitColor: splitColor,
                splitlineColor: splitlineColor,
                splitline: splitline,
                multSelection: multSelection,
                selection: nil,
                rightClick: nil,
                defaultRowHeight: defaultRowHeight,
                getRowHeight: getRowHeight,
                refreshId: refreshUI,
                onScrollChanged: { offsetY, offsetX in
                    scrollOffsetX = -offsetX
                },
                onVisibleSizeChanged: { size in
                    contentVisibleSize = size
                },
                extraBackgroundRows: calculateExtraBackgroundRows(),
                onMouseDown: { row, _ in
                    handleMouseDown(row: row)
                },
                onMouseDragged: { row, _ in
                    handleMouseDragged(row: row)
                },
                onMouseUp: {
                    handleMouseUp()
                },
                onRightClick: { row, point, event in
                    handleRightClick(row: row, point: point, event: event)
                }
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .background(contentBgColor)
        }
        .onChange(of: data) { _ in
            // 按 id 查找已有行，复用 RowItem（保留选中状态）
            var existingRows: [Value.ID: AKSUTableRowItem<Value>] = [:]
            for row in rowStorage.rows {
                existingRows[row.value.id] = row
            }

            var tmp = [AKSUTableRowItem<Value>]()
            for item in data {
                if let existing = existingRows[item.id] {
                    existing.value = item
                    tmp.append(existing)
                    existingRows.removeValue(forKey: item.id)
                } else {
                    tmp.append(AKSUTableRowItem(value: item, selected: false, rightSelected: false))
                }
            }
            let deletedIds = Set(existingRows.keys)
            rowStorage.rows = tmp

            if !deletedIds.isEmpty {
                rowStorage.removeDeleted(deletedIds)
            }
        }
        .onChange(of: scrollBarWidth) { _ in
            if scrollBarWidth > 0 {
                initWidth()
                refreshUI.toggle()
            }
        }
        .overlay {
            GeometryReader { geometry in
                Color.clear.onAppear {
                    tableSize = geometry.size
                    refreshUI.toggle()
                }
                .onChange(of: geometry.size) { _ in
                    tableSize = geometry.size
                    updateWidth()
                    refreshUI.toggle()
                }
            }
        }
        .onAppear {
            scrollBarWidth = 6
            self.columnStorage.reset(_initColumns)
            initWidth()
        }
        .clipped()
    }

    // MARK: - Selection Handling

    private func handleMouseDown(row: Int) {
        guard row < rowStorage.rows.count else { return }

        rowStorage.clearAllSelected()

        if multSelection {
            selectionStartRow = row
            isDraggingSelection = true
            let item = rowStorage.rows[row]
            rowStorage.selected(index: row, selected: true)
            if realtimeSelection {
                selection?([item.value])
            }
        } else {
            let item = rowStorage.rows[row]
            rowStorage.selected(index: row, selected: true)
            selection?([item.value])
        }
        refreshUI.toggle()
    }

    private func handleMouseDragged(row: Int) {
        guard isDraggingSelection, let startRow = selectionStartRow else { return }
        guard row >= 0 && row < rowStorage.rows.count else { return }

        rowStorage.clearAllSelected()

        let from = min(startRow, row)
        let to = max(startRow, row)

        var selected = [Value]()
        for i in from ... to {
            rowStorage.selected(index: i, selected: true)
            selected.append(rowStorage.rows[i].value)
        }

        if realtimeSelection {
            selection?(selected)
        }
        refreshUI.toggle()
    }

    private func handleMouseUp() {
        if !realtimeSelection && isDraggingSelection {
            // 非实时模式：放开鼠标时触发一次回调
            let selected = rowStorage.rows.filter { $0.selected }.map { $0.value }
            if !selected.isEmpty {
                selection?(selected)
            }
        }
        isDraggingSelection = false
        selectionStartRow = nil
    }

    private func handleRightClick(row: Int, point: NSPoint, event: NSEvent) {
        guard row < rowStorage.rows.count else { return }
        guard let rightClick = rightClick else { return }

        let item = rowStorage.rows[row]
        rowStorage.rightSelected(id: item.value.id, selected: true)

        // 判断哪一列（内容从 x=0 开始，与 header 对齐）
        var columnOffset = point.x
        var columnKey = ""
        for col in columnStorage.columns {
            columnOffset -= col.width
            if columnOffset <= 0 {
                columnKey = col.key
                break
            }
            columnOffset -= 1 // spacing
        }

        rightClick(item.value, columnKey, event)
        refreshUI.toggle()
    }

    // MARK: - Column Width Management

    func initWidth() {
        if tableSize == CGSize.zero { return }

        let totalWidth = tableSize.width - scrollBarWidth - CGFloat(max(columnStorage.columns.count - 1, 0))
        let totalCount = columnStorage.columns.count

        var distributedWidths = 0.0
        var distributedCount = 0
        for item in columnStorage.columns {
            if let idea = item.ideaWidth {
                item.width = idea
                distributedWidths += idea
                distributedCount += 1
            }
        }

        while distributedCount < columnStorage.columns.count {
            let savedCount = distributedCount
            let lostPerWidth = (totalWidth - distributedWidths) / CGFloat(totalCount - distributedCount)

            for item in columnStorage.columns {
                if item.width == 0 {
                    if lostPerWidth < item.minWidth {
                        item.width = item.minWidth
                        distributedWidths += item.minWidth
                        distributedCount += 1
                    } else if let maxWidth = item.maxWidth {
                        if lostPerWidth > maxWidth {
                            item.width = maxWidth
                            distributedWidths += maxWidth
                            distributedCount += 1
                        }
                    }
                }
            }

            if savedCount == distributedCount { break }
        }

        if distributedCount < totalCount {
            let lostPerWidth = (totalWidth - distributedWidths) / CGFloat(totalCount - distributedCount)
            for item in columnStorage.columns {
                if item.width == 0.0 {
                    item.width = lostPerWidth
                    distributedWidths += lostPerWidth
                }
            }
        }

        while true {
            var keepRunning = false

            if distributedWidths > totalWidth {
                let shrinkWidth = (distributedWidths - totalWidth) / CGFloat(totalCount)
                distributedWidths = 0
                for item in columnStorage.columns {
                    let nowWidth = item.width
                    item.width = max(item.minWidth, nowWidth - shrinkWidth)
                    distributedWidths += item.width
                    if item.width != nowWidth { keepRunning = true }
                }
            } else if distributedWidths < totalWidth {
                let expandWidth = (totalWidth - distributedWidths) / CGFloat(totalCount)
                distributedWidths = 0
                for item in columnStorage.columns {
                    let nowWidth = item.width
                    if let max = item.maxWidth {
                        item.width = min(max, nowWidth + expandWidth)
                    } else {
                        item.width = nowWidth + expandWidth
                    }
                    distributedWidths += item.width
                    if item.width != nowWidth { keepRunning = true }
                }
            }

            if !keepRunning { break }
        }

        refreshEndPadding()
    }

    func updateWidth() {
        if tableSize == CGSize.zero { return }
        let targetWidth = tableSize.width - scrollBarWidth - CGFloat(max(columnStorage.columns.count - 1, 0))
        var currentWidth = 0.0
        for item in columnStorage.columns {
            currentWidth += item.width
        }

        if targetWidth > currentWidth {
            while currentWidth < targetWidth {
                var changed = false
                let perExpandWidth = (targetWidth - currentWidth) / CGFloat(columnStorage.columns.count)
                currentWidth = 0
                for item in columnStorage.columns {
                    if let maxWidth = item.maxWidth {
                        let newWidth = min(item.width + perExpandWidth, maxWidth)
                        if newWidth != item.width {
                            item.width = newWidth
                            changed = true
                        }
                    } else {
                        item.width = item.width + perExpandWidth
                        changed = true
                    }
                    currentWidth += item.width
                }
                if !changed { break }
            }
        } else if targetWidth < currentWidth {
            while currentWidth > targetWidth {
                var changed = false
                let perShrinkWidth = (currentWidth - targetWidth) / CGFloat(columnStorage.columns.count)
                currentWidth = 0
                for item in columnStorage.columns {
                    let newWidth = max(item.width - perShrinkWidth, item.minWidth)
                    if newWidth != item.width {
                        item.width = newWidth
                        changed = true
                    }
                    currentWidth += item.width
                }
                if !changed { break }
            }
        }

        refreshEndPadding()
    }

    func refreshEndPadding() {
        var currentWidth = 0.0
        for item in columnStorage.columns {
            currentWidth += item.width
        }
        let spacing = CGFloat(max(columnStorage.columns.count - 1, 0))
        endPinding = tableSize.width - scrollBarWidth - spacing - currentWidth
    }

    // MARK: - Helpers

    func resolveRowHeight(_ value: Value?) -> CGFloat? {
        if let getRowHeight = getRowHeight {
            return getRowHeight(value)
        }
        return defaultRowHeight
    }

    func resolveBackgroundRowHeight() -> CGFloat {
        return resolveRowHeight(nil) ?? 25
    }

    func calculateDataHeight() -> CGFloat {
        var total: CGFloat = 0
        for row in rowStorage.rows {
            total += resolveRowHeight(row.value) ?? 25
        }
        return total
    }

    func calculateExtraBackgroundRows() -> Int {
        let dataHeight = calculateDataHeight()
        // contentVisibleSize 可能尚未初始化（滚动监听器未触发），此时用 tableSize 估算
        let visibleHeight: CGFloat
        if contentVisibleSize.height > 0 {
            visibleHeight = contentVisibleSize.height
        } else {
            visibleHeight = max(tableSize.height - titleSize.height - scrollBarWidth, 0)
        }
        let bgTotalHeight = visibleHeight - dataHeight - scrollBarWidth
        guard bgTotalHeight > 0 else { return 0 }

        let bgH = resolveBackgroundRowHeight()
        let bgCount = Int((bgTotalHeight / bgH).rounded(.up))
        return max(0, bgCount)
    }
}


// MARK: - Shared Types
class AKSUTableRowStorage<Value: Identifiable>: ObservableObject {
    @Published var rows: [AKSUTableRowItem<Value>] = []

    @Published var selection: Set<Value.ID> = []
    @Published var selectionFirst: Value.ID? = nil
    @Published var selectionLast: Value.ID? = nil
    private var selectionFirstPosition: Int? = nil
    private var selectionLastPosition: Int? = nil

    @Published var rightSelection: Value.ID? = nil

    var appearList: [Int: (count: Int, top: CGFloat, bottom: CGFloat)] = [:]

    func clearAllSelected() {
        for row in rows {
            if row.selected { row.selected = false }
            if row.rightSelected { row.rightSelected = false }
        }
        selection.removeAll()
        rightSelection = nil
        selectionFirst = nil
        selectionLast = nil
        selectionFirstPosition = nil
        selectionLastPosition = nil
    }

    func rightSelected(id: Value.ID, selected: Bool) {
        // 取消旧的右键选中
        if let oldId = rightSelection {
            if let oldRow = rows.first(where: { $0.value.id == oldId }) {
                oldRow.rightSelected = false
            }
        }

        if selected {
            rightSelection = id
            if let row = rows.first(where: { $0.value.id == id }) {
                row.rightSelected = true
            }
        }
        else {
            rightSelection = nil
        }
    }

    func isRightSelected(id: Value.ID) -> Bool {
        return rightSelection == id
    }

    // 左键选取的内容
    func selected(index: Int, selected: Bool) {
        let item = rows[index]
        item.selected = true
        if selected {
            selection.insert(item.value.id)
            if selectionFirst == nil || index < selectionFirstPosition! {
                selectionFirst = item.value.id
                selectionFirstPosition = index
            }
            if selectionLast == nil || index > selectionLastPosition! {
                selectionLast = item.value.id
                selectionLastPosition = index
            }
        }
        else {
            selection.remove(item.value.id)
        }
    }

    func isSelected(id: Value.ID) -> Bool {
        return selection.contains(id)
    }

    // 在数据刷新之后重新选择已经选中的内容
    func resetSelected() {
        var newSelection = Set<Value.ID>()
        selectionFirst = nil
        selectionLast = nil
        selectionFirstPosition = nil
        selectionLastPosition = nil

        for (i, item) in rows.enumerated() {
            if item.selected {
                newSelection.insert(item.value.id)
                if selectionFirst == nil || i < selectionFirstPosition! {
                    selectionFirst = item.value.id
                    selectionFirstPosition = i
                }
                if selectionLast == nil || i > selectionLastPosition! {
                    selectionLast = item.value.id
                    selectionLastPosition = i
                }
            }

            if item.rightSelected {
                rightSelection = item.value.id
            }
        }
        selection = newSelection
    }

    // 精确移除被删除行的选中状态，不遍历所有行
    func removeDeleted(_ deletedIds: Set<Value.ID>) {
        var needRecalcFirstLast = false

        for id in deletedIds {
            selection.remove(id)
            if id == selectionFirst {
                selectionFirst = nil
                selectionFirstPosition = nil
                needRecalcFirstLast = true
            }
            if id == selectionLast {
                selectionLast = nil
                selectionLastPosition = nil
                needRecalcFirstLast = true
            }
            if id == rightSelection {
                rightSelection = nil
            }
        }

        // 如果 first/last 被删了，从剩余选中项中重算
        if needRecalcFirstLast && !selection.isEmpty {
            for (i, item) in rows.enumerated() {
                if item.selected {
                    if selectionFirst == nil || i < selectionFirstPosition! {
                        selectionFirst = item.value.id
                        selectionFirstPosition = i
                    }
                    if selectionLast == nil || i > selectionLastPosition! {
                        selectionLast = item.value.id
                        selectionLastPosition = i
                    }
                }
            }
        }
    }

    // 管理已经显示的项目
    func appear(index: Int, offset: CGFloat, height: CGFloat) {
        if let value = appearList[index] {
            appearList[index] = (value.count + 1, offset, offset + height)
        }
        else {
            appearList[index] = (1, offset, offset + height)
        }
    }

    func disappear(index: Int) {
        if let value = appearList[index] {
            if value.count <= 1 {
                appearList.removeValue(forKey: index)
            }
            else {
                appearList[index] = (value.count - 1, value.top, value.bottom)
            }
        }
    }
}

class AKSUTableRowItem<Value>: Identifiable, ObservableObject {
    var value: Value
    @Published var selected: Bool
    @Published var rightSelected: Bool

    init(value: Value, selected: Bool, rightSelected: Bool) {
        self.value = value
        self.selected = selected
        self.rightSelected = rightSelected
    }
}

class AKSUTableColumnStorage<Value>: ObservableObject {
    @Published var columns: [AKSUTableColumnItem<Value>] = []

    func reset(_ list: [AKSUTableColumnItem<Value>]) {
        self.columns = list
    }

    func refresh() {
        self.objectWillChange.send()
    }
}

class AKSUTableColumnItem<Value>: Identifiable, ObservableObject {
    let key: String
    let minWidth: CGFloat
    let ideaWidth: CGFloat?
    let maxWidth: CGFloat?
    var headerBuilder: () -> [AnyView]
    var itemBuilder: (Value) -> [AnyView]

    @Published var width = 100.0

    init(builder: AKSUTableColumn<Value>) {
        self.key = builder.key
        self.headerBuilder = builder.headerBuilder
        self.itemBuilder = builder.itemBuilder
        self.minWidth = builder.minWidth
        self.ideaWidth = builder.ideaWidth
        self.maxWidth = builder.maxWidth
    }
}

public struct AKSUTableColumn<V>: Identifiable {
    public let id: UUID = UUID()

    public let key: String
    public let minWidth: CGFloat
    public let ideaWidth: CGFloat?
    public let maxWidth: CGFloat?

    public init(_ key: String, minWidth: CGFloat = 20, ideaWidth: CGFloat? = nil, maxWidth: CGFloat? = nil, @AKSUAnyViewArrayBuilder headerBuilder: @escaping () -> [AnyView], @AKSUAnyViewArrayBuilder itemBuilder: @escaping (V) -> [AnyView]) {
        self.key = key
        self.headerBuilder = headerBuilder
        self.itemBuilder = itemBuilder
        self.minWidth = minWidth
        self.ideaWidth = ideaWidth
        self.maxWidth = maxWidth
    }

    // 表头内容
    @AKSUAnyViewArrayBuilder var headerBuilder: () -> [AnyView]

    // 单元格内容
    @AKSUAnyViewArrayBuilder var itemBuilder: (V) -> [AnyView]
}

@resultBuilder public enum AKSUTableColumnBuilder<Value: Identifiable> {
    static func buildBlock() -> [AKSUTableColumn<Value>] {
        []
    }

    public static func buildBlock(_ components: AKSUTableColumn<Value>...) -> [AKSUTableColumn<Value>] {
        components
    }

    public static func buildBlock(_ components: [AKSUTableColumn<Value>]...) -> [AKSUTableColumn<Value>] {
        components.flatMap {
            $0
        }
    }

    public static func buildExpression(_ expression: AKSUTableColumn<Value>) -> [AKSUTableColumn<Value>] {
        [expression]
    }

    public static func buildExpression(_ expression: ForEach<Range<Int>, Int, AKSUTableColumn<Value>>) -> [AKSUTableColumn<Value>] {
        expression.data.map {
            expression.content($0)
        }
    }

    public static func buildEither(first: [AKSUTableColumn<Value>]) -> [AKSUTableColumn<Value>] {
        return first
    }

    public static func buildEither(second: [AKSUTableColumn<Value>]) -> [AKSUTableColumn<Value>] {
        return second
    }

    public static func buildIf(_ element: [AKSUTableColumn<Value>]?) -> [AKSUTableColumn<Value>] {
        return element ?? []
    }
}

// struct
struct Person: Identifiable, Equatable {
    let id = UUID()
    let index: Int
    let givenName: String
    let familyName: String
    let emailAddress: String
}

// MARK: - Preview

struct AKSUTable_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AKSUTablePreviewsView()
        }
        .frame(width: 600, height: 600)
    }
}

struct AKSUTablePreviewsView: View {
    @State private var people: [Person] = []
    @State var color: Color = .aksuTextBackground
    @State var appending: Bool = false

    func add() {
        if !appending { return }
        for index in 0 ... 100 {
            if !appending { return }
            people.append(Person(index: index, givenName: "tom \(people.count)", familyName: "alwaysking", emailAddress: "xxx@hotmail.com"))
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            add()
        }
    }

    var body: some View {
        HStack {
            Button("init") {
                var tmp = [Person]()
                for index in 0 ... 10 {
                    tmp.append(Person(index: index, givenName: "tom \(index)", familyName: "alwaysking", emailAddress: "xxx@hotmail.com"))
                }
                people = tmp
            }

            Button("add") {
                for index in 0 ... 20 {
                    people.append(Person(index: index, givenName: "tom \(people.count)", familyName: "alwaysking", emailAddress: "xxx@hotmail.com"))
                }
            }

            Button("time") {
                appending.toggle()
                if appending {
                    add()
                }
            }
        }
        HStack {
            Text("颜色")
            AKSUButton("", bgColor: .red) {
                color = .red
            }
            AKSUButton("", bgColor: .green) {
                color = .green
            }
            AKSUButton("", bgColor: .blue) {
                color = .blue
            }
            AKSUButton("", bgColor: .aksuLightBlue) {
                color = .aksuLightBlue
            }
            AKSUButton("", bgColor: .white) {
                color = .aksuTextBackground
            }
        }

        AKSUTable(data: $people, defaultRowHeight: 60, multSelection: true)
            {
                AKSUTableColumn("名字", minWidth: 200, maxWidth: 300) {
                    HStack {
                        Text("名字").padding().frame(height: 20)
                        Spacer()
                    }.frame(height: 20)
                } itemBuilder: { value in
                    HStack {
                        Text(value.givenName).padding(.leading)
                        Spacer()
                    }
                }
                AKSUTableColumn("家庭", minWidth: 200, maxWidth: 300) {
                    Text("家庭")
                } itemBuilder: { value in
                    Text(value.familyName)
                }

                AKSUTableColumn("电子邮件", minWidth: 200, maxWidth: 300) {
                    Text("电子邮件")
                } itemBuilder: { value in
                    Text(value.emailAddress)
                }

            } selection: { list in
                print(list)
            } rightClick: { value, key, event in
                guard let location = AKSUMouseEventMonitor.filpLocationPoint(event: event) else { return }
                let menu = NSMenu()
                let menuItem1 = NSMenuItem(title: "Menu Item 1", action: nil, keyEquivalent: "")
                menu.addItem(menuItem1)
                let menuItem2 = NSMenuItem(title: "Menu Item 2", action: nil, keyEquivalent: "")
                menu.addItem(menuItem2)
                menu.popUp(positioning: nil, at: location, in: event?.window?.contentView)
            }
            getRowHeight: { value in
                if let value = value {
                    return CGFloat(value.index % 2 * 20 + 20)
                }
                return 30
            }
    }
}
