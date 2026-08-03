//
//  AKSUTableController.swift
//  AKSwiftUI
//
//  AKSUTable 精准更新控制器
//

import SwiftUI

public class AKSUTableController<Value: Identifiable & Equatable>: ObservableObject {
    public enum Op {
        case upsert([Value])
        case remove([Value.ID])
    }

    public enum ResolvedOp {
        case update(index: Int)
        case remove(index: Int)
        case insert(index: Int)
    }

    var pendingOps: [Op] = []
    public var resolvedOps: [ResolvedOp] = []
    var skipOnChange = false

    /// 更新已有行，不存在则追加到末尾（upsert）
    public func update(_ values: [Value]) {
        pendingOps.append(.upsert(values))
        objectWillChange.send()
    }

    /// 按 id 删除行
    public func remove(_ ids: [Value.ID]) {
        pendingOps.append(.remove(ids))
        objectWillChange.send()
    }
}
