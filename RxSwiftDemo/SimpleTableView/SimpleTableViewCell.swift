//
//  SimpleTableViewCell.swift
//  RxSwiftDemo
//

import UIKit
import SnapKit

final class SimpleTableViewCell: UITableViewCell {
    static let reuseIdentifier = "SimpleTableViewCell"

    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let detailLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createUI()
        layoutUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with item: SimpleTableItem) {
        iconView.image = UIImage(systemName: item.iconName)
        titleLabel.text = item.title
        detailLabel.text = item.detail
    }

    private func createUI() {
        accessoryType = .disclosureIndicator

        iconView.tintColor = .systemBlue
        iconView.contentMode = .scaleAspectFit
        contentView.addSubview(iconView)

        titleLabel.font = .systemFont(ofSize: 17, weight: .medium)
        titleLabel.textColor = .label
        contentView.addSubview(titleLabel)

        detailLabel.font = .systemFont(ofSize: 14)
        detailLabel.textColor = .secondaryLabel
        detailLabel.numberOfLines = 0
        contentView.addSubview(detailLabel)
    }

    private func layoutUI() {
        iconView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.size.equalTo(32)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalTo(iconView.snp.trailing).offset(12)
            make.trailing.equalToSuperview().inset(16)
        }

        detailLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.leading.trailing.equalTo(titleLabel)
            make.bottom.equalToSuperview().inset(12)
        }
    }
}
