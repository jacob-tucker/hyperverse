import SimpleFT from "../../../contracts/Project/SimpleFT.cdc"

// Needs to be called every time a user comes into a new tenant of this contract
transaction(tenantID: UInt64) {

    let Package: &SimpleFT.Package

    prepare(signer: AuthAccount) {
        self.Package = signer.borrow<&SimpleFT.Package>(from: SimpleFT.PackageStoragePath)
                        ?? panic("Could not borrow the signer's Package.")
    }

    execute {
        self.Package.setup(tenantID: tenantID)
        log("Signer setup their Package for SimpleFT and its dependencies.")
    }
}
