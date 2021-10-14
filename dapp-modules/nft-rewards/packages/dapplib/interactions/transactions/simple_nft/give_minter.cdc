import SimpleNFT from "../../../contracts/Project/SimpleNFT.cdc"

transaction() {
    
    prepare(signer: AuthAccount, recipient: AuthAccount) {
        let simpleNFTTenant = signer.borrow<&SimpleNFT.Tenant>(from: SimpleNFT.getMetadata().tenantStoragePath)!
        recipient.save(<- simpleNFTTenant.createNewMinter(), to: /storage/SimpleNFTMinter)
    }

    execute {
        log("Gave a SimpleNFT.NFTMinter to the recipient's account.")
    }
}

