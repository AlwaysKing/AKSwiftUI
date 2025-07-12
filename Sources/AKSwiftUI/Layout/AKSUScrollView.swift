//
//  AKSUScrollView.swift
//  AKSwiftUI
//
//  Created by cnsinda on 2025/7/12.
//

import SwiftUI

struct AKSUScrollViewMonitor {
    let bounds: CGRect
    let frame: CGSize

    var lead: Bool {
        return bounds.origin.x <= 0
    }

    var tail: Bool {
        return bounds.origin.x + bounds.size.width >= frame.width
    }

    var top: Bool {
        return bounds.origin.y <= 0
    }

    var bottom: Bool {
        return bounds.origin.y + bounds.size.height >= frame.height
    }
}

struct AKSUScrollView<Content: View>: View {
    let ases: Axis.Set
    let showsIndicators: Bool
    let content: () -> Content
    var monitor: ((AKSUScrollViewMonitor) -> Void)? = nil

    @State var bounds: CGRect = .zero
    @State var frame: CGSize = .zero

    public init(_ axes: Axis.Set = .vertical, showsIndicators: Bool = true, @ViewBuilder content: @escaping () -> Content) {
        self.ases = axes
        self.showsIndicators = showsIndicators
        self.content = content
    }

    var body: some View {
        if #available(macOS 15.0, *) {
            ScrollView(ases, showsIndicators: showsIndicators, content: content)
                .onScrollGeometryChange(for: ScrollGeometry.self) { geo in
                    geo
                } action: { oldValue, newValue in
                    frame = newValue.contentSize
                    bounds = newValue.visibleRect
                    if let monitor = monitor {
                        monitor(AKSUScrollViewMonitor(bounds: bounds, frame: frame))
                    }
                }
        } else {
            ScrollView(ases, showsIndicators: showsIndicators) {
                content()
                    .background {
                        GeometryReader {
                            reader in
                            if #available(macOS 14.0, *) {
                                Color.clear
                                    .onAppear {
                                        frame = reader.frame(in: .local).size
                                        if let info = reader.bounds(of: .scrollView) {
                                            bounds = info
                                        }
                                        if let monitor = monitor {
                                            monitor(AKSUScrollViewMonitor(bounds: bounds, frame: frame))
                                        }
                                    }
                                    .onChange(of: reader.frame(in: .local)) { info in
                                        frame = info.size
                                        if let monitor = monitor {
                                            monitor(AKSUScrollViewMonitor(bounds: bounds, frame: frame))
                                        }
                                    }
                                    .onChange(of: reader.bounds(of: .scrollView)) { info in
                                        if let info = info {
                                            bounds = info
                                            if let monitor = monitor {
                                                monitor(AKSUScrollViewMonitor(bounds: bounds, frame: frame))
                                            }
                                        }
                                    }
                            } else {
                                Color.clear
                                    .onAppear {
                                        frame = reader.frame(in: .local).size
                                        if let monitor = monitor {
                                            monitor(AKSUScrollViewMonitor(bounds: bounds, frame: frame))
                                        }
                                    }
                                    .onChange(of: reader.frame(in: .local)) { info in
                                        frame = info.size
                                        if let monitor = monitor {
                                            monitor(AKSUScrollViewMonitor(bounds: bounds, frame: frame))
                                        }
                                    }

                                InfiniteScrollHelper { info in
                                    bounds = info
                                    if let monitor = monitor {
                                        monitor(AKSUScrollViewMonitor(bounds: bounds, frame: frame))
                                    }
                                }
                            }
                        }
                    }
            }
        }
    }

    func monitor(_ monitor: @escaping (AKSUScrollViewMonitor) -> Void) -> Self {
        var new = self
        new.monitor = monitor
        return new
    }
}

private extension NSView {
    // 递归查找superview 直到找到类型为UIScrollView的父元素
    var clipView: NSClipView? {
        if let superview, superview is NSClipView {
            return superview as? NSClipView
        }
        return superview?.clipView
    }
}

private struct InfiniteScrollHelper: NSViewRepresentable {
    var monitor: ((CGRect) -> Void)? = nil

    func makeNSView(context: Context) -> NSView {
        let view = NSView(frame: .zero)
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.clear.cgColor

        DispatchQueue.main.async {
            guard let clipView = view.clipView else {
                return
            }

            clipView.postsBoundsChangedNotifications = true
            NotificationCenter.default.addObserver(
                context.coordinator,
                selector: #selector(Coordinator.scrollViewDidScroll),
                name: NSView.boundsDidChangeNotification,
                object: clipView
            )

            NotificationCenter.default.addObserver(
                context.coordinator,
                selector: #selector(Coordinator.scrollViewDidScroll),
                name: NSView.frameDidChangeNotification,
                object: clipView
            )
        }

        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(monitor: monitor)
    }

    class Coordinator: NSObject {
        var monitor: ((CGRect) -> Void)?

        init(monitor: ((CGRect) -> Void)? = nil) {
            self.monitor = monitor
        }

        @objc func scrollViewDidScroll(_ notification: Notification) {
            if let monitor = monitor {
                // 这里可以获取具体的滚动位置
                if let clipView = notification.object as? NSClipView {
                    monitor(clipView.bounds)
                }
            }
        }
    }
}

struct AKSUScrollView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AKSUScrollViewPreviewsView()
        }
        .frame(width: 600, height: 600)
    }
}

struct AKSUScrollViewPreviewsView: View {
    var body: some View {
        AKSUScrollView(.horizontal) {
            LazyHStack {
                ForEach(Array(0 ... 20), id: \.self) { key in
                    Text("\(key)")
                        .frame(width: 100)
                        .padding()
                        .foregroundStyle(.white)
                        .background(.green)
                        .cornerRadius(4)
                }
            }
        }
        .monitor { monitor in
        }
    }
}
