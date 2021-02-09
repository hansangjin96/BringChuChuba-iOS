//
//  HomeViewController.swift
//  BringChuChuba
//
//  Created by 홍다희 on 2021/01/04.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit
import Then

final class HomeViewController: UIViewController {
    // MARK: Properties
    private let viewModel: HomeViewModel!
    private let disposeBag: DisposeBag = DisposeBag()

    // MARK: UI Components
    private lazy var segmentControl = UISegmentedControl(
        items: Mission.Status.allCases.map { $0.title }
    ).then {
        $0.selectedSegmentIndex = 0
        $0.autoresizingMask = .flexibleWidth
        navigationItem.titleView = $0
    }

    private lazy var activityIndicator = UIActivityIndicatorView().then {
        // color constants로 뺴기
        $0.color = UIColor(red: 0.25, green: 0.72, blue: 0.85, alpha: 1.0)
    }

    private lazy var tableView = UITableView(frame: .zero).then {
        $0.contentInsetAdjustmentBehavior = .never
        $0.separatorStyle = .none
        $0.allowsSelection = false
        $0.rowHeight = 335
        $0.refreshControl = UIRefreshControl()
        $0.register(
            HomeTableViewCell.self,
            forCellReuseIdentifier: HomeTableViewCell.reuseIdentifier()
        )
    }

    private lazy var createBarButtonItem = UIBarButtonItem().then {
        $0.title = "Home.Navigation.CreateButton.Title".localized
        $0.style = .done
    }

    // MARK: Initializers
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()

        bindViewModel()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    // MARK: Binds
    private func bindViewModel() {
        assert(viewModel.isSome)

        let viewWillAppear = rx
            .sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .mapToVoid()
            .asDriverOnErrorJustComplete()

        let pull = tableView.refreshControl!.rx
            .controlEvent(.valueChanged)
            .asDriver()

        let input = HomeViewModel.Input(
            trigger: Driver.merge(viewWillAppear, pull),
            segmentSelected: segmentControl.rx.selectedSegmentIndex
                .debug("selectedSegment -->")
                .map { Mission.Status.allCases[$0] }
                .asDriverOnErrorJustComplete(),
            createMissionTrigger: createBarButtonItem.rx.tap.asDriver()
        )

        let output = viewModel.transform(input: input)

        [output.items
            .drive(tableView.rx.items(
                cellIdentifier: HomeTableViewCell.reuseIdentifier(),
                cellType: HomeTableViewCell.self
            )) { _, viewModel, cell in
                cell.bind(with: viewModel)
            },
         output.fetching
            .drive(tableView.refreshControl!.rx.isRefreshing),
         output.createMission
            .drive()
         ]
        .forEach { $0.disposed(by: disposeBag) }
    }

    // MARK: Set UIs
    private func setupUI() {
        navigationItem.title = "Home.Navigation.Title".localized
        navigationItem.rightBarButtonItem = createBarButtonItem // TODO: floating button

        view.addSubview(tableView)
        view.addSubview(activityIndicator)

        tableView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(view.safeArea.top)
            make.bottom.equalTo(view.safeArea.bottom)
        }

        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
// MARK: Previews

// #if canImport(SwiftUI) && DEBUG
// import SwiftUI
// @available(iOS 13.0, *)
// struct HomeVCRepresentable: UIViewControllerRepresentable {
// func makeUIViewController(context: Context) -> HomeViewController {
// HomeViewController(viewModel: HomeViewModel(
// coordinator: HomeCoordinator(navigationController: UINavigationController()))
// )
// }
//
// func updateUIViewController(_ uiViewController: HomeViewController, context: Context) {
// }
// }
//
// @available(iOS 13.0, *)
// struct HomeVCPreview: PreviewProvider {
// static var previews: some View {
// HomeVCRepresentable()
// }
// }
// #endif