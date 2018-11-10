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

    func asBeaconRegion() -> CLBeaconRegion {
        return CLBeaconRegion(proximityUUID: uuid,
                              major: major,
                              minor: minor,
                              identifier: name)
    }
}
