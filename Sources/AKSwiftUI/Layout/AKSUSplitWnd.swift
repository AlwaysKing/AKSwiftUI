//
//  AKSUSplitWnd.swift
//  AKSwiftUI
//
//  Created by alwaysking on 2024/9/2.
//

import SwiftUI

@available(macOS 14.0, *)
public struct AKSUSplitWnd<LeftView: View, MainView: View>: View {
    let leftView: LeftView
    let mainView: MainView
    let rightView: AnyView

    var mainLayout: (min: CGFloat?, ideal: CGFloat, max: CGFloat?) = (nil, 600, nil)

    @Binding var showLeft: Bool
    @State var realShowLeft: NavigationSplitViewVisibility = .detailOnly
    var leftButton: Bool
    var leftLayout: (min: CGFloat?, ideal: CGFloat, max: CGFloat?) = (nil, 200, nil)
    var leftImage: AnyView? = nil

    @Binding var showRight: Bool
    @State var realShowRight = true
    var rightButton: Bool
    var rightLayout: (min: CGFloat?, ideal: CGFloat, max: CGFloat?) = (nil, 200, nil)
    var rightImage: AnyView? = nil

    public init(leftToolBar: Bool = true, showLeft: Binding<Bool>, @ViewBuilder mainView: () -> MainView, @ViewBuilder leftView: () -> LeftView) {
        self.leftView = leftView()
        self.mainView = mainView()
        self.rightView = AnyView(ZStack {})

        self.leftButton = leftToolBar
        self.realShowLeft = showLeft.wrappedValue ? .all : .detailOnly
        self._showLeft = showLeft

        self.rightButton = false
        self.realShowRight = false
        self._showRight = .constant(false)
    }

    public init<RightView: View>(leftToolBar: Bool = true, showLeft: Binding<Bool>, rightToolBar: Bool = true, showRight: Binding<Bool>, @ViewBuilder mainView: () -> MainView, @ViewBuilder leftView: () -> LeftView, @ViewBuilder rightView: () -> RightView) {
        self.leftView = leftView()
        self.mainView = mainView()
        self.rightView = AnyView(rightView())

        self.leftButton = leftToolBar
        self.realShowLeft = showLeft.wrappedValue ? .all : .detailOnly
        self._showLeft = showLeft

        self.rightButton = rightToolBar
        self.realShowRight = showRight.wrappedValue
        self._showRight = showRight
    }

    public var body: some View {
        HStack {
            NavigationSplitView(columnVisibility: $realShowLeft) {
                leftView
                    .toolbar(removing: .sidebarToggle)
                    .toolbar {
                        if leftButton {
                            ToolbarItem {
                                Button {
                                    withAnimation {
                                        if realShowLeft == .detailOnly {
                                            realShowLeft = .all
                                            showLeft = true
                                        } else {
                                            realShowLeft = .detailOnly
                                            showLeft = false
                                        }
                                    }
                                } label: {
                                    if let leftImage = leftImage {
                                        leftImage
                                    } else {
                                        Image(systemName: "sidebar.leading").imageScale(.large)
                                    }
                                }
                            }
                        }
                    }
                    .navigationSplitViewColumnWidth(min: leftLayout.min, ideal: leftLayout.ideal, max: leftLayout.max)
            }
            detail: {
                mainView
                    .navigationSplitViewColumnWidth(min: mainLayout.min, ideal: mainLayout.ideal, max: mainLayout.max)
            }
            .inspector(isPresented: $realShowRight) {
                rightView
                    .toolbar {
                        if rightButton {
                            Spacer()
                            Button(action: {
                                realShowRight.toggle()
                                showRight = realShowRight
                            }) {
                                if let rightImage = rightImage {
                                    rightImage
                                } else {
                                    Image(systemName: "sidebar.trailing").imageScale(.large)
                                }
                            }
                        }
                    }
                    .inspectorColumnWidth(min: rightLayout.min, ideal: rightLayout.ideal, max: rightLayout.max)
            }
        }
        .onChange(of: showLeft) { _ in
            withAnimation {
                if showLeft == true {
                    realShowLeft = .all
                } else {
                    realShowLeft = .detailOnly
                }
            }
        }
        .onChange(of: showRight) { newValue in
            realShowRight = newValue
        }
    }

    public func mainWndSize(min: CGFloat?, ideal: CGFloat, max: CGFloat?) -> Self {
        var tmp = self
        tmp.mainLayout = (min: min, ideal: ideal, max: max)
        return tmp
    }

    public func leftWndSize(min: CGFloat?, ideal: CGFloat, max: CGFloat?) -> Self {
        var tmp = self
        tmp.leftLayout = (min: min, ideal: ideal, max: max)
        return tmp
    }

    public func showLeftToolButton(show: Bool) -> Self {
        var tmp = self
        tmp.leftButton = show
        return tmp
    }

    public func setLeftToolButton<V: View>(@ViewBuilder view: () -> V) -> Self {
        var tmp = self
        tmp.leftImage = AnyView(view())
        return tmp
    }

    public func rightWndSize(min: CGFloat?, ideal: CGFloat, max: CGFloat?) -> Self {
        var tmp = self
        tmp.rightLayout = (min: min, ideal: ideal, max: max)
        return tmp
    }

    public func showRightToolButton(show: Bool) -> Self {
        var tmp = self
        tmp.rightButton = show
        return tmp
    }

    public func setRightToolButton<V: View>(@ViewBuilder view: () -> V) -> Self {
        var tmp = self
        tmp.rightImage = AnyView(view())
        return tmp
    }
}

@available(macOS 14.0, *)
struct AKSUSplitWnd_Previews: PreviewProvider {
    @State var showLeftView: Bool = true

    static var previews: some View {
        ZStack {
            AKSUSplitWndPreviewsView()
        }
        .frame(width: 600, height: 600)
    }
}

@available(macOS 14.0, *)
struct AKSUSplitWndPreviewsView: View {
    @State var showLeftView: Bool = true
    @State var showRightView: Bool = false

    var body: some View {
        AKSUSplitWnd(leftToolBar: true, showLeft: $showLeftView, rightToolBar: true, showRight: $showRightView) {
            VStack {
                Button(showLeftView ? "left 隐藏" : "left 显示") {
                    showLeftView.toggle()
                }

                Button(showRightView ? "right 隐藏" : "right 显示") {
                    showRightView.toggle()
                }
            }
        } leftView: {
            VStack {
            }
        } rightView: {
            VStack {
            }
        }
        .setRightToolButton {
            Image(systemName: "eraser.fill").imageScale(.large)
        }
        VStack {}
    }
}
