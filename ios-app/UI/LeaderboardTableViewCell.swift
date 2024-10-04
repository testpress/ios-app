//
//  LeaderboardTableViewCell.swift
//  ios-app
//
//  Copyright © 2017 Testpress. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit
import CourseKit

class LeaderboardTableViewCell: UITableViewCell {
    
    @IBOutlet weak var rank: UILabel!
    @IBOutlet weak var contentViewCell: UIView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var trophiesCount: UILabel!
    @IBOutlet weak var differenceCount: UILabel!
    @IBOutlet weak var differenceImage: UIImageView!
    
    func initCell(reputation: Reputation, rank: Int, userId: Int?) {
        
        self.rank.text = String(rank)
        userImage.kf.setImage(with: URL(string: reputation.user.mediumImage!),
                              placeholder: Images.PlaceHolder.image)
        
        userName.text = String(reputation.user.displayName)
        trophiesCount.text = String(reputation.trophiesCount)
        if userId == reputation.user.id {
            contentViewCell.backgroundColor = Colors.getRGB(Colors.BLUE, alpha: 0.1)
        } else {
            contentViewCell.backgroundColor = UIColor.white
        }
    }
}
