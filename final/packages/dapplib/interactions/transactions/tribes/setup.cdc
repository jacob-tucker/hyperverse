import Tribes from 0x26a365de6d6237cd

// Needs to be called every time a user comes into a new tenant of this contract
transaction(tenantID: String) {

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

