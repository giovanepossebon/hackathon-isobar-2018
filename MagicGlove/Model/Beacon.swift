import CoreLocation

struct Beacon {
    let name: String
    let uuid: UUID
    let major: CLBeaconMajorValue
    let minor: CLBeaconMinorValue

    init(name: String, uuid: String, major: Int, minor: Int) {
        self.name = name
        self.uuid = UUID(uuidString: uuid)!
        self.major = CLBeaconMajorValue(major)
        self.minor = CLBeaconMinorValue(minor)
    }

    static let glove = Beacon(name: "bico",
                              uuid: "86e55c38-7b7a-4b8f-b869-0e5c12cde3a9",
                              major: 0, minor: 0)
    
    func asBeaconRegion() -> CLBeaconRegion {
        return CLBeaconRegion(proximityUUID: uuid,
                              identifier: name)
    }
}

extension CLBeacon {

    var gloveProximity: Int {

        if accuracy < 0.7 {
            return 5
        } else if accuracy < 5 {
            return 4
        } else if accuracy < 10 {
            return 3
        } else if accuracy < 15 {
            return 2
        } else if accuracy < 20 {
            return 1
        }

        return 0
    }

}
