import SimpleNFT from "../../../contracts/Project/SimpleNFT.cdc"
import Rewards from "../../../contracts/Project/Rewards.cdc"

transaction(tenantID: UInt64, recipient: Address) {
    let MintersSNFTPackage: &SimpleNFT.Package
    let RecipientsSNFTPackage: &SimpleNFT.Package{SimpleNFT.PackagePublic}

    prepare(signer: AuthAccount) {

        self.MintersSNFTPackage = signer.borrow<&SimpleNFT.Package>(from: SimpleNFT.PackageStoragePath)
                                    ?? panic("Could not borrow the Package from the signer.")

        self.RecipientsSNFTPackage = getAccount(recipient).getCapability(SimpleNFT.PackagePublicPath)
                                        .borrow<&SimpleNFT.Package{SimpleNFT.PackagePublic}>()
                                        ?? panic("Could not borrow the public Package from the recipient.")
    }

    execute {
        let TheSimpleNFTID = Rewards.getTenant(id: tenantID).SNFTTenantID
        let minter = self.MintersSNFTPackage.borrowMinter(tenantID: TheSimpleNFTID)

        self.RecipientsSNFTPackage.borrowCollectionPublic(tenantID: TheSimpleNFTID).deposit(token: <- minter.mintNFT(name: "Base Reward"))
    
        log("Minted a SimpleNFT into the recipient's SimpleNFT Collection.")
    }
}

