import SimpleFT from "../../../contracts/Project/SimpleFT.cdc"
import SimpleNFT from "../../../contracts/Project/SimpleNFT.cdc"
import Rewards from "../../../contracts/Project/Rewards.cdc"
import NFTMarketplace from "../../../contracts/Project/NFTMarketplace.cdc"
import Tribes from "../../../contracts/Project/Tribes.cdc"

pub fun main(account: Address): Bool {

    let SimpleNFTPackage = getAccount(account).getCapability<&SimpleNFT.Package{SimpleNFT.PackagePublic}>(SimpleNFT.PackagePublicPath).borrow()
    let SimpleFTPackage = getAccount(account).getCapability<&SimpleFT.Package{SimpleFT.PackagePublic}>(SimpleFT.PackagePublicPath).borrow()
    let TribesPackage = getAccount(account).getCapability<&Tribes.Package{Tribes.PackagePublic}>(Tribes.PackagePublicPath).borrow()
    let RewardsPackage = getAccount(account).getCapability<&Rewards.Package{Rewards.PackagePublic}>(Rewards.PackagePublicPath).borrow()
    let NFTMarketplacePackage = getAccount(account).getCapability<&NFTMarketplace.Package{NFTMarketplace.PackagePublic}>(NFTMarketplace.PackagePublicPath).borrow()

    if SimpleNFTPackage != nil && SimpleFTPackage != nil && TribesPackage != nil && RewardsPackage != nil && NFTMarketplacePackage != nil{
        return true
    }
    return false
}