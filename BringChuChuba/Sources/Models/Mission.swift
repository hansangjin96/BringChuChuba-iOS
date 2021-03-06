//
//  Mission.swift
//  BringChuChuba
//
//  Created by 홍다희 on 2021/01/04.
//

import Foundation

struct Mission: Decodable {
    let client: Member
    let contractor: Member?
    let createdAt: String
    let description: String?
    let expireAt: String
    let familyId: String
    let id: String
    let modifiedAt: String
    let reward: String
    let status: Status
    let title: String
}

struct MissionDetails: Hashable {
    let description: String
    let expireAt: String
    let familyId: String
    let reward: String
    let title: String
}

extension Mission {
    enum Status: String, Decodable, CaseIterable {
        case todo
        case inProgress
        case complete

        var title: String {
            switch self {
            case .todo: return "모집중"
            case .inProgress: return "진행중"
            case .complete: return "완료됨"
            }
        }
    }
}
