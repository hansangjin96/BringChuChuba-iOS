//
//  CreateMissionViewModel.swift
//  BringChuChuba
//
//  Created by 한상진 on 2021/01/19.
//
import Photos

import RxCocoa
import RxSwift

final class ProfileViewModel: ViewModelType {
    // MARK: Structs
    struct Input {
        let profileTrigger: Observable<ControlEvent<UITapGestureRecognizer>.Element>
        let nickName: Driver<String>
        let saveTrigger: Driver<Void>
        let profileVC: ProfileViewController
    }

    struct Output {
        let error: Driver<Error>
        let profile: Driver<UIImage?>
        let saveEnabled: Driver<Bool>
        let dismiss: Driver<Void>
    }

    // MARK: Properties
    private let coordinator: SettingCoordinator
    private var alertTitle: String?

    // MARK: Initializers
    init(coordinator: SettingCoordinator) {
        self.coordinator = coordinator
    }

    // MARK: Methods
    func transform(input: Input) -> Output {
        let errorTracker = ErrorTracker()
        let error = errorTracker.asDriver()

        // 프로필 사진 클릭 -> 알럿뷰(선택) -> 앨범 권한 획득 -> 권한에 따라 사진 선택 -> 선택시 서버에 API 요청 -> dismiss

        let saveEnabled = input.nickName
            .map { nickname -> Bool in
                return !nickname.isEmpty && nickname != GlobalData.shared.nickname
            }

        let profile = input.profileTrigger
            .debug("profile tapped")
            .flatMapLatest { _ in
                return UIImagePickerController.rx.createWithParent(input.profileVC) { picker in
                    picker.sourceType = .photoLibrary
                    picker.allowsEditing = true
                }
                .debug("create parent")
                .flatMap { $0.rx.didFinishPickingMediaWithInfo.debug("media with info") }
                .debug("out of flatmap")
                .take(1)
            }
            .map { $0[.originalImage] as? UIImage }
            .debug("to image")
            .asDriverOnErrorJustComplete()

        // 프로필 사진이랑 닉네임 중에 바뀐거 저장 -> saveTrigger가 오면 request

        let dismiss = input.nickName
            .withLatestFrom(input.saveTrigger) { nickname, _ in
                return Network.shared.request(
                    with: .changeNickName(nickname: nickname),
                    for: Member.self
                )
            }
            .trackError(errorTracker)
            .asDriverOnErrorJustComplete()
            .mapToVoid()
            .do(onNext: coordinator.popToHome)
        
        return Output(
            error: error,
            profile: profile,
            saveEnabled: saveEnabled,
            dismiss: dismiss
        )
    }
}
