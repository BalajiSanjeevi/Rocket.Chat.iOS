//
//  BaseTextAttachmentMessageCell.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 16/10/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

class BaseTextAttachmentMessageCell: BaseMessageCell {
    weak var delegate: ChatMessageCellProtocol?

    var subtitleHeightConstraint: NSLayoutConstraint!
    var emptySubtitleHeightConstraint: NSLayoutConstraint!
    var avatarLeadingInitialConstant: CGFloat = 0
    var avatarWidthInitialConstant: CGFloat = 0
    var textContainerLeadingInitialConstant: CGFloat = 0
    var statusViewLeadingInitialConstant: CGFloat = 0
    var statusViewWidthInitialConstant: CGFloat = 0
    var fieldsStackViewLeadingInitialConstant: CGFloat = 0
    var fieldsStackViewTrailingInitialConstant: CGFloat = 0
    var textContainerTrailingInitialConstant: CGFloat = 0
    var fieldsStackTopInitialConstant: CGFloat = 0
    var fieldsStackHeightInitialConstant: CGFloat = 0
    var subtitleHeightInitialConstant: CGFloat = 0
    var subtitleTopInitialConstant: CGFloat = 0
    var readReceiptWidthInitialConstant: CGFloat = 0
    var readReceiptTrailingInitialConstant: CGFloat = 0
    var fieldLabelWidth: CGFloat {
        return
            messageWidth -
            avatarLeadingInitialConstant -
            avatarWidthInitialConstant -
            textContainerLeadingInitialConstant -
            statusViewLeadingInitialConstant -
            statusViewWidthInitialConstant -
            fieldsStackViewLeadingInitialConstant -
            fieldsStackViewTrailingInitialConstant -
            textContainerTrailingInitialConstant -
            readReceiptWidthInitialConstant -
            readReceiptTrailingInitialConstant
    }

    func configure(stackView: UIStackView) -> CGFloat {
        guard let viewModel = viewModel?.base as? TextAttachmentChatItem else {
            return 0
        }

        let maxSize = CGSize(width: fieldLabelWidth, height: .greatestFiniteMagnitude)
        var stackViewHeight: CGFloat = 0
        var attachmentFieldViews: [AttachmentFieldView] = []

        reset(stackView: stackView)

        for attachmentField in viewModel.fields {
            guard let attachmentFieldView = AttachmentFieldView.instantiateFromNib() else {
                continue
            }

            let attributedValue = NSMutableAttributedString(string: attachmentField.value).transformMarkdown(with: theme)
            attachmentFieldView.field.text = attachmentField.title
            attachmentFieldView.value.attributedText = attributedValue

            let valueTextHeight = attachmentFieldView.value.sizeThatFits(maxSize).height
            let fieldViewHeight = attachmentFieldView.fieldHeightConstraint.constant +
                attachmentFieldView.valueTopConstraint.constant +
                valueTextHeight

            stackViewHeight += fieldViewHeight
            attachmentFieldView.contentSize = CGSize(width: fieldLabelWidth, height: fieldViewHeight)
            attachmentFieldView.invalidateIntrinsicContentSize()
            attachmentFieldViews.append(attachmentFieldView)
        }

        stackViewHeight += stackView.spacing * CGFloat(attachmentFieldViews.count - 1)

        attachmentFieldViews.forEach { view in
            stackView.addArrangedSubview(view)
        }

        return stackViewHeight
    }

    func reset(stackView: UIStackView) {
        stackView.arrangedSubviews.forEach { subview in
            stackView.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
    }

    @objc func didTapTextContainerView() {
        guard
            let viewModel = viewModel,
            let chatItem = viewModel.base as? TextAttachmentChatItem
        else {
            return
        }

        messageSection?.collapsibleItemsState[viewModel.differenceIdentifier] = !chatItem.collapsed
        delegate?.viewDidCollapseChange(viewModel: viewModel)
    }
}

extension BaseTextAttachmentMessageCell: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}
