import HyperverseService from "../../../contracts/Hyperverse/HyperverseService.cdc"

pub fun main(): UInt64 {
    return HyperverseService.totalTenants
}