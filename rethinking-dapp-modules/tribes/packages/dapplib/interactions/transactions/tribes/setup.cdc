import Tribes from "../../../contracts/Project/Tribes.cdc"

// Needs to be called every time a user comes into a new tenant of this contract
transaction(tenantID: UInt64) {

    let Package: &Tribes.Package

    prepare(signer: AuthAccount) {
        self.Package = signer.borrow<&Tribes.Package>(from: Tribes.PackageStoragePath)
                        ?? panic("Could not borrow the signer's Package.")
    }

    execute {
        self.Package.setup(tenantID: tenantID)
        log("Signer setup their Package for Tribes and its dependencies.")
    }
}

