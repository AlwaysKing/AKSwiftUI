//
//  AKSUTable.swift
//  AKSwiftUI
//
//  Created by alwaysking on 2024/9/2.
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

    @GestureState var dragState: Bool = false

    // 选择功能
    @State private var scrollOffsetX: CGFloat = 0.0
    @State private var scrollOffsetY: CGFloat = 0.0
    @State private var selectionInfo: (start: CGFloat, end: CGFloat)? = nil

    // 自定义滚动条状态
    @State private var contentScrollPosition: CGPoint = .zero
    @State private var contentContentSize: CGSize = .zero
    @State private var contentVisibleSize: CGSize = .zero
    @State private var scrollBarWidth: CGFloat = 0

    let headerBgColor: Color
    let contentBgColor: Color
    let selectionColor: Color
    let splitColor: Color
    let splitlineColor: Color
    let headerSplitColor: Color
    let headerDividerColor: Color

    let splitline: Bool
    let multSelection: Bool
    let selection: (([Value]) -> Void)?
    let rightClick: ((Value, String, NSEvent?) -> Void)?
    let defaultRowHeight: CGFloat?
    let getRowHeight: ((Value?) -> CGFloat?)?

    @State var backgroundColorIndex: Int = 0
    @State var backgroundRowTotalHeight: CGFloat = 0.0
    @State var measuredDataHeight: CGFloat = 0.0

    public init(data: Binding<[Value]>, defaultRowHeight: CGFloat? = nil, headerBgColor: Color = .aksuTextBackground, headerSplitColor: Color = .aksuDivider, headerDividerColor: Color = .aksuDivider, contentBgColor: Color = .aksuTextBackground, selectionColor: Color = .aksuPrimary, splitColor: Color = .aksuGrayMask, splitline: Bool = false, splitlineColor: Color = .aksuGrayMask, multSelection: Bool = false, @AKSUTableColumnBuilder<Value> columns: () -> [AKSUTableColumn<Value>], selection: (([Value]) -> Void)? = nil, rightClick: ((Value, String, NSEvent?) -> Void)? = nil, getRowHeight: ((Value?) -> CGFloat?)? = nil)
    {
        self._data = data
        self._initColumns = columns().map { AKSUTableColumnItem(builder: $0) }
        self.headerBgColor = headerBgColor
        self.contentBgColor = contentBgColor
        self.selection = selection
        self.rightClick = rightClick
        self.multSelection = multSelection
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
                                    }
                                    else {
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

            // Content
            AKSUNSScrollView(axes: [.horizontal, .vertical], scrollPosition: $contentScrollPosition, contentSize: $contentContentSize, visibleSize: $contentVisibleSize, scrollBarWidth: $scrollBarWidth,
                                onScrollChanged: { offsetY, offsetX in
                                    contentScrollPosition = CGPoint(x: offsetX, y: offsetY)
                                    let newScrollY = -offsetY
                                    selectionRange(scroll: newScrollY)
                                    scrollOffsetX = -offsetX
                                }) {
                    VStack(alignment: .leading, spacing: 0) {
                        LazyVStack(alignment: .leading, spacing: 0) {
                            ForEach(rowStorage.rows) {
                                item in
                                ZStack(alignment: .leading) {
                                    let selected = rowStorage.isSelected(id: item.value.id)
                                    
                                    // 添加背景色
                                    VStack(spacing: 0) {
                                        if item.light {
                                            RoundedRectangle(cornerRadius: AKSUAppearance.cornerRadius)
                                                .fill(splitColor)
                                        }
                                        else {
                                            Rectangle().fill(contentBgColor)
                                        }
                                        if splitline {
                                            Rectangle()
                                                .fill(splitlineColor)
                                                .frame(height: 1)
                                                .cornerRadius(AKSUAppearance.cornerRadius)
                                        }
                                    }
                                    .padding(.leading, scrollBarWidth + 3)
                                    .padding(.trailing, 3)

                                    if selected {
                                        if multSelection {
                                            if item.index == rowStorage.selectionFirst {
                                                ZStack {
                                                    RoundedRectangle(cornerRadius: AKSUAppearance.cornerRadius)
                                                        .fill(selectionColor)
                                                        .padding(.leading, scrollBarWidth + 3)
                                                        .padding(.trailing, 3)
                                                    if item.index != rowStorage.selectionLast {
                                                        VStack {
                                                            Spacer()
                                                            Rectangle()
                                                                .fill(selectionColor)
                                                                .frame(height: 7)
                                                                .padding(.leading, scrollBarWidth + 3)
                                                                .padding(.trailing, 3)
                                                        }
                                                    }
                                                }
                                            }
                                            else if item.index == rowStorage.selectionLast {
                                                ZStack {
                                                    RoundedRectangle(cornerRadius: AKSUAppearance.cornerRadius)
                                                        .fill(selectionColor)
                                                        .padding(.leading, scrollBarWidth + 3)
                                                        .padding(.trailing, 3)
                                                    VStack {
                                                        Rectangle()
                                                            .fill(selectionColor)
                                                            .frame(height: 7)
                                                            .padding(.leading, scrollBarWidth + 3)
                                                            .padding(.trailing, 3)
                                                        Spacer()
                                                    }
                                                }
                                            }
                                            else {
                                                Rectangle()
                                                    .fill(selectionColor)
                                                    .padding(.leading, scrollBarWidth + 3)
                                                    .padding(.trailing, 3)
                                            }
                                        }
                                        else {
                                            RoundedRectangle(cornerRadius: AKSUAppearance.cornerRadius)
                                                .fill(selectionColor)
                                                .padding(.leading, scrollBarWidth + 3)
                                                .padding(.trailing, 3)
                                        }
                                    }

                                    if item.rightSelected {
                                        RoundedRectangle(cornerRadius: AKSUAppearance.cornerRadius)
                                            .stroke(selected ? .aksuWhite : selectionColor, lineWidth: 1.5)
                                            .padding(.leading, scrollBarWidth + (selected ? 6 : 4))
                                            .padding(.trailing, selected ? 6 : 4)
                                            .padding(.vertical, selected ? 3 : 2)
                                    }

                                    HStack(spacing: 1) {
                                        ForEach(columnStorage.columns) { header in
                                            // 这里要传递数据
                                            HStack {
                                                header.itemBuilder(item.value).first
                                            }
                                            .frame(width: header.width)
                                            .foregroundColor(selected ? .aksuWhite : nil)
                                        }
                                        if endPinding > 0 {
                                            ZStack { }
                                                .frame(width: endPinding, height: 1)
                                        }
                                    }
                                }
                                .frame(minWidth: 25)
                                .frame(height: resolveRowHeight(item.value))
                                .contentShape(Rectangle())
                                .onMouseEvent(event: [.rightMouseDown]) { point, event in
                                    rightSelection(row: item, point: point, event: event)
                                    refreshUI.toggle()
                                    return true
                                }
                                .background {
                                    GeometryReader { geometry in
                                        Color.clear
                                            .onAppear {
                                                rowStorage.appear(index: item.index, offset: geometry.frame(in: .named("dataLazyVStack")).minY, height: geometry.size.height)
                                            }
                                    }
                                }
                                .onDisappear {
                                    rowStorage.disappear(index: item.index)
                                }
                            }
                        }
                        .coordinateSpace(name: "dataLazyVStack")
                        .background(
                            GeometryReader { geo in
                                Color.clear
                                    .onAppear {
                                        let newHeight = geo.size.height
                                        if abs(measuredDataHeight - newHeight) > 0.5 {
                                            measuredDataHeight = newHeight
                                        }
                                    }
                                    .onChange(of: geo.size.height) { newHeight in
                                        if abs(measuredDataHeight - newHeight) > 0.5 {
                                            measuredDataHeight = newHeight
                                        }
                                    }
                            }
                        )

                        // 在高度不够的情况下增加背景
                        let bgTotalHeight = (contentVisibleSize.height - measuredDataHeight - scrollBarWidth)
                        if bgTotalHeight > 0 {
                            VStack(spacing: 0) {
                                let bgH = resolveBackgroundRowHeight() - (splitline ? 1 : 0)

                                let bgCount = Int((bgTotalHeight / bgH).rounded(.up))
                                ForEach(Array(0 ..< bgCount), id: \.self) {
                                    index in
                                    HStack(spacing: 0) {
                                        if (max(1, backgroundColorIndex) + index) % 2 == 0 {
                                            Rectangle()
                                                .fill(splitColor)
                                                .frame(height: bgH)
                                                .frame(maxWidth: .infinity)
                                                .cornerRadius(AKSUAppearance.cornerRadius)
                                        }
                                        else {
                                            Rectangle()
                                                .fill(contentBgColor)
                                                .frame(height: bgH)
                                        }
                                        if splitline {
                                            Rectangle()
                                                .fill(splitlineColor)
                                                .frame(height: 1)
                                                .frame(maxWidth: .infinity)
                                                .cornerRadius(AKSUAppearance.cornerRadius)
                                        }
                                    }
                                    .padding(.leading, scrollBarWidth + 3)
                                        .padding(.trailing, 3)
                                }

                                Spacer(minLength: 0)
                            }
                            .frame(maxHeight: bgTotalHeight.rounded(.down), alignment: .topLeading)
                            .clipped()
                            Spacer(minLength: 0)
                        }
                    }
                    .frame(minHeight: contentVisibleSize.height > 0 ? contentVisibleSize.height : nil,  alignment: .topLeading)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .updating($dragState) { value, state, transaction in
                                DispatchQueue.main.async {
                                    selectionInfo = (value.startLocation.y, value.location.y)
                                    selectionRange(scroll: 0)
                                }
                            }
                            .onEnded { _ in
                                selectionInfo = nil
                            }
                    )
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .background(contentBgColor)
        }
        .onChange(of: data) { _ in
            var light = false
            var tmp = [AKSUTableRowItem<Value>]()
            for (index, item) in data.enumerated() {
                tmp.append(AKSUTableRowItem(index: index, value: item, light: light, selected: rowStorage.isSelected(id: item.id), rightSelected: rowStorage.isRightSelected(id: item.id)))
                light = !light
            }
            rowStorage.rows = tmp
            rowStorage.resetSelected()
            refreshEndPadding()
            refreshUI.toggle()
        }
        .onChange(of: titleSize) { _ in
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
            self.columnStorage.reset(_initColumns)
            initWidth()
        }
        .clipped()
    }

    func initWidth() {
        if tableSize == CGSize.zero {
            return
        }

        let totalWidth = tableSize.width - scrollBarWidth - CGFloat(max(columnStorage.columns.count - 1, 0))
        let totalCount = columnStorage.columns.count

        // 第一步给idea 分配空间
        var distributedWidths = 0.0
        var distributedCount = 0
        for item in columnStorage.columns {
            if let idea = item.ideaWidth {
                item.width = idea
                distributedWidths += idea
                distributedCount += 1
            }
        }

        // 给剩余的分一分
        while distributedCount < columnStorage.columns.count {
            let savedCount = distributedCount
            let lostPerWidth = (totalWidth - distributedWidths) / CGFloat(totalCount - distributedCount)

            // 参考最大最小宽度选择
            for item in columnStorage.columns {
                if item.width == 0 {
                    if lostPerWidth < item.minWidth {
                        item.width = item.minWidth
                        distributedWidths += item.minWidth
                        distributedCount += 1
                    }
                    else if let maxWidth = item.maxWidth {
                        if lostPerWidth > maxWidth {
                            item.width = maxWidth
                            distributedWidths += maxWidth
                            distributedCount += 1
                        }
                    }
                }
            }

            // 这一轮轮空了，说明没有可以分配的了
            if savedCount == distributedCount {
                break
            }
        }

        // 最后把剩下的分一分
        if distributedCount < totalCount {
            let lostPerWidth = (totalWidth - distributedWidths) / CGFloat(totalCount - distributedCount)
            for item in columnStorage.columns {
                if item.width == 0.0 {
                    item.width = lostPerWidth
                    distributedWidths += lostPerWidth
                }
            }
        }

        // 接下来就开始 缩放了
        while true {
            var keepRunning = false

            if distributedWidths > totalWidth {
                // 缩小
                let shrinkWidth = (distributedWidths - totalWidth) / CGFloat(totalCount)
                distributedWidths = 0
                for item in columnStorage.columns {
                    let nowWidth = item.width
                    item.width = max(item.minWidth, nowWidth - shrinkWidth)
                    distributedWidths += item.width
                    if item.width != nowWidth {
                        keepRunning = true
                    }
                }
            }
            else if distributedWidths < totalWidth {
                // 放宽
                let expandWidth = (totalWidth - distributedWidths) / CGFloat(totalCount)
                distributedWidths = 0
                for item in columnStorage.columns {
                    let nowWidth = item.width
                    if let max = item.maxWidth {
                        item.width = min(max, nowWidth + expandWidth)
                    }
                    else {
                        item.width = nowWidth + expandWidth
                    }

                    distributedWidths += item.width
                    if item.width != nowWidth {
                        keepRunning = true
                    }
                }
            }

            if keepRunning == false {
                break
            }
        }

        refreshEndPadding()
    }

    func updateWidth() {
        if tableSize == CGSize.zero {
            return
        }
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
                    }
                    else {
                        item.width = item.width + perExpandWidth
                        changed = true
                    }
                    currentWidth += item.width
                }
                if changed == false {
                    break
                }
            }
        }
        else if targetWidth < currentWidth {
            // 缩减
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
                if changed == false {
                    break
                }
            }
        }

        refreshEndPadding()
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

    func calculateDataHeight() -> CGFloat {
        var total: CGFloat = 0
        for row in rowStorage.rows {
            total += resolveRowHeight(row.value) ?? 25
        }
        return total
    }

    func refreshEndPadding() {
        var currentWidth = 0.0
        for item in columnStorage.columns {
            currentWidth += item.width
        }
        let spacing = CGFloat(max(columnStorage.columns.count - 1, 0))
        endPinding = tableSize.width - scrollBarWidth - spacing - currentWidth
    }

    func selectionRange(scroll: CGFloat) {
        guard let selection = selection else { return }
        var scrollChanged = 0.0
        if scroll != 0 {
            scrollChanged = scroll - scrollOffsetY
            scrollOffsetY = scroll
        }

        guard let selectionInfo = selectionInfo else { return }
        var start = selectionInfo.start
        var end = selectionInfo.end - scrollChanged
        self.selectionInfo = (selectionInfo.start, CGFloat(end))

        if start > end {
            let tmp = end
            end = start
            start = tmp
        }

        if multSelection {
            var selected = [Value]()
            rowStorage.clearAllSelected()
            for item in rowStorage.appearList {
                guard item.key < rowStorage.rows.count else { continue }
                if item.value.top > end || item.value.bottom < start {
                    continue
                }

                selected.append(rowStorage.rows[item.key].value)
                rowStorage.selected(index: item.key, selected: true)
            }

            // 处理一下首尾的问题
            selection(selected)
        }
        else {
            // 单选只要最后一个就行
            rowStorage.clearAllSelected()
            for item in rowStorage.appearList {
                guard item.key < rowStorage.rows.count else { continue }
                if item.value.top < end && end < item.value.bottom {
                    rowStorage.selected(index: item.key, selected: true)
                    selection([rowStorage.rows[item.key].value])
                    break
                }
            }
        }
    }

    func rightSelection(row: AKSUTableRowItem<Value>, point: CGPoint, event: NSEvent?) {
        guard let rightClick = rightClick else { return }
        rowStorage.rightSelected(index: row.index, selected: true)

        // 判断是哪一个colume
        var columnOffset = point.x
        var columnKey = ""
        for item in columnStorage.columns {
            columnOffset -= item.width
            if columnOffset <= 0 {
                columnKey = item.key
                break
            }
        }
        rightClick(row.value, columnKey, event)
    }
}

