//
//  DoingMissionViewController.swift
//  BringChuChuba
//
//  Created by 한상진 on 2021/01/19.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit
import Then

final class MyMissionViewController: UIViewController {
    // MARK: Properties
    var viewModel: MyMissionViewModel!
    private var status: String?
    private let disposeBag = DisposeBag()

    // MARK: UI Components
    private lazy var footerView: UIView = UIView(frame: .zero).then { footer in
        footer.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
    }

    private lazy var tableView: UITableView = UITableView().then { table in
        // 50 Constant로 빼기
        table.rowHeight = 100
        table.register(MyMissionTableViewCell.self,
                       forCellReuseIdentifier: MyMissionTableViewCell.reuseIdentifier())
        table.allowsSelection = false
    }

    // MARK: Initializers
    init(viewModel: MyMissionViewModel, status: String? = nil) {
        self.viewModel = viewModel
        self.status = status
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()

        bindViewModel()
        setupUI()
    }

    // MARK: Binds
    private func bindViewModel() {
        assert(viewModel.isSome)

        let viewWillAppear = rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .mapToVoid()
            .asDriverOnErrorJustComplete()

        let input = MyMissionViewModel.Input(status: status,
                                             appear: viewWillAppear)

        let output = viewModel.transform(input: input)

        [output.missions
             .drive(tableView.rx.items(
                     cellIdentifier: MyMissionTableViewCell.reuseIdentifier(),
                     cellType: MyMissionTableViewCell.self)
             ) { _, viewModel, cell in
                cell.bind(with: viewModel)
             },
         output.error
            .drive(errorBinding)
        ].forEach { $0.disposed(by: disposeBag) }
    }

    private var errorBinding: Binder<Error> {
        return Binder(self, binding: { _, error in
            print(error.localizedDescription)
        })
    }

    // MARK: Set UIs
    private func setupUI() {
        view.addSubview(tableView)

        tableView.snp.makeConstraints { make in
            make.top
                .bottom
                .leading
                .trailing
                .equalToSuperview()
        }
    }
}