// Copyright © 2018 Stormbird PTE. LTD.

import UIKit

protocol ChooseTokenCardTransferModeViewControllerDelegate: class, CanOpenURL {
    func didChooseTransferViaMagicLink(token: TokenObject, tokenHolder: TokenHolder, in viewController: ChooseTokenCardTransferModeViewController)
    func didChooseTransferNow(token: TokenObject, tokenHolder: TokenHolder, in viewController: ChooseTokenCardTransferModeViewController)
    func didPressViewInfo(in viewController: ChooseTokenCardTransferModeViewController)
}

class ChooseTokenCardTransferModeViewController: UIViewController, TokenVerifiableStatusViewController {
    private let horizontalAdjustmentForLongMagicLinkButtonTitle = CGFloat(20)
    private let roundedBackground = RoundedBackground()
    private let header = TokensCardViewControllerTitleHeader()
    private let tokenRowView: TokenRowView & UIView
    private let buttonsBar = ButtonsBar(numberOfButtons: 2)
    private var viewModel: ChooseTokenCardTransferModeViewControllerViewModel
    private let tokenHolder: TokenHolder

    let config: Config
    var contract: String {
        return viewModel.token.contract
    }
    let paymentFlow: PaymentFlow
    weak var delegate: ChooseTokenCardTransferModeViewControllerDelegate?

    init(
            config: Config,
            tokenHolder: TokenHolder,
            paymentFlow: PaymentFlow,
            viewModel: ChooseTokenCardTransferModeViewControllerViewModel
    ) {
        self.config = config
        self.tokenHolder = tokenHolder
        self.paymentFlow = paymentFlow
        self.viewModel = viewModel

        let tokenType = OpenSeaNonFungibleTokenHandling(token: viewModel.token)
        switch tokenType {
        case .supportedByOpenSea:
            tokenRowView = OpenSeaNonFungibleTokenCardRowView()
        case .notSupportedByOpenSea:
            tokenRowView = TokenCardRowView()
        }

        super.init(nibName: nil, bundle: nil)

        updateNavigationRightBarButtons(isVerified: true)

        roundedBackground.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(roundedBackground)

        tokenRowView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tokenRowView)

        let stackView = [
            header,
            tokenRowView,
        ].asStackView(axis: .vertical, alignment: .center)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        roundedBackground.addSubview(stackView)

        let footerBar = UIView()
        footerBar.translatesAutoresizingMaskIntoConstraints = false
        footerBar.backgroundColor = .clear
        roundedBackground.addSubview(footerBar)

        footerBar.addSubview(buttonsBar)

        NSLayoutConstraint.activate([
			header.heightAnchor.constraint(equalToConstant: 90),

            tokenRowView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tokenRowView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            stackView.leadingAnchor.constraint(equalTo: roundedBackground.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: roundedBackground.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: roundedBackground.topAnchor),

            buttonsBar.leadingAnchor.constraint(equalTo: footerBar.leadingAnchor),
            buttonsBar.trailingAnchor.constraint(equalTo: footerBar.trailingAnchor),
            buttonsBar.topAnchor.constraint(equalTo: footerBar.topAnchor),
            buttonsBar.heightAnchor.constraint(equalToConstant: ButtonsBar.buttonsHeight),

            footerBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footerBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footerBar.topAnchor.constraint(equalTo: view.layoutGuide.bottomAnchor, constant: -ButtonsBar.buttonsHeight - ButtonsBar.marginAtBottomScreen),
            footerBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ] + roundedBackground.createConstraintsWithContainer(view: view))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func generateMagicLinkTapped() {
        delegate?.didChooseTransferViaMagicLink(token: viewModel.token, tokenHolder: tokenHolder, in: self)
    }

    @objc func transferNowTapped() {
        delegate?.didChooseTransferNow(token: viewModel.token, tokenHolder: tokenHolder, in: self)
    }

    func showInfo() {
        delegate?.didPressViewInfo(in: self)
    }

    func showContractWebPage() {
        delegate?.didPressViewContractWebPage(forContract: contract, in: self)
    }

    func configure(viewModel newViewModel: ChooseTokenCardTransferModeViewControllerViewModel? = nil) {
        if let newViewModel = newViewModel {
            viewModel = newViewModel
        }
        updateNavigationRightBarButtons(isVerified: isContractVerified)

        view.backgroundColor = viewModel.backgroundColor

        header.configure(title: viewModel.headerTitle)

        tokenRowView.configure(tokenHolder: tokenHolder)

        tokenRowView.stateLabel.isHidden = true

        buttonsBar.configure()

        let generateMagicLinkButton = buttonsBar.buttons[0]
        generateMagicLinkButton.setTitle(R.string.localizable.aWalletTokenTransferModeMagicLinkButtonTitle(), for: .normal)
        generateMagicLinkButton.addTarget(self, action: #selector(generateMagicLinkTapped), for: .touchUpInside)

        let transferNowButton = buttonsBar.buttons[1]
        transferNowButton.setTitle("    \(R.string.localizable.aWalletTokenTransferModeNowButtonTitle())    ", for: .normal)
        transferNowButton.addTarget(self, action: #selector(transferNowTapped), for: .touchUpInside)

        //Button fonts have to be smaller because the button title is too long
        generateMagicLinkButton.titleLabel?.font = viewModel.buttonFont
        transferNowButton.titleLabel?.font = viewModel.buttonFont
    }
}