class AKSUTableRowStorage<Value: Identifiable>: ObservableObject {
    @Published var rows: [AKSUTableRowItem<Value>] = []

    @Published var selection: Set<Value.ID> = []
    @Published var selectionIndex: Set<Int> = []
    @Published var selectionFirst: Int? = nil
    @Published var selectionLast: Int? = nil

    @Published var rightSelection: Value.ID? = nil
    @Published var rightSelectionIndex: Int? = nil

    var appearList: [Int: (count: Int, top: CGFloat, bottom: CGFloat)] = [:]

    func clearAllSelected() {
        selection.removeAll()
        for index in selectionIndex {
            guard index < rows.count else { continue }
            rows[index].selected = false
        }
        selectionIndex.removeAll()
        if let oldIndex = rightSelectionIndex {
            if oldIndex < rows.count {
                rows[oldIndex].rightSelected = false
            }
        }
        rightSelection = nil
        rightSelectionIndex = nil
        selectionFirst = nil
        selectionLast = nil
    }

    func rightSelected(index: Int, selected: Bool) {
        if let oldIndex = rightSelectionIndex {
            if oldIndex < rows.count {
                rows[oldIndex].rightSelected = false
            }
        }

        guard index < rows.count else { return }
        let item = rows[index]
        if selected {
            rightSelection = item.value.id
            rightSelectionIndex = item.index
            item.rightSelected = selected
        }
        else {
            rightSelection = nil
            rightSelectionIndex = nil
        }
    }

