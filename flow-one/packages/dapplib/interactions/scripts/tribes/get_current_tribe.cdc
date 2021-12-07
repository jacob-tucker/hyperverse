import Tribes from "../../../contracts/Project/Tribes.cdc"

// We could technically pass in the tenantID right away, but it makes
// sense to do it through an address.

pub fun main(account: Address, tenantOwner: Address): {String: String}? {
                        
    let identity = getAccount(account).getCapability(Tribes.IdentityPublicPath)
                                .borrow<&Tribes.Identity{Tribes.IdentityPublic}>()
                                ?? panic("Could not get the Identity.")

    let tribe = identity.currentTribeName(tenantOwner)

    if tribe == nil {
        return nil
    }

    let returnObject: {String: String} = {}
    let tenantData = Tribes.getTribeData(tenantOwner, tribeName: tribe!)
    returnObject["name"] = tribe
    returnObject["ipfsHash"] = tenantData.ipfsHash
    returnObject["description"] = tenantData.description

    return returnObject
}