import Foundation

// MARK: - Wash Instructions

public enum WashTemperature: Int, Equatable, CaseIterable {
    case veryDelicate = 30  // 30°C / 86°F
    case delicate = 40      // 40°C / 104°F
    case normal = 60        // 60°C / 140°F
    case hot = 95           // 95°C / 203°F

    public var description: String {
        switch self {
        case .veryDelicate: return "Cold (30°C / 86°F)"
        case .delicate:     return "Warm (40°C / 104°F)"
        case .normal:       return "Hot (60°C / 140°F)"
        case .hot:          return "Very Hot (95°C / 203°F)"
        }
    }
}

public enum WashInstruction: Equatable {
    case machineWash(temperature: WashTemperature)
    case gentleMachineWash(temperature: WashTemperature)
    case handWash
    case doNotWash

    public var description: String {
        switch self {
        case .machineWash(let temp):
            return "Machine wash – \(temp.description)"
        case .gentleMachineWash(let temp):
            return "Gentle/delicate machine wash – \(temp.description)"
        case .handWash:
            return "Hand wash only"
        case .doNotWash:
            return "Do not wash"
        }
    }

    public var sfSymbolName: String {
        switch self {
        case .machineWash, .gentleMachineWash:
            return "washer"
        case .handWash:
            return "hand.raised"
        case .doNotWash:
            return "xmark.circle"
        }
    }
}

// MARK: - Drying Instructions

public enum HeatLevel: Equatable {
    case noHeat
    case low
    case medium
    case high

    public var description: String {
        switch self {
        case .noHeat:  return "No Heat"
        case .low:     return "Low Heat"
        case .medium:  return "Medium Heat"
        case .high:    return "High Heat"
        }
    }
}

public enum DryInstruction: Equatable {
    case tumbleDry(heat: HeatLevel)
    case layFlatToDry
    case hangToDry
    case dripDry
    case doNotTumbleDry

    public var description: String {
        switch self {
        case .tumbleDry(let heat):
            return "Tumble dry – \(heat.description)"
        case .layFlatToDry:
            return "Lay flat to dry"
        case .hangToDry:
            return "Hang to dry / Line dry"
        case .dripDry:
            return "Drip dry"
        case .doNotTumbleDry:
            return "Do not tumble dry"
        }
    }

    public var sfSymbolName: String {
        switch self {
        case .tumbleDry:
            return "dryer"
        case .layFlatToDry:
            return "arrow.down.to.line.compact"
        case .hangToDry:
            return "arrow.down"
        case .dripDry:
            return "drop"
        case .doNotTumbleDry:
            return "xmark.circle"
        }
    }
}

// MARK: - Bleach Instructions

public enum BleachInstruction: Equatable {
    case bleachAllowed
    case nonChlorineBleachOnly
    case doNotBleach

    public var description: String {
        switch self {
        case .bleachAllowed:          return "Bleach when needed"
        case .nonChlorineBleachOnly:  return "Non-chlorine / color-safe bleach only"
        case .doNotBleach:            return "Do not bleach"
        }
    }

    public var sfSymbolName: String {
        switch self {
        case .bleachAllowed:          return "checkmark.circle"
        case .nonChlorineBleachOnly:  return "exclamationmark.triangle"
        case .doNotBleach:            return "xmark.circle"
        }
    }
}

// MARK: - Iron Instructions

public enum IronHeat: Equatable {
    case low    // 110°C
    case medium // 150°C
    case high   // 200°C

    public var description: String {
        switch self {
        case .low:    return "Low (110°C / 230°F)"
        case .medium: return "Medium (150°C / 300°F)"
        case .high:   return "High (200°C / 390°F)"
        }
    }
}

public enum IronInstruction: Equatable {
    case iron(heat: IronHeat)
    case doNotIron
    case doNotSteam

    public var description: String {
        switch self {
        case .iron(let heat):
            return "Iron – \(heat.description)"
        case .doNotIron:
            return "Do not iron"
        case .doNotSteam:
            return "Do not steam"
        }
    }

    public var sfSymbolName: String {
        switch self {
        case .iron:
            return "thermometer.medium"
        case .doNotIron, .doNotSteam:
            return "xmark.circle"
        }
    }
}

// MARK: - Dry Clean Instructions

public enum DrycleanInstruction: Equatable {
    case dryclean
    case gentleDryclean
    case doNotDryclean

    public var description: String {
        switch self {
        case .dryclean:        return "Dry clean"
        case .gentleDryclean:  return "Gentle / sensitive dry clean"
        case .doNotDryclean:   return "Do not dry clean"
        }
    }

    public var sfSymbolName: String {
        switch self {
        case .dryclean, .gentleDryclean:  return "building.2"
        case .doNotDryclean:              return "xmark.circle"
        }
    }
}
