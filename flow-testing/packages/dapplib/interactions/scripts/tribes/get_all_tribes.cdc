import Tribes from "../../../contracts/Project/Tribes.cdc"

// We could technically pass in the tenantID right away, but it makes
// sense to do it through an address.

pub fun main(tenantOwner: Address): {String: Tribes.TribeData} {
    let tenantID = tenantOwner.toString()
                        .concat(".")
                        .concat(Tribes.getType().identifier)
    
    return Tribes.getTenant(id: tenantID).getAllTribes()
}