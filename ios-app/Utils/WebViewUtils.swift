//
//  WebViewUtils.swift
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

import Foundation

class WebViewUtils {
    
    static func getTestEngineHeader() -> String {
        return "<script src='TestEngine.js'></script>"
    }
    
    static func getRadioButtonInitializer(selectedOption: Int) -> String {
        return "initRadioGroup(\(selectedOption));"
    }
    
    static func getCheckBoxInitializer(selectedOptions: [Int]) -> String {
        return "initCheckBoxGroup(\(selectedOptions));"
    }
    
    public static func getHeader() -> String {
        var header = "<!DOCTYPE html><meta name='viewport' content='width=device-width, " +
        "initial-scale=1, maximum-scale=1, user-scalable=no' />"
        header += "<link rel='stylesheet' type='text/css' href='questions_typebase.css' />"
        header += "<style> img { display: inline; height: auto !important; width: auto !important; "
            + "max-width: 100%; } </style>"
        header += "<link rel='stylesheet' href='katex/katex.min.css' />"
        header += "<script src='katex/katex.min.js'></script>"
        header += "<script src='katex/contrib/auto-render.min.js'></script>"
        return header
    }
    
    public static func getRadioButtonOptionWithTags(optionText: String, id: Int) -> String {
        var html = "<tr>"
        html += "   <td id='\(id)' onclick='onRadioOptionClick(this)' class='option-item " +
                            "table-without-border'>"
        html += "       <div name='\(id)' class='radio-button-unchecked'></div>"
        html += "       <div>\(optionText)</div>"
        html += "   </td>"
        html += "</tr>"
        return html
    }
    
    public static func getCheckBoxOptionWithTags(optionText: String, id: Int) -> String {
        var html = "<tr>"
        html += "   <td id='\(id)' onclick='onCheckBoxOptionClick(this)' class='option-item " +
                            "table-without-border'>"
        html += "       <div name='\(id)' class='checkbox-unchecked'></div>"
        html += "       <div>\(optionText)</div>"
        html += "   </td>"
        html += "</tr>"
        return html
        
    }
    
    public static func getOptionWithTags(optionText: String, index: Int, color: String?) -> String {
        var html = "\n<div class='review-option-item'>"
        if color == nil {
            html += "<div class='alphabetical-option-ring-general'>"
        } else {
            html += "<div class='alphabetical-option-ring-attempted' style='background-color:" +
                color! + "'>"
        }
        html += "\(Character(UnicodeScalar(65 + index)!))</div>"
        html += "<div>" + optionText + "</div>"
        html += "</div>"
        return html
    }
    
    public static func getCorrectAnswerIndexWithTags(index: Int) -> String {
        return "\n<div class='alphabetical-option-ring-general'>" +
                "\(Character(UnicodeScalar(65 + index)!))</div>"
    }
    
    public static func getHeadingTags(headingText: String) -> String {
        return "<div class='review-heading'>" + headingText + "</div>"
    }

}
