//
//  MyVoteGeneralCell.swift
//  iconex_ios
//
//  Created by a1ahn on 22/08/2019.
//  Copyright © 2019 ICON Foundation. All rights reserved.
//

import UIKit

class MyVoteGeneralCell: UITableViewCell {
    @IBOutlet private weak var voteHeader: UILabel!
    @IBOutlet private weak var slideView: UIView!
    @IBOutlet private weak var votedWidth: NSLayoutConstraint!
    @IBOutlet private weak var votedLabel: UILabel!
    @IBOutlet private weak var availableLabel: UILabel!
    @IBOutlet private weak var votedICXLabel: UILabel!
    @IBOutlet private weak var availableICXLabel: UILabel!
    @IBOutlet private weak var votedValueLabel: UILabel!
    @IBOutlet private weak var availableValueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        slideView.corner(slideView.frame.height / 2)
        votedICXLabel.size12(text: "Voted (VP)", color: .gray77, weight: .light, align: .left)
        availableICXLabel.size12(text: "Available (VP)", color: .gray77, weight: .light, align: .left)
        voteHeader.size16(text: "Vote (0/10)", color: .gray77, weight: .light, align: .left)
        votedLabel.size14(text: "Voted -", color: .mint1, weight: .light, align: .left)
        availableLabel.size14(text: "Available -", color: .gray77, weight: .light, align: .right)
        votedValueLabel.size14(text: "-", color: .gray77, weight: .light, align: .right)
        availableValueLabel.size14(text: "-", color: .gray77, weight: .light, align: .right)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
