//
//  cell.swift
//  Free Food App
//
//  Created by Joe Peplowski on 2015-05-13.
//  Copyright (c) 2015 Joseph Peplowski. All rights reserved.
//

import UIKit

class postTableCell: UITableViewCell {
    @IBOutlet weak var statusImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var lastConfirmedLabel: UILabel!
    @IBOutlet weak var postedLabel: UILabel!
}

class voteTableCell: UITableViewCell {
    @IBOutlet weak var voteCellLabel: UILabel!
    @IBOutlet weak var voteCellImage: UIImageView!
}