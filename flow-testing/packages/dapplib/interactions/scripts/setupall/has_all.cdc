import SimpleToken from "../../../contracts/Project/SimpleToken.cdc"
import SimpleNFT from "../../../contracts/Project/SimpleNFT.cdc"
import Rewards from "../../../contracts/Project/Rewards.cdc"
import NFTMarketplace from "../../../contracts/Project/NFTMarketplace.cdc"
import Tribes from "../../../contracts/Project/Tribes.cdc"
import SimpleNFTMarketplace from "../../../contracts/Project/SimpleNFTMarketplace.cdc"
import HyperverseAuth from "../../../contracts/Hyperverse/HyperverseAuth.cdc"

pub fun main(account: Address): Bool {

    let Auth = getAccount(account).getCapability<&HyperverseAuth.Auth{HyperverseAuth.IAuth}>(HyperverseAuth.AuthPublicPath).borrow()
    let SimpleNFTPackage = getAccount(account).getCapability<&SimpleNFT.Package{SimpleNFT.PackagePublic}>(SimpleNFT.PackagePublicPath).borrow()
    let SimpleTokenPackage = getAccount(account).getCapability<&SimpleToken.Package{SimpleToken.PackagePublic}>(SimpleToken.PackagePublicPath).borrow()
    let TribesPackage = getAccount(account).getCapability<&Tribes.Package{Tribes.PackagePublic}>(Tribes.PackagePublicPath).borrow()
    let RewardsPackage = getAccount(account).getCapability<&Rewards.Package{Rewards.PackagePublic}>(Rewards.PackagePublicPath).borrow()
    let NFTMarketplacePackage = getAccount(account).getCapability<&NFTMarketplace.Package{NFTMarketplace.PackagePublic}>(NFTMarketplace.PackagePublicPath).borrow()
    let SimpleNFTMarketplacePackage = getAccount(account).getCapability<&SimpleNFTMarketplace.Package{SimpleNFTMarketplace.PackagePublic}>(SimpleNFTMarketplace.PackagePublicPath).borrow()

    if Auth != nil && SimpleNFTPackage != nil && SimpleTokenPackage != nil && TribesPackage != nil && RewardsPackage != nil && NFTMarketplacePackage != nil && SimpleNFTMarketplacePackage != nil {
        return true
    }
    return false
}