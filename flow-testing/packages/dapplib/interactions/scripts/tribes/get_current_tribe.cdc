import Tribes from "../../../contracts/Project/Tribes.cdc"

// We could technically pass in the tenantID right away, but it makes
// sense to do it through an address.

pub fun main(account: Address, tenantOwner: Address): {String: String}? {
    let tenantID = tenantOwner.toString()
                        .concat(".")
                        .concat(Tribes.getType().identifier)
                        
    let accountPackage = getAccount(account).getCapability(Tribes.PackagePublicPath)
                                .borrow<&Tribes.Package{Tribes.PackagePublic}>()!

    let tribe = accountPackage.borrowIdentityPublic(tenantID: tenantID).currentTribeName

    if tribe == nil {
        return nil
    }

    let returnObject: {String: String} = {}
    let tenantData = Tribes.getTenant(id: tenantID)
    returnObject["name"] = tribe
    returnObject["ipfsHash"] = tenantData.getTribeData(tribeName: tribe!).ipfsHash
    returnObject["description"] = tenantData.getTribeData(tribeName: tribe!).description

    return returnObject
}