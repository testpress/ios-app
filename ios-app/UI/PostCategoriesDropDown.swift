//
//  PostCategoriesDropDown.swift
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

import DropDown
import UIKit
import CourseKit

class PostCategoriesDropDown {
    
    var titleButton: UIButton!
    var dropDown: DropDown!
    var categories: [CourseKit.Category]
    
    init(category: CourseKit.Category? = nil, categories: [CourseKit.Category], navigationItem: UINavigationItem) {
        self.categories = categories
        titleButton = UIButton(type: .system)
        let image = UIImage(named: "ic_arrow_drop_down")
        titleButton.setImage(image, for: .normal)
        titleButton.tintColor = .white
        
        if category != nil {
            titleButton.setTitle(category!.name, for: .normal)
        } else {
            titleButton.setTitle(Strings.ARTICLES, for: .normal)
        }
        
        let instituteSettings = DBManager<InstituteSettings>().getResultsFromDB()[0]
        titleButton.setTitle(instituteSettings.postsLabel, for: .normal)

        titleButton.setTitleColor(.white, for: .normal)
        titleButton.addTarget(self, action: #selector(self.onClickDropDown), for: .touchUpInside)
        titleButton.sizeToFit()
        navigationItem.titleView = titleButton
        
        dropDown = DropDown()
        dropDown.anchorView = navigationItem.titleView
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.selectionBackgroundColor = Colors.getRGB(Colors.BLUE, alpha: 0.1)
        dropDown.offsetFromWindowBottom = 100
        var categoriesSlug = [String]()
        for category in categories {
            categoriesSlug.append(category.slug)
        }
        dropDown.dataSource = categoriesSlug
        dropDown.cellConfiguration = { (index, item) in
            return self.getCategory(withSlug: item, from: self.categories)!.name
        }
    }
    
    func getCategory(withSlug slug: String, from categories: [CourseKit.Category]) -> CourseKit.Category? {
        for category in categories {
            if category.slug == slug {
                return category
            }
        }
        return nil
    }
    
    @objc func onClickDropDown() {
        dropDown.show()
    }
}
