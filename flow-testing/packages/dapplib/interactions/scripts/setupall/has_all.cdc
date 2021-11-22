import SimpleToken from "../../../contracts/Project/SimpleToken.cdc"
import SimpleNFT from "../../../contracts/Project/SimpleNFT.cdc"
import Rewards from "../../../contracts/Project/Rewards.cdc"
import NFTMarketplace from "../../../contracts/Project/NFTMarketplace.cdc"
import Tribes from "../../../contracts/Project/Tribes.cdc"
import SimpleNFTMarketplace from "../../../contracts/Project/SimpleNFTMarketplace.cdc"
import HyperverseAuth from "../../../contracts/Hyperverse/HyperverseAuth.cdc"

pub fun main(account: Address): Bool {

    let Auth = getAccount(account).getCapability<&HyperverseAuth.Auth{HyperverseAuth.IAuth}>(HyperverseAuth.AuthPublicPath).borrow()
    let SimpleNFTPackage = getAccount(account).getCapability<&SimpleNFT.Bundle{SimpleNFT.PublicBundle}>(SimpleNFT.BundlePublicPath).borrow()
    let SimpleTokenPackage = getAccount(account).getCapability<&SimpleToken.Bundle{SimpleToken.PublicBundle}>(SimpleToken.BundlePublicPath).borrow()
    let TribesPackage = getAccount(account).getCapability<&Tribes.Bundle{Tribes.PublicBundle}>(Tribes.BundlePublicPath).borrow()
    let RewardsPackage = getAccount(account).getCapability<&Rewards.Bundle{Rewards.PublicBundle}>(Rewards.BundlePublicPath).borrow()
    let NFTMarketplacePackage = getAccount(account).getCapability<&NFTMarketplace.Bundle{NFTMarketplace.PublicBundle}>(NFTMarketplace.BundlePublicPath).borrow()
    let SimpleNFTMarketplacePackage = getAccount(account).getCapability<&SimpleNFTMarketplace.Bundle{SimpleNFTMarketplace.PublicBundle}>(SimpleNFTMarketplace.BundlePublicPath).borrow()

    if Auth != nil && SimpleNFTPackage != nil && SimpleTokenPackage != nil && TribesPackage != nil && RewardsPackage != nil && NFTMarketplacePackage != nil && SimpleNFTMarketplacePackage != nil {
        return true
    }
    return false
}