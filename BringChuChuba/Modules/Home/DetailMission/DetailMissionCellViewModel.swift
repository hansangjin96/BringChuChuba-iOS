//
//  DetailMissionCellViewModel.swift
//  BringChuChuba
//
//  Created by 홍다희 on 2021/01/21.
//

import Foundation
import RxSwift
import RxCocoa

class DetailMissionCellViewModel {

    let title = BehaviorRelay<String?>(value: nil)
    let detail = BehaviorRelay<String?>(value: nil)
    //    let image = BehaviorRelay<UIImage?>(value: nil)

    init(with title: String, detail: String) {
        //    image: UIImage?
        self.title.accept(title)
        self.detail.accept(detail)
    }

}
