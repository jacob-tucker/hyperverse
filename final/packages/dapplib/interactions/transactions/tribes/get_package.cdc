import Tribes from 0x26a365de6d6237cd

// Will only be run 1 time per user - ever. So even if they need this
// collection as dependencies, etc.
transaction() {

    prepare(signer: AuthAccount) {
        signer.save(<- Tribes.getPackage(), to: Tribes.PackageStoragePath)
        signer.link<&Tribes.Package>(Tribes.PackagePrivatePath, target: Tribes.PackageStoragePath)
        signer.link<&Tribes.Package{Tribes.PackagePublic}>(Tribes.PackagePublicPath, target: Tribes.PackageStoragePath)
    }

    execute {
        log("Signer has a Tribes.Package.")
    }
}

