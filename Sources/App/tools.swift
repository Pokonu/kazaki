//
//  tools.swift
//  App
//  Полезные для работы инструменты (функции, классы, и пр. )
//
//  Created by veresk on 08.09.2018.
//

import Foundation
//
//  Поиск в сроке при помощи регулярного выражения
//
func matches(for regex: String, in text: String) throws -> [String] {
    let regex = try NSRegularExpression(pattern: regex, options: NSRegularExpression.Options.caseInsensitive)
    let results = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
    return results.compactMap {
        Range($0.range, in: text).map { String(text[$0]) }
    }
}

