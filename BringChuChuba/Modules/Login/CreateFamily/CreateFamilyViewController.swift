//
//  ViewController.swift
//  BringChuChuba
//
//  Created by 홍다희 on 2021/01/14.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

final class CreateFamilyViewController: UIViewController {
    // MARK: - Properties
    private var viewModel: CreateFamilyViewModel
    private let disposeBag = DisposeBag()

    // MARK: - UI Components
    private lazy var familyNameTextField = UITextField().then {
        $0.placeholder = "Enter your family name"
        $0.autocapitalizationType = .none
        $0.backgroundColor = .systemGray6
        $0.layer.cornerRadius = 5
        $0.layer.borderWidth = 0.5
        $0.layer.borderColor = UIColor.systemGray.cgColor
        // 왼쪽 inset padding 추가
    }

    private lazy var createFamilyButton = UIButton().then {
        $0.setTitle("Create new family", for: .normal)
        $0.backgroundColor = UIColor.systemBlue
        $0.layer.cornerRadius = 5
    }

    private lazy var joinFamilyButton = UIButton().then {
        let attributedString = NSAttributedString(
            string: NSLocalizedString("or Find and join a family", comment: ""),
            attributes: [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16.0),
                NSAttributedString.Key.foregroundColor: UIColor.systemBlue,
                NSAttributedString.Key.underlineStyle: 1.0
            ])
        $0.setAttributedTitle(attributedString, for: .normal)
        $0.layer.cornerRadius = 5
    }

    private lazy var stackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 10
    }

    // MARK: - Initializers

    init(viewModel: CreateFamilyViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
    }

    // MARK: - Private Method
    private func setupUI() {
        title = "Create new Family"
        navigationItem.hidesBackButton = true
        view.addSubview(stackView)
        stackView.addArrangedSubview(familyNameTextField)
        stackView.addArrangedSubview(createFamilyButton)
        stackView.addArrangedSubview(joinFamilyButton)

        view.backgroundColor = .systemBackground

        stackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.centerY.equalTo(view)
        }

        familyNameTextField.snp.makeConstraints { make in
            make.height.equalTo(joinFamilyButton)
        }
    }

    private func bind() {
        let input = CreateFamilyViewModel.Input(
            familyName: familyNameTextField.rx.text.orEmpty.asDriver(),
            createTrigger: createFamilyButton.rx.tap.asDriver(),
            joinTrigger: joinFamilyButton.rx.tap.asDriver()
        )

        let output = viewModel.transform(input: input)

        [output.createEnable
            .drive(createFamilyButton.rx.isEnabled),
         output.create
            .drive(),
         output.toJoin
            .drive()
        ].forEach { $0.disposed(by: disposeBag) }
    }
}