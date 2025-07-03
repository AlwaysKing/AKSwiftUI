//
//  AKSUToast.swift
//  AKSwiftUI
//
//  Created by alwaysking on 2024/9/2.
//

import SwiftUI

public enum AKSUToastLocation {
    case leftTop
    case top
    case rightTop
    case left
    case center
    case right
    case leftBottom
    case bottom
    case rightBottom
}

public class AKSUToastItemStorage: Identifiable, ObservableObject {
    var parent: NSWindow
    var window: NSWindow
    @Published var colorScheme: ColorScheme = .light

    @Published var leftTop: [AKSUToastItemView] = []
    @Published var top: [AKSUToastItemView] = []
    @Published var rightTop: [AKSUToastItemView] = []
    @Published var left: [AKSUToastItemView] = []
    @Published var center: [AKSUToastItemView] = []
    @Published var right: [AKSUToastItemView] = []
    @Published var leftBottom: [AKSUToastItemView] = []
    @Published var bottom: [AKSUToastItemView] = []
    @Published var rightBottom: [AKSUToastItemView] = []

    public init(parent: NSWindow, colorScheme: ColorScheme) {
        self.colorScheme = colorScheme
        self.parent = parent
        self.window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 0, height: 0),
            styleMask: [.fullSizeContentView, .borderless],
            backing: .buffered, defer: false
        )

        window.titlebarAppearsTransparent = true
        window.backgroundColor = .clear
        window.level = .popUpMenu
        window.isReleasedWhenClosed = false
        window.hasShadow = false
        window.contentView = NSHostingView(rootView: AKSUToastWindowView(storage: self))

        // 将windowMenu添加到父亲窗口
        if parent.childWindows != nil {
            if !parent.childWindows!.contains(window) {
                parent.addChildWindow(window, ordered: .above)
            }
        } else {
            parent.addChildWindow(window, ordered: .above)
        }

        window.setFrame(parent.frame, display: true)

        NotificationCenter.default.addObserver(forName: NSWindow.didResizeNotification, object: parent, queue: OperationQueue.main) {
            _ in
            self.window.setFrame(parent.frame, display: true)
        }
    }

    func append(_ view: AKSUToastItemView) {
        switch view.location {
        case .leftTop: leftTop.append(view)
        case .top: top.append(view)
        case .rightTop: rightTop.append(view)
        case .left: left.append(view)
        case .center: center.append(view)
        case .right: right.append(view)
        case .leftBottom: leftBottom.append(view)
        case .bottom: bottom.append(view)
        case .rightBottom: rightBottom.append(view)
        }
    }

    func remove(location: AKSUToastLocation, id: UUID) {
        switch location {
        case .leftTop: leftTop.removeAll(where: { id == $0.id })
        case .top: top.removeAll(where: { id == $0.id })
        case .rightTop: rightTop.removeAll(where: { id == $0.id })
        case .left: left.removeAll(where: { id == $0.id })
        case .center: center.removeAll(where: { id == $0.id })
        case .right: right.removeAll(where: { id == $0.id })
        case .leftBottom: leftBottom.removeAll(where: { id == $0.id })
        case .bottom: bottom.removeAll(where: { id == $0.id })
        case .rightBottom: rightBottom.removeAll(where: { id == $0.id })
        }
    }
}

public class AKSUToast {
    static var colorScheme: ColorScheme = .light
    static var timer: Timer? = nil
    static var windowsList: [Int: AKSUToastItemStorage] = [:]
    public static func showToast(window: NSWindow, location: AKSUToastLocation, title: String?, message: String, headerColor: Color? = nil, color: Color = .aksuText, bgColor: Color = .aksuTextBackground, width: CGFloat = 250, height: CGFloat = 60, maxHeight: CGFloat = 400, timeout: Int? = 5, click: ((Any?) -> Void)? = nil, param: Any? = nil) {
        let view = AKSUToastItemView(location: location, title: title, message: message, headerColor: headerColor, color: color, bgColor: bgColor, width: width, height: height, maxHeight: maxHeight, timeout: timeout, click: click, param: param)

        if let object = windowsList.first(where: { key, _ in key == window.windowNumber }) {
            object.value.append(view)
        } else {
            let object = AKSUToastItemStorage(parent: window, colorScheme: colorScheme)
            object.append(view)
            windowsList[window.windowNumber] = object
            NotificationCenter.default.addObserver(forName: NSWindow.willCloseNotification, object: window, queue: OperationQueue.main) {
                _ in
                windowsList.removeValue(forKey: window.windowNumber)
            }
        }
    }

