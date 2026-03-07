import XCTest
@testable import LaundryLabelParser

final class LabelParserTests: XCTestCase {

    var sut: LabelAnalyzerService!

    override func setUp() {
        super.setUp()
        sut = LabelAnalyzerService()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Wash Tests

    func testMachineWashCold() {
        let result = sut.parseLabel(from: ["Machine wash cold"])
        XCTAssertEqual(result.wash, .machineWash(temperature: .veryDelicate))
    }

    func testMachineWashWarm() {
        let result = sut.parseLabel(from: ["Machine wash warm"])
        XCTAssertEqual(result.wash, .machineWash(temperature: .delicate))
    }

    func testMachineWashHot() {
        let result = sut.parseLabel(from: ["Machine wash hot"])
        XCTAssertEqual(result.wash, .machineWash(temperature: .normal))
    }

    func testMachineWash30Degrees() {
        let result = sut.parseLabel(from: ["Wash at 30"])
        XCTAssertEqual(result.wash, .machineWash(temperature: .veryDelicate))
    }

    func testMachineWash60Degrees() {
        let result = sut.parseLabel(from: ["Wash at 60"])
        XCTAssertEqual(result.wash, .machineWash(temperature: .normal))
    }

    func testHandWash() {
        let result = sut.parseLabel(from: ["Hand wash only"])
        XCTAssertEqual(result.wash, .handWash)
    }

    func testDoNotWash() {
        let result = sut.parseLabel(from: ["Do not wash"])
        XCTAssertEqual(result.wash, .doNotWash)
    }

    func testDryCleanOnly_impliesDoNotWash() {
        let result = sut.parseLabel(from: ["Dry clean only"])
        XCTAssertEqual(result.wash, .doNotWash)
    }

    func testGentleCycle() {
        let result = sut.parseLabel(from: ["Gentle cycle", "Wash at 40"])
        XCTAssertEqual(result.wash, .gentleMachineWash(temperature: .delicate))
    }

    func testDelicateCycle() {
        let result = sut.parseLabel(from: ["Delicate wash cold"])
        XCTAssertEqual(result.wash, .gentleMachineWash(temperature: .veryDelicate))
    }

    // MARK: - Dry Tests

    func testTumbleDryLow() {
        let result = sut.parseLabel(from: ["Tumble dry low"])
        XCTAssertEqual(result.dry, .tumbleDry(heat: .low))
    }

    func testTumbleDryMedium() {
        let result = sut.parseLabel(from: ["Tumble dry medium"])
        XCTAssertEqual(result.dry, .tumbleDry(heat: .medium))
    }

    func testTumbleDryHigh() {
        let result = sut.parseLabel(from: ["Tumble dry high"])
        XCTAssertEqual(result.dry, .tumbleDry(heat: .high))
    }

    func testTumbleDryNoHeat() {
        let result = sut.parseLabel(from: ["Tumble dry no heat"])
        XCTAssertEqual(result.dry, .tumbleDry(heat: .noHeat))
    }

    func testTumbleDryDefault() {
        let result = sut.parseLabel(from: ["Tumble dry"])
        XCTAssertEqual(result.dry, .tumbleDry(heat: .medium))
    }

    func testLayFlatToDry() {
        let result = sut.parseLabel(from: ["Lay flat to dry"])
        XCTAssertEqual(result.dry, .layFlatToDry)
    }

    func testHangToDry() {
        let result = sut.parseLabel(from: ["Hang to dry"])
        XCTAssertEqual(result.dry, .hangToDry)
    }

    func testLineDry() {
        let result = sut.parseLabel(from: ["Line dry"])
        XCTAssertEqual(result.dry, .hangToDry)
    }

    func testDripDry() {
        let result = sut.parseLabel(from: ["Drip dry"])
        XCTAssertEqual(result.dry, .dripDry)
    }

    func testDoNotTumbleDry() {
        let result = sut.parseLabel(from: ["Do not tumble dry"])
        XCTAssertEqual(result.dry, .doNotTumbleDry)
    }

    // MARK: - Bleach Tests

    func testDoNotBleach() {
        let result = sut.parseLabel(from: ["Do not bleach"])
        XCTAssertEqual(result.bleach, .doNotBleach)
    }

    func testNoBleach() {
        let result = sut.parseLabel(from: ["No bleach"])
        XCTAssertEqual(result.bleach, .doNotBleach)
    }

    func testNonChlorineBleach() {
        let result = sut.parseLabel(from: ["Non-chlorine bleach only"])
        XCTAssertEqual(result.bleach, .nonChlorineBleachOnly)
    }

    func testColorSafeBleach() {
        let result = sut.parseLabel(from: ["Colour safe bleach"])
        XCTAssertEqual(result.bleach, .nonChlorineBleachOnly)
    }

    func testBleachAllowed() {
        let result = sut.parseLabel(from: ["Bleach when needed"])
        XCTAssertEqual(result.bleach, .bleachAllowed)
    }

    // MARK: - Iron Tests

    func testDoNotIron() {
        let result = sut.parseLabel(from: ["Do not iron"])
        XCTAssertEqual(result.iron, .doNotIron)
    }

    func testNoIron() {
        let result = sut.parseLabel(from: ["No iron"])
        XCTAssertEqual(result.iron, .doNotIron)
    }

    func testDoNotSteam() {
        let result = sut.parseLabel(from: ["Do not steam"])
        XCTAssertEqual(result.iron, .doNotSteam)
    }

    func testIronLow() {
        let result = sut.parseLabel(from: ["Iron low"])
        XCTAssertEqual(result.iron, .iron(heat: .low))
    }

    func testIronMedium() {
        let result = sut.parseLabel(from: ["Iron medium"])
        XCTAssertEqual(result.iron, .iron(heat: .medium))
    }

    func testIronHigh() {
        let result = sut.parseLabel(from: ["Iron high"])
        XCTAssertEqual(result.iron, .iron(heat: .high))
    }

    func testCoolIron() {
        let result = sut.parseLabel(from: ["Cool iron"])
        XCTAssertEqual(result.iron, .iron(heat: .low))
    }

    func testIronDefault() {
        let result = sut.parseLabel(from: ["Iron"])
        XCTAssertEqual(result.iron, .iron(heat: .medium))
    }

    // MARK: - Dry Clean Tests

    func testDryclean() {
        let result = sut.parseLabel(from: ["Dry clean"])
        XCTAssertEqual(result.dryclean, .dryclean)
    }

    func testDrycleanOnly() {
        let result = sut.parseLabel(from: ["Dry clean only"])
        XCTAssertEqual(result.dryclean, .dryclean)
    }

    func testDoNotDryclean() {
        let result = sut.parseLabel(from: ["Do not dry clean"])
        XCTAssertEqual(result.dryclean, .doNotDryclean)
    }

    func testGentleDryclean() {
        let result = sut.parseLabel(from: ["Gentle dry clean"])
        XCTAssertEqual(result.dryclean, .gentleDryclean)
    }

    // MARK: - Combined / Edge Cases

    func testFullLabel() {
        let result = sut.parseLabel(from: [
            "Machine wash cold",
            "Tumble dry low",
            "Do not bleach",
            "Iron medium"
        ])
        XCTAssertEqual(result.wash,   .machineWash(temperature: .veryDelicate))
        XCTAssertEqual(result.dry,    .tumbleDry(heat: .low))
        XCTAssertEqual(result.bleach, .doNotBleach)
        XCTAssertEqual(result.iron,   .iron(heat: .medium))
    }

    func testEmptyInput() {
        let result = sut.parseLabel(from: [])
        XCTAssertTrue(result.isEmpty)
    }

    func testUnrecognisedText() {
        let result = sut.parseLabel(from: ["100% Cotton", "Made in Portugal", "Size M"])
        XCTAssertTrue(result.isEmpty)
    }

    func testCaseInsensitivity() {
        let result = sut.parseLabel(from: ["MACHINE WASH COLD", "DO NOT BLEACH"])
        XCTAssertEqual(result.wash,   .machineWash(temperature: .veryDelicate))
        XCTAssertEqual(result.bleach, .doNotBleach)
    }

    func testLeadingTrailingWhitespace() {
        let result = sut.parseLabel(from: ["  Hand wash only  "])
        XCTAssertEqual(result.wash, .handWash)
    }

    // MARK: - LaundryLabel isEmpty

    func testLaundryLabelIsEmpty_whenAllNil() {
        let label = LaundryLabel()
        XCTAssertTrue(label.isEmpty)
    }

    func testLaundryLabelIsNotEmpty_whenAnySet() {
        let label = LaundryLabel(wash: .handWash)
        XCTAssertFalse(label.isEmpty)
    }
}
