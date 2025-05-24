import SwiftUI

func getColor(color: String) -> Color {
    switch color {
    case DatabaseColor.blue.rawValue:
        return Color.blue
    case DatabaseColor.red.rawValue:
        return Color.red
    case DatabaseColor.green.rawValue:
        return Color.green
    case DatabaseColor.yellow.rawValue:
        return Color.yellow
    case DatabaseColor.purple.rawValue:
        return Color.purple
    case DatabaseColor.orange.rawValue:
        return Color.orange
    default:
        return Color.accentColor
    }
}

enum DatabaseColor: String {
    case blue = "blue"
    case red = "red"
    case green = "green"
    case yellow = "yellow"
    case purple = "purple"
    case orange = "orange"
    case pink = "pink"
    case brown = "brown"
    case gray = "gray"
    case black = "black"
}