    public static func showToast(window: NSWindow, location: AKSUToastLocation, timeout: Int? = 5, @ViewBuilder content: (_ windowNumber: Int, _ location: AKSUToastLocation, _ toastID: UUID) -> some View) {
        let id = UUID()
        let view = AKSUToastItemView(location: location, timeout: timeout, id: id, contentView: AnyView(content(window.windowNumber, location, id)))

        if let object = windowsList.first(where: { key, _ in key == window.windowNumber }) {
            object.value.append(view)
        } else {
            let object = AKSUToastItemStorage(parent: window, colorScheme: colorScheme)
            object.append(view)
            windowsList[window.windowNumber] = object
        }
    }

    public static func closeToast(window: NSWindow, location: AKSUToastLocation, id: UUID) {
        if let storage = windowsList[window.windowNumber] {
            storage.remove(location: location, id: id)
        }
    }

    public static func closeToast(windowNumber: Int, location: AKSUToastLocation, id: UUID) {
        if let storage = windowsList[windowNumber] {
            storage.remove(location: location, id: id)
        }
    }

    public static func setColorScheme(_ colorScheme: ColorScheme) {
        AKSUToast.colorScheme = colorScheme
    }

    public static func changeColorScheme(_ colorScheme: ColorScheme) {
        for item in windowsList {
            item.value.colorScheme = colorScheme
        }
    }

    public static func changeColorScheme(window: NSWindow, _ colorScheme: ColorScheme) {
        if let storage = windowsList[window.windowNumber] {
            storage.colorScheme = colorScheme
        }
    }
}

struct AKSUToastWindowView: View {
    @StateObject var storage: AKSUToastItemStorage

    var body: some View {
        ZStack {
            // 左上角
            HStack {
                VStack(alignment: .leading) {
                    ForEach(storage.leftTop) {
                        item in
                        item
                    }
                    Spacer()
                }
                Spacer()
            }.padding([.leading, .top])

            // 上
            HStack {
                VStack {
                    ForEach(storage.top) {
                        item in
                        item
                    }
                    Spacer()
                }
            }.padding(.top)

            // 右上角
            HStack {
                Spacer()
                VStack(alignment: .trailing) {
                    ForEach(storage.rightTop) {
                        item in
                        item
                    }
                    Spacer()
                }
            }.padding([.trailing, .top])

            // 左边
            HStack {
                VStack {
                    ForEach(storage.left) {
                        item in
                        item
                    }
                }
                Spacer()
            }.padding(.leading)

            // 中
            HStack {
                VStack {
                    ForEach(storage.center) {
                        item in
                        item
                    }
                }
            }

            // 右
            HStack {
                Spacer()
                VStack(alignment: .trailing) {
                    ForEach(storage.right) {
                        item in
                        item
                    }
                }
            }.padding(.trailing)

            // 左上角
            HStack {
                VStack(alignment: .leading) {
                    Spacer()
                    ForEach(storage.leftBottom) {
                        item in
                        item
                    }
                }
                Spacer()
            }.padding([.leading, .bottom])

            // 上
            HStack {
                VStack {
                    Spacer()
                    ForEach(storage.bottom) {
                        item in
                        item
                    }
                }
            }.padding(.bottom)

            // 右上角
            HStack {
                Spacer()
                VStack(alignment: .trailing) {
                    Spacer()
                    ForEach(storage.rightBottom) {
                        item in
                        item
                    }
                }
            }.padding([.trailing, .bottom])
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .preferredColorScheme(storage.colorScheme)
        .environmentObject(storage)
    }
}

public struct AKSUToastItemView: View, Identifiable {
    @EnvironmentObject var storage: AKSUToastItemStorage
    let title: String?
    let message: String
    let width: CGFloat
    let height: CGFloat
    let maxHeight: CGFloat?
    let headerColor: Color?
    let bgColor: Color
    let color: Color
    let click: ((Any?) -> Void)?
    let timeout: Int?
    let location: AKSUToastLocation
    let param: Any?
    let contentView: AnyView?

