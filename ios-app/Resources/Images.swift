//
//  Images.swift
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

enum Images: String {
    case TestpressNoWifi = "testpress_no_wifi"
    case TestpressAlertWarning = "testpress_alert_warning"
    case ExamsFlatIcon = "exams_flat_icon"
    case ProfileImagePlaceHolder = "profile_image_place_holder"
    case BackButton = "ic_navigate_before_36pt"
    case CloseButton = "ic_close"
    case PlaceHolder = "placeholder_icon"
    case LearnFlatIcon = "learn_flat_icon"
    case NewsFlatIcon = "news_flat_icon"
    case DiscussionFlatIcon = "discussion_flat_icon"
    case SuccessTick = "success_tick"
    case TimeIcon = "time_icon"
    case ViewsIcon = "views_icon"
    case NavigateNext = "ic_navigate_next"
    case AnalyticsFlatIcon = "analytics_flat_icon"
    case ExamAddedIcon = "exam_added_icon"
    case FileDownloadIcon = "file_download_icon"
    case PostAdded = "post_added"
    case VideoAddedIcon = "video_added_icon"
    case ExamAttemptedIcon = "exam_attempted_icon"
    
    var image: UIImage {
        return UIImage(asset: self)
    }
}

extension UIImage {
    convenience init!(asset: Images) {
        self.init(named: asset.rawValue)
    }
}
