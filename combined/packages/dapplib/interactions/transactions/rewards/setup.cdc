import Rewards from "../../../contracts/Project/Rewards.cdc"

// Needs to be called every time a user comes into a new tenant of this contract
transaction(tenantID: String) {

    let Package: &Rewards.Package

    prepare(signer: AuthAccount) {

        self.Package = signer.borrow<&Rewards.Package>(from: Rewards.PackageStoragePath)
                        ?? panic("Could not borrow the signer's Package.")
    }

    execute {
        self.Package.setup(tenantID: tenantID)
        log("Signer setup their Rewards.Package for itself and its dependencies.")
    }
}

