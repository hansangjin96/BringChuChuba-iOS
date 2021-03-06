//
//  MyMissionCellViewModel.swift
//  BringChuChuba
//
//  Created by 홍다희 on 2021/01/31.
//

import Foundation

import RxCocoa
import RxSwift

final class MyMissionCellViewModel: ViewModelType {
    // MARK: Structs
    struct Input {
        let deleteTrigger: Driver<Void>
        let completeTrigger: Driver<Void>
    }
    
    struct Output {
        let deleted: Driver<Void>
        let completed: Driver<Void>
    }
    
    // MARK: Properties
    let title: String
    let expireAt: String
    let contractorName: String
    let status: Mission.Status
    let mission: Mission
    
    // MARK: Initializers
    init (with mission: Mission) {
        self.mission = mission
        self.title = mission.title
        self.expireAt = mission.expireAt
        self.contractorName = mission.contractor?.id ?? "" // nickname
        self.status = mission.status
    }
    
    // MARK: Methods
    func transform(input: Input) -> Output {
        let errorTracker = ErrorTracker()

        let deleted = input.deleteTrigger
            .flatMapLatest { [weak self] _ -> Driver<Void> in
                guard let self = self,
                      let missionUid = Int(self.mission.id) else { return .empty() }

                return Network.shared.request(
                    with: .deleteMission(missionUid: missionUid),
                    for: Result.self
                )
                .trackError(errorTracker)
                .mapToVoid()
                .share()
                .asDriverOnErrorJustComplete()
            }

        let completed = input.completeTrigger
            .flatMapLatest { [weak self] _ -> Driver<Void> in
                guard let self = self,
                      let missionUid = Int(self.mission.id) else { return .empty() }
                
                return Network.shared.request(
                    with: .completeMission(missionUid: missionUid),
                    for: Mission.self
                )
                .trackError(errorTracker)
                .mapToVoid()
                .share()
                .asDriverOnErrorJustComplete()
            }
        
        return Output(
            deleted: deleted,
            completed: completed
        )
    }
}
