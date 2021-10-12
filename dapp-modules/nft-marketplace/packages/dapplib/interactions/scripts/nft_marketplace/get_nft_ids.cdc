import MorganNFT from "../../../contracts/Project/MorganNFT.cdc"
import NonFungibleToken from "../../../contracts/Flow/NonFungibleToken.cdc"

pub fun main(account: Address): [UInt64] {
    let accountCollection = getAccount(account).getCapability(MorganNFT.CollectionPublicPath)
                                .borrow<&MorganNFT.Collection{NonFungibleToken.CollectionPublic}>()!

    return accountCollection.getIDs()
}