    @State var isExpand: Bool = false
    @State var showExpandBtn: Bool = false

    @State var hoveringExpand: Bool = false
    @State var hoveringClose: Bool = false
    @State var hovering: Bool = false

    @State var contentHeight: CGFloat = 0.0
    @State var titleHeight: CGFloat = 0.0
    @State var timeCount: CGFloat = 5

    @Environment(\.self) var environment
    public let id: UUID

    public init(location: AKSUToastLocation, title: String?, message: String, headerColor: Color? = nil, color: Color = .aksuText, bgColor: Color = .aksuTextBackground, width: CGFloat = 250, height: CGFloat = 60, maxHeight: CGFloat? = 400, timeout: Int? = 5, click: ((Any) -> Void)? = nil, param: Any? = nil) {
        self.title = title
        self.message = message
        self.width = width
        self.height = height
        self.maxHeight = maxHeight
        self.color = color
        self.bgColor = bgColor
        self.headerColor = headerColor
        self.timeout = timeout
        self.click = click
        self.location = location
        self.param = param
        self.contentView = nil
        self.id = UUID()
    }

    public init(location: AKSUToastLocation, timeout: Int? = 5, id: UUID, contentView: AnyView) {
        self.title = nil
        self.message = ""
        self.width = 0
        self.height = 0
        self.maxHeight = 0
        self.color = .clear
        self.bgColor = .clear
        self.headerColor = .clear
        self.timeout = timeout
        self.click = nil
        self.location = location
        self.param = nil
        self.contentView = contentView
        self.id = id
    }

    public var body: some View {
        if let contentView = contentView {
            contentView
                .cornerRadius(AKSUAppearance.cornerRadius)
                .shadow(radius: 2)
                .onHover { hovering = $0 }
                .onAppear {
                    guard let timeout = timeout else { return }
                    timeCount = CGFloat(timeout)
                    timeoutMonitor()
                }
        } else {
            messageView()
        }
    }

