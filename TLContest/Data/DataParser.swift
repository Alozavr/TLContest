//
//  DataParser.swift
//  TLContest
//
//  Created by Dmitry Grebenschikov on 11/03/2019.
//  Copyright © 2019 dd-team. All rights reserved.
//

import Foundation
import UIKit

enum ParseErrors: Error {
    case noSuchFile
}

fileprivate extension UIColor {
    static func colorWith(hexString: String, alpha: CGFloat = 1.0) -> UIColor {
        
        // Convert hex string to an integer
        let hexint = Int(UIColor.intFromHexString(hexStr: hexString))
        let red = CGFloat((hexint & 0xff0000) >> 16) / 255.0
        let green = CGFloat((hexint & 0xff00) >> 8) / 255.0
        let blue = CGFloat((hexint & 0xff) >> 0) / 255.0
        let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        return color
    }
    
    private static func intFromHexString(hexStr: String) -> UInt32 {
        var hexInt: UInt32 = 0
        let scanner: Scanner = Scanner(string: hexStr)
        scanner.charactersToBeSkipped = CharacterSet(charactersIn: "#")
        scanner.scanHexInt32(&hexInt)
        return hexInt
    }
}

class DataParser {
    
    struct DataElement: Decodable {
        enum CodingKeys: String, CodingKey {
            case columns
            case names
            case colors
            case types
        }
        
        let columns: [[Any]]
        let names: [String: String]
        let colors: [String: String]
        let types: [String: String]
        
        init(from decoder: Decoder) throws {
            let decoderContainer = try decoder.container(keyedBy: CodingKeys.self)
            names = try decoderContainer.decode([String: String].self, forKey: .names)
            colors = try decoderContainer.decode([String: String].self, forKey: .colors)
            types = try decoderContainer.decode([String: String].self, forKey: .types)
            
            var columnsArray = try decoderContainer.nestedUnkeyedContainer(forKey: .columns)
            var tempArray = [[Any]]()
            for _ in 0 ..< (columnsArray.count ?? 0) {
                guard var elArray = try? columnsArray.nestedUnkeyedContainer() else { continue }
                var tempColumn = [Any]()
                while !elArray.isAtEnd {
                    let name = try? elArray.decode(String.self)
                    if let name = name {
                        tempColumn.append(name)
                    }
                    else {
                        let ts = try? elArray.decode(Int.self)
                        if let ts = ts {
                            tempColumn.append(ts)
                        }
                    }
                }
                tempArray.append(tempColumn)
            }
            
            columns = tempArray
        }
    }
    
    func parseFile(named: String) throws -> [Chart] {
        guard let url = Bundle.main.url(forResource: named, withExtension: ".json") else {
            throw ParseErrors.noSuchFile
        }
        let data = try Data(contentsOf: url)
        
        let initialArray = try JSONDecoder().decode([DataElement].self, from: data)
        
        return initialArray.map({ (element) -> Chart? in
            guard let nameOfX = element.types.first(where: { $0.value == "x" })?.key else { return nil }
            guard let xColumn = element.columns.first(where: { ($0.first as? String) == nameOfX }) else { return nil }
            let dates = xColumn.dropFirst().compactMap({ $0 as? Int }).map({ timestamp -> Date? in
                guard let interval = TimeInterval(exactly: timestamp) else { return nil }
                return Date(timeIntervalSince1970: interval)
            }).compactMap({ $0 })
            
            let linesNames = element.types.filter({ $0.value == "line" }).map({ $0.key })
            let lines = linesNames.map { lineName -> Line? in
                guard let linePositions = element.columns
                    .first(where: { ($0.first as? String) == lineName })?
                    .dropFirst()
                    .compactMap({ $0 as? Int }),
                    linePositions.count == dates.count else {
                        return nil
                }
                guard let colorString = element.colors[lineName] else { return nil }
                let color = UIColor.colorWith(hexString: colorString)
                return Line(id: UUID().uuidString, name: lineName, values: linePositions, color: color, isVisible: true)
            }.compactMap({ $0 })
            guard lines.count > 0 else { return nil }
            return Chart.init(dateAxis: dates, lines: lines)
        }).compactMap({ $0 })
    }
    
    
}
