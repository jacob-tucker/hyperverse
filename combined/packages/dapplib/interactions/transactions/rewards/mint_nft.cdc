import SimpleNFT from "../../../contracts/Project/SimpleNFT.cdc"
import Rewards from "../../../contracts/Project/Rewards.cdc"

transaction(recipient: Address) {

    let TenantID: String
    let MintersSNFTPackage: &SimpleNFT.Package
    let RecipientsSNFTPackage: &SimpleNFT.Package{SimpleNFT.PackagePublic}

    prepare(tenantOwner: AuthAccount) {
        self.TenantID = tenantOwner.address.toString()
                        .concat(".")
                        .concat(SimpleNFT.getType().identifier)
                        .concat(".0")

        self.MintersSNFTPackage = tenantOwner.borrow<&SimpleNFT.Package>(from: SimpleNFT.PackageStoragePath)
                                    ?? panic("Could not borrow the Package from the signer.")

        self.RecipientsSNFTPackage = getAccount(recipient).getCapability(SimpleNFT.PackagePublicPath)
                                        .borrow<&SimpleNFT.Package{SimpleNFT.PackagePublic}>()
                                        ?? panic("Could not borrow the public Package from the recipient.")
    }

    execute {
        let minter = self.MintersSNFTPackage.borrowMinter(tenantID: self.TenantID)

        self.RecipientsSNFTPackage.borrowCollectionPublic(tenantID: self.TenantID).deposit(token: <- minter.mintNFT(metadata: {"name": "Base Reward"}))
    
        log("Minted a SimpleNFT into the recipient's SimpleNFT Collection.")
    }
}

