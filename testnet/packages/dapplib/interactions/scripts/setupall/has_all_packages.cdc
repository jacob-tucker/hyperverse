import SimpleFT from 0x26a365de6d6237cd
import SimpleNFT from 0x26a365de6d6237cd
import Rewards from 0x26a365de6d6237cd
import NFTMarketplace from 0x26a365de6d6237cd
import Tribes from 0x26a365de6d6237cd

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