    func messageView() -> some View {
        VStack(alignment: .leading, spacing: 2) {
            if let title = title {
                Text(title)
                    .font(.aksuTitle4)
                    .foregroundStyle(.aksuText)
                    .lineLimit(1)
                    .padding([.leading, .trailing])
                    .padding(.top, 6)
                    .background {
                        GeometryReader {
                            reader in
                            Color.clear.onAppear {
                                titleHeight = reader.size.height
                            }
                        }
                    }
            }

            ZStack {
                Text(message)
                    .font(.aksuText)
                    .foregroundStyle(.aksuText)
                    .padding([.leading, .trailing])
                    .padding(.bottom, title == nil ? 0 : 8)
                    .padding(.vertical, title == nil ? 8 : 0)

                // 不限时用来测算高度的
                ScrollView {
                    Text(message)
                        .font(.aksuText)
                        .foregroundStyle(.aksuText)
                        .padding([.leading, .trailing])
                        .padding(.bottom, title == nil ? 0 : 8)
                        .padding(.vertical, title == nil ? 8 : 0)
                        .opacity(0)
                        .background {
                            GeometryReader {
                                reader in
                                Color.clear.onAppear {
                                    showExpandBtn = reader.size.height > height
                                    contentHeight = reader.size.height
                                }
                            }
                        }
                }
                .disabled(true)
            }
        }
        .frame(width: width, height: isExpand ? min(maxHeight ?? contentHeight + titleHeight, contentHeight + titleHeight) : height, alignment: .leading)
        .overlay {
            // 功能按钮
            HStack {
                Spacer()
                VStack {
                    if hovering {
                        ZStack {
                            Image(systemName: "xmark")
                                .frame(width: 14, height: 14)
                                .foregroundColor(hoveringClose ? .aksuText : .aksuLessText)
                                .onHover { hoveringClose = $0 }
                                .padding([.top, .trailing], 4)
                                .onTapGesture {
                                    close()
                                }
                        }
                    }

                    Spacer()
                    if showExpandBtn {
                        ZStack {
                            Image(systemName: "chevron.down")
                                .rotationEffect(Angle(degrees: isExpand ? -180 : 0))
                                .font(.aksuLessText)
                        }
                        .frame(width: 14, height: 14)
                        .background {
                            Circle()
                                .fill(hoveringExpand ? .aksuGrayBackground : .aksuGrayMask)
                        }
                        .onHover { hoveringExpand = $0 }
                        .padding([.bottom, .trailing], 4)
                        .onTapGesture {
                            withAnimation {
                                isExpand.toggle()
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .foregroundColor(color)
        .background(bgColor)
        .cornerRadius(AKSUAppearance.cornerRadius)
        .shadow(radius: 2)
        .opacity(timeCount >= 1 ? 1.0 : timeCount)
        .onTapGesture {
            if let click = click {
                click(param)
                close()
            }
        }
        .onHover { hovering = $0 }
        .onAppear {
            guard let timeout = timeout else { return }
            timeCount = CGFloat(timeout)
            timeoutMonitor()
        }
    }

    func timeoutMonitor() {
        if !hoveringExpand && !hoveringClose && !hovering {
            withAnimation {
                timeCount -= 0.1
            }
        } else {
            timeCount = 2
        }

        if timeCount <= 0 {
            close()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: timeoutMonitor)
        }
    }

    func close() {
        storage.remove(location: location, id: id)
    }
}

struct AKSUToastWnd_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AKSUToastPreviewsView()
        }
        .frame(width: 600, height: 600)
    }
}

struct AKSUToastPreviewsView: View {
    @State var index: Int = 0
    @State var timeout: Bool = false

    var body: some View {
        VStack {
            HStack {
                AKSUToastItemView(location: .leftTop, title: nil, message: "这是一段比较短的的数据内容", timeout: nil)
                AKSUToastItemView(location: .leftTop, title: nil, message: "这是一段比很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长的的数据内容", timeout: nil)
            }

            HStack {
                AKSUToastItemView(location: .leftTop, title: "标题", message: "这是一段比较短的的数据内容", timeout: nil)
                AKSUToastItemView(location: .leftTop, title: "标题", message: "这是一段比很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长的的数据内容", timeout: nil)
            }

            AKSUToastItemView(location: .leftTop, timeout: nil, id: UUID(), contentView: AnyView(AKSUToastContentPreviewsView(windowNumber: 0, location: .left, toastID: UUID())))

            AKSUWarpStack { reader in
                VStack {
                    AKSUCheckBox(checked: $timeout, label: "定时关闭")

                    Text("基本消息")
                    Divider()
                    HStack {
                        AKSUButton("左上角消息") {
                            index += 1
                            AKSUToast.showToast(window: reader.window!, location: .leftTop, title: "Title", message: "Message: \(index)", timeout: timeout ? 5 : nil)
                        }

                        AKSUButton("上消息") {
                            index += 1
                            AKSUToast.showToast(window: reader.window!, location: .top, title: "Title", message: "Message: \(index)", timeout: timeout ? 5 : nil)
                        }

                        AKSUButton("右上角消息") {
                            index += 1
                            AKSUToast.showToast(window: reader.window!, location: .rightTop, title: "Title", message: "Message: \(index)", timeout: timeout ? 5 : nil)
                        }
                    }

                    HStack {
                        AKSUButton("左消息") {
                            index += 1
                            AKSUToast.showToast(window: reader.window!, location: .left, title: "Title", message: "Message: \(index)", timeout: timeout ? 5 : nil)
                        }

                        AKSUButton("居中消息") {
                            index += 1
                            AKSUToast.showToast(window: reader.window!, location: .center, title: "Title", message: "Message: \(index)", timeout: timeout ? 5 : nil)
                        }

                        AKSUButton("右消息") {
                            index += 1
                            AKSUToast.showToast(window: reader.window!, location: .right, title: "Title", message: "Message: \(index)", timeout: timeout ? 5 : nil)
                        }
                    }

                    HStack {
                        AKSUButton("左下消息") {
                            index += 1
                            AKSUToast.showToast(window: reader.window!, location: .leftBottom, title: "Title", message: "Message: \(index)", timeout: timeout ? 5 : nil)
                        }

                        AKSUButton("下消息") {
                            index += 1
                            AKSUToast.showToast(window: reader.window!, location: .bottom, title: "Title", message: "Message: \(index)", timeout: timeout ? 5 : nil)
                        }

                        AKSUButton("右下消息") {
                            index += 1
                            AKSUToast.showToast(window: reader.window!, location: .rightBottom, title: "Title", message: "Message: \(index)", timeout: timeout ? 5 : nil)
                        }
                    }

                    Text("自定义消息")
                    Divider()

                    HStack {
                        AKSUButton("左上角消息") {
                            AKSUToast.showToast(window: reader.window!, location: .leftTop, timeout: timeout ? 5 : nil) {
                                windowNumber, location, toastID in
                                AKSUToastContentPreviewsView(windowNumber: windowNumber, location: location, toastID: toastID)
                            }
                        }

                        AKSUButton("上消息") {
                            AKSUToast.showToast(window: reader.window!, location: .top, timeout: timeout ? 5 : nil) {
                                windowNumber, location, toastID in
                                AKSUToastContentPreviewsView(windowNumber: windowNumber, location: location, toastID: toastID)
                            }
                        }

                        AKSUButton("右上角消息") {
                            AKSUToast.showToast(window: reader.window!, location: .rightTop, timeout: timeout ? 5 : nil) {
                                windowNumber, location, toastID in
                                AKSUToastContentPreviewsView(windowNumber: windowNumber, location: location, toastID: toastID)
                            }
                        }
                    }

                    HStack {
                        AKSUButton("左消息") {
                            AKSUToast.showToast(window: reader.window!, location: .left, timeout: timeout ? 5 : nil) {
                                windowNumber, location, toastID in
                                AKSUToastContentPreviewsView(windowNumber: windowNumber, location: location, toastID: toastID)
                            }
                        }

                        AKSUButton("居中消息") {
                            AKSUToast.showToast(window: reader.window!, location: .center, timeout: timeout ? 5 : nil) {
                                windowNumber, location, toastID in
                                AKSUToastContentPreviewsView(windowNumber: windowNumber, location: location, toastID: toastID)
                            }
                        }

                        AKSUButton("右消息") {
                            AKSUToast.showToast(window: reader.window!, location: .right, timeout: timeout ? 5 : nil) {
                                windowNumber, location, toastID in
                                AKSUToastContentPreviewsView(windowNumber: windowNumber, location: location, toastID: toastID)
                            }
                        }
                    }

                    HStack {
                        AKSUButton("左下消息") {
                            AKSUToast.showToast(window: reader.window!, location: .leftBottom, timeout: timeout ? 5 : nil) {
                                windowNumber, location, toastID in
                                AKSUToastContentPreviewsView(windowNumber: windowNumber, location: location, toastID: toastID)
                            }
                        }

                        AKSUButton("下消息") {
                            AKSUToast.showToast(window: reader.window!, location: .bottom, timeout: timeout ? 5 : nil) {
                                windowNumber, location, toastID in
                                AKSUToastContentPreviewsView(windowNumber: windowNumber, location: location, toastID: toastID)
                            }
                        }

                        AKSUButton("右下消息") {
                            AKSUToast.showToast(window: reader.window!, location: .rightBottom, timeout: timeout ? 5 : nil) {
                                windowNumber, location, toastID in
                                AKSUToastContentPreviewsView(windowNumber: windowNumber, location: location, toastID: toastID)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct AKSUToastContentPreviewsView: View {
    let windowNumber: Int
    let location: AKSUToastLocation
    let toastID: UUID
    @State var isExpand: Bool = false
    var body: some View {
        VStack {
            AKSUButton(isExpand ? "折叠" : "展开") {
                withAnimation {
                    isExpand.toggle()
                }
            }

            AKSUButton("关闭") {
                AKSUToast.closeToast(windowNumber: windowNumber, location: location, id: toastID)
            }
        }
        .frame(width: isExpand ? 200 : 100, height: isExpand ? 200 : 100)
        .background(.green)
    }
}
