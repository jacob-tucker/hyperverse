// import MorganNFT from "../../../contracts/Project/MorganNFT.cdc"
// import NonFungibleToken from "../../../contracts/Flow/NonFungibleToken.cdc"
// import NFTMarketplace from "../../../contracts/Project/NFTMarketplace.cdc"

// transaction() {
    
//     prepare(signer: AuthAccount, recipient: AuthAccount) {
//         let nftMarketplaceTenant = signer.borrow<&NFTMarketplace.Tenant>(from: NFTMarketplace.getMetadata().tenantStoragePath)!
//         recipient.save(<- nftMarketplaceTenant.morganNFTTenant.createNewMinter(), to: /storage/MorganNFTMinter)
//     }

//     execute {
//         log("Gave a MorganNFT.NFTMinter to the recipient's account.")
//     }
// }

