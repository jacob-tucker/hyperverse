import NFTMarketplace from "../../../contracts/Project/NFTMarketplace.cdc"

// Needs to be called every time a user comes into a new tenant of this contract
transaction(tenantID: UInt64) {

    let Package: &NFTMarketplace.Package

    prepare(signer: AuthAccount) {
        self.Package = signer.borrow<&NFTMarketplace.Package>(from: NFTMarketplace.PackageStoragePath)
                        ?? panic("Could not borrow the signer's Package.")
    }

    execute {
        self.Package.setup(tenantID: tenantID)
        log("Signer setup their NFTMarketplace.Package for itself and its dependencies.")
    }
}

