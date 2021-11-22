import Tribes from "../../../contracts/Project/Tribes.cdc"

// We could technically pass in the tenantID right away, but it makes
// sense to do it through an address.

pub fun main(account: Address, tenantOwner: Address): {String: String}? {
                        
    let accountPackage = getAccount(account).getCapability(Tribes.BundlePublicPath)
                                .borrow<&Tribes.Bundle{Tribes.PublicBundle}>()!

    let tribe = accountPackage.borrowIdentityPublic(tenant: tenantOwner).currentTribeName

    if tribe == nil {
        return nil
    }

    let returnObject: {String: String} = {}
    let tenantData = Tribes.getTribeData(tenant: tenantOwner, tribeName: tribe!)
    returnObject["name"] = tribe
    returnObject["ipfsHash"] = tenantData.ipfsHash
    returnObject["description"] = tenantData.description

    return returnObject
}