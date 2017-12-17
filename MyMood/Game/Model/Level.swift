//
//  Level.swift
//  Check In
//
//  Created by Юрий Бондарчук on 15/12/2017.
//  Copyright © 2017 Samantha Parola. All rights reserved.
//

import Foundation

let NumColumns = 9
let NumRows = 9

class Level {
    var cookies = Array2D<Cookie>(columns: NumColumns, rows: NumRows)
    
    private var tiles = Array2D<Tile>(columns: NumColumns, rows: NumRows)
    var possibleSwaps = Set<Swap>()
    
    init(filename: String) {
        // early return if the filename is incorrect
        guard let dictionary = Dictionary<String, AnyObject>.loadJSONFromBundle(filename: filename) else {
            return
        }
        
        guard let tilesArray = dictionary["tiles"] as? [[Int]] else { return }
        
        for (row, rowArray) in tilesArray.enumerated() {
            let tileRow = NumRows - row - 1
            for (column, value) in rowArray.enumerated() {
                if value == 1 {
                    tiles[column, tileRow] = Tile()
                }
            }
        }
        
    }
    
    
    func cookieAt(column: Int, row: Int) -> Cookie? {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        return cookies[column, row]
    }
    
    func tileAt(column: Int, row: Int) -> Tile? {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        return tiles[column, row]
    }
    