    func isRightSelected(id: Value.ID) -> Bool {
        if let rightSelection = rightSelection {
            return id == rightSelection
        }
        return false
    }

    // 左键选取的内容
    func selected(index: Int, selected: Bool) {
        let item = rows[index]
        item.selected = true
        if selected {
            selection.insert(item.value.id)
            selectionIndex.insert(index)
            if selectionFirst == nil {
                selectionFirst = index
            }
            else {
                selectionFirst = min(selectionFirst!, index)
            }
            if selectionLast == nil {
                selectionLast = index
            }
            else {
                selectionLast = max(selectionLast!, index)
            }
        }
        else {
            selection.remove(item.value.id)
            selectionIndex.remove(index)
        }
    }

    func isSelected(id: Value.ID) -> Bool {
        return selection.contains(id)
    }

    // 在数据刷新之后重新选择已经选中的内容
    func resetSelected() {
        var new = Set<Value.ID>()
        var index = Set<Int>()
        for item in rows {
            if item.selected {
                new.insert(item.value.id)
                index.insert(item.index)
            }

            if item.rightSelected {
                rightSelection = item.value.id
                rightSelectionIndex = item.index
            }
        }
        selection = new
        selectionIndex = index
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
    let index: Int
    let value: Value
    var light: Bool
    @Published var selected: Bool
    @Published var rightSelected: Bool

    init(index: Int, value: Value, light: Bool, selected: Bool, rightSelected: Bool) {
        self.index = index
        self.value = value
        self.light = light
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

struct AKSUTable_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AKSUTablePreviewsView()
        }
        .frame(width: 600, height: 600)
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

struct AKSUTablePreviewsView: View {
    @State private var people: [Person] = []
    @State var color: Color = .aksuTextBackground

    func add() {
        for index in 0 ... 100 {
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
                add()
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

        AKSUTable(data: $people, defaultRowHeight: 60) {
            AKSUTableColumn("名字", minWidth: 200, maxWidth: 300) {
                HStack {
                    Text("名字").padding().frame(height: 20)
                    Spacer()
                }.frame(height: 50)
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
        getRowHeight: {
            value in
            if let value = value {
                return CGFloat(value.index % 2 * 20 + 20)
            }
            return 30
        }
    }
}
