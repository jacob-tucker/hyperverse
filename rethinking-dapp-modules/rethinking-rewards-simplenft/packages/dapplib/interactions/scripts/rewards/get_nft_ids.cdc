import SimpleNFT from "../../../contracts/Project/SimpleNFT.cdc"

pub fun main(account: Address): [UInt64] {
    let accountCollection = getAccount(account).getCapability(SimpleNFT.CollectionPublicPath)
                                .borrow<&SimpleNFT.Collection{SimpleNFT.CollectionPublic}>()!

    return accountCollection.getIDs()
}