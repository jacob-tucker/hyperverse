import Registry from "../../../contracts/Hyperverse/Registry.cdc"

pub fun main(convention: String): Registry.Contract {
    return Registry.retrieveContract(convention: convention)!
}