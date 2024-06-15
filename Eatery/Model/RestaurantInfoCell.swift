//
//  RestaurantInfoCell.swift
//  Eatery
//
//  Created by Test on 11.06.24.
//

import UIKit
import SnapKit

class RestaurantInfoCell: UITableViewCell {
    
    // MARK: - Constants

    static let identifier = "UITableViewCell"
    
    private let iconContainer: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 10
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let icon = UIImageView()
        icon.tintColor = .white
        icon.contentMode = .scaleAspectFit
        return icon
    }()
    
    private let detailLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 6
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(iconContainer)
        iconContainer.addSubview(iconImageView)
        contentView.addSubview(detailLabel)
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Functions
    
    private func setConstraints() {
        iconContainer.snp.makeConstraints { make in
            make.top.equalToSuperview().offset((contentView.frame.height - 30) / 2)
            make.leading.equalToSuperview().offset(10)
            make.height.equalTo(30)
            make.width.equalTo(30)
        }
        
        iconImageView.snp.makeConstraints { make in
            make.center.equalTo(iconContainer.snp.center)
            make.height.equalTo(20)
            make.width.equalTo(20)
        }
        
        detailLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconContainer.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.height.equalTo(50)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        iconContainer.backgroundColor = nil
        iconImageView.image = nil
        detailLabel.text = nil
    }
    
    func configureRestaurantInfoCell(with model: RestaurantDetail) {
        iconContainer.backgroundColor = model.iconBackgroundColor
        iconImageView.image = model.icon
        detailLabel.text = model.detail
    }
}