    func recreateCookies() -> Set<Cookie> {
        var set = Set<Cookie>()
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                if tiles[column, row] != nil && cookies[column, row] != nil {
                    set.insert(cookies[column, row]!)
                }
            }
        }
        return set
    }
    
    func printCookies() {
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                if tiles[column, row] != nil && cookies[column, row] != nil {
                    let t = cookies[column, row]!.cookieType.spriteName
                    print("\(row), \(column) = \(t)")
                } else {
                    print("\(row), \(column) = nil")
                }
            }
        }
    }
    
    private func createInitialCookies() -> Set<Cookie> {
        var set = Set<Cookie>()
        
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                if tiles[column, row] != nil {
                    // smartly fill up the cookies board
                    var cookieType: CookieType
                    
                    repeat {
                        cookieType = CookieType.random()
                    } while (column >= 2 &&
                        cookies[column - 1, row]?.cookieType == cookieType &&
                        cookies[column - 2, row]?.cookieType == cookieType)
                        || (row >= 2 &&
                            cookies[column, row - 1]?.cookieType == cookieType &&
                            cookies[column, row - 2]?.cookieType == cookieType)
                    
                    // create a cookie of that type with current coordinates in the grid
                    let cookie = Cookie(column: column, row: row, cookieType: cookieType)
                    // set the cookie in the correct place in the grid
                    cookies[column, row] = cookie
                    // add the cookie to the set
                    set.insert(cookie)
                }
            }
        }
        return set
    }
    
    func shuffle() -> Set<Cookie> {
        var set: Set<Cookie>
        repeat {
            set = createInitialCookies()
            detectPossibleSwaps()
            print("possible swaps: \(possibleSwaps)")
        } while possibleSwaps.count == 0
        
        return set
    }
    
    func detectPossibleSwaps() {
        var set = Set<Swap>()
        
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                if let cookie = cookies[column, row] {
                    // is it possible to swap tis cookie with the one on the right?
                    if column < NumColumns - 1 {
                        // if there is no tile, there is no cookie there
                        if let other = cookies[column + 1, row] {
                            //swap them
                            cookies[column, row] = other
                            cookies[column + 1, row] = cookie
                            
                            // is either cookie now part of a chain
                            if hasChainAt(column: column + 1, row: row) ||
                                hasChainAt(column: column, row: row) {
                                set.insert(Swap(cookieA: cookie, cookieB: other))
                                set.insert(Swap(cookieA: other, cookieB: cookie))
                                print("FOUND SWAP X = \(column) & \(row)")
                            }
                            
                            // Swap them back
                            cookies[column, row] = cookie
                            cookies[column + 1, row] = other
                        }
                    }
                    
                    if row < NumRows - 1 {
                        if let other = cookies[column, row + 1] {
                            // swap them
                            cookies[column, row] = other
                            cookies[column, row + 1] = cookie
                            
                            // is either cookie now part of a chain?
                            if hasChainAt(column: column, row: row + 1) ||
                                hasChainAt(column: column, row: row) {
                                set.insert(Swap(cookieA: cookie, cookieB: other))
                                set.insert(Swap(cookieA: other, cookieB: cookie))
                                print("FOUND SWAP Y = \(column) & \(row)")
                            }
                            
                            // swap them back
                            cookies[column, row] = cookie
                            cookies[column, row + 1] = other
                        }
                    }
                }
            }
        }
        possibleSwaps = set
    }
    
    // helper method for detectPossibleSwaps() to see if a cookie is part of a chain
    private func hasChainAt(column: Int, row: Int) -> Bool {
        let cookieType = cookies[column, row]!.cookieType
        
        // horizontal chain check
        var horzLength = 1
        
        // left
        var i = column - 1
        while i >= 0 && cookies[i, row]?.cookieType == cookieType {
            print(cookies[i, row]!.cookieType)
            i -= 1
            horzLength += 1
        }
        
        // right
        i = column + 1
        while i < NumColumns && cookies[i, row]?.cookieType == cookieType {
            print(cookies[i, row]!.cookieType)
            i += 1
            horzLength += 1
        }
        print("\(column), \(row) = \(horzLength)")
        if horzLength >= 3 { return true }
        
        // vertical chain check
        var vertLength = 1
        
        // Down
        i = row - 1
        while i >= 0 && cookies[column, i]?.cookieType == cookieType {
            print(cookies[column, i]!.cookieType)
            i -= 1
            vertLength += 1
        }
        
        // UP
        i = row + 1
        while i < NumRows && cookies[column, i]?.cookieType == cookieType {
            print(cookies[column, i]!.cookieType)
            i += 1
            vertLength += 1
        }
        print("\(column), \(row) = \(vertLength)")
        return vertLength >= 3
    }
    
    func getChainAt(column: Int, row: Int) -> Array<Cookie>  {
        
        var result: Array<Cookie> = []
        
        let cookieType = cookies[column, row]!.cookieType
        
        // horizontal chain check
        var horzLength = 1
        result.append(cookies[column, row]!)
        
        // left
        var i = column - 1
        while i >= 0 && cookies[i, row]?.cookieType == cookieType {
            result.append(cookies[i, row]!)
            i -= 1
            horzLength += 1
        }
        
        // right
        i = column + 1
        while i < NumColumns && cookies[i, row]?.cookieType == cookieType {
            result.append(cookies[i, row]!)
            i += 1
            horzLength += 1
        }
        
        let resultA: Array<Cookie> = result
        
        result = []
        
        // vertical chain check
        var vertLength = 1
        result.append(cookies[column, row]!)
        
        // Down
        i = row - 1
        while i >= 0 && cookies[column, i]?.cookieType == cookieType {
            result.append(cookies[column, i]!)
            i -= 1
            vertLength += 1
        }
        
        // UP
        i = row + 1
        while i < NumRows && cookies[column, i]?.cookieType == cookieType {
            result.append(cookies[column, i]!)
            i += 1
            vertLength += 1
        }
        let resultB: Array<Cookie> = result
        
        let maxSize = max(resultA.count, resultB.count)
        result = []
        if (maxSize < 3) {
            return result
        }
        if (resultA.count > resultB.count) {
            return resultA
        } else {
            return resultB
        }
    }
    
    // updating the data model to ensure that the cookies array is always updated
    // and that their row and column properties are alway in sync.
    
    func performSwap(swap: Swap) {
        let columnA = swap.cookieA.column
        let rowA = swap.cookieA.row
        let columnB = swap.cookieB.column
        let rowB = swap.cookieB.row
        
        cookies[columnA, rowA] = swap.cookieB
        swap.cookieB.column = columnA
        swap.cookieB.row = rowA
        
        cookies[columnB, rowB] = swap.cookieA
        swap.cookieA.column = columnB
        swap.cookieA.row = rowB
    }
    
    func isPossibleSwap(_ swap: Swap) -> Bool {
        return possibleSwaps.contains(swap)
    }
    
}
