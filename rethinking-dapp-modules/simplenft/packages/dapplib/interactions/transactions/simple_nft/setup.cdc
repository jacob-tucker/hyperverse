import SimpleNFT from "../../../contracts/Project/SimpleNFT.cdc"

// Needs to be called every time a user comes into a new tenant of this contract
transaction(tenantID: UInt64) {

    let Package: &SimpleNFT.Package

    prepare(signer: AuthAccount) {
        self.Package = signer.borrow<&SimpleNFT.Package>(from: SimpleNFT.PackageStoragePath)
                        ?? panic("Could not borrow the signer's Package.")
    }

    execute {
        self.Package.setup(tenantID: tenantID)
        log("Signer setup their Package for SimpleNFT and its dependencies.")
    }
}

