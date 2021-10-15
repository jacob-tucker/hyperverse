// import NFTMarketplace from "../../../contracts/Project/NFTMarketplace.cdc"
// import IHyperverseComposable from "../../../contracts/Hyperverse/IHyperverseComposable.cdc"

// pub fun main(account: Address): Bool {
//     let tenant = getAccount(account).getCapability(NFTMarketplace.getMetadata().tenantPublicPath)
//                     .borrow<&NFTMarketplace.Tenant{IHyperverseComposable.ITenant}>()

//     if tenant == nil {
//         return false
//     } else {
//         return true
//     }
// }