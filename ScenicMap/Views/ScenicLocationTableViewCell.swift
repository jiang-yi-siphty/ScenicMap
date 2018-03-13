//
//  ScenicLocationTableViewCell.swift
//  ScenicMap
//
//  Created by Yi Jiang on 13/3/18.
//  Copyright © 2018 Siphty. All rights reserved.
//

import UIKit

class ScenicLocationTableViewCell: UITableViewCell {
    @IBOutlet weak var ScenicName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    static func nib() -> UINib {
        return UINib(nibName: String(describing: self), bundle: nil)
    }

    static func reuseId() -> String {
        return String(describing: self)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func configureCell(_ scenic: Location?) {
        guard let scenic = scenic else { return }
        ScenicName.text = scenic.name
    }
    
}
