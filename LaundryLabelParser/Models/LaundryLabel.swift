import Foundation

public struct LaundryLabel: Equatable {
    public var wash: WashInstruction?
    public var dry: DryInstruction?
    public var bleach: BleachInstruction?
    public var iron: IronInstruction?
    public var dryclean: DrycleanInstruction?

    public init(
        wash: WashInstruction? = nil,
        dry: DryInstruction? = nil,
        bleach: BleachInstruction? = nil,
        iron: IronInstruction? = nil,
        dryclean: DrycleanInstruction? = nil
    ) {
        self.wash = wash
        self.dry = dry
        self.bleach = bleach
        self.iron = iron
        self.dryclean = dryclean
    }

    public var isEmpty: Bool {
        wash == nil && dry == nil && bleach == nil && iron == nil && dryclean == nil
    }
}
