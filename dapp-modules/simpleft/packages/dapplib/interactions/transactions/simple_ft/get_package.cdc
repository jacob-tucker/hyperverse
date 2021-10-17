import SimpleFT from "../../../contracts/Project/SimpleFT.cdc"

// Will only be run 1 time per user - ever. So even if they need this
// collection as dependencies, etc.
transaction() {

    prepare(signer: AuthAccount) {
        signer.save(<- SimpleFT.getPackage(), to: SimpleFT.PackageStoragePath)
        signer.link<&SimpleFT.Package{SimpleFT.PackagePublic}>(SimpleFT.PackagePublicPath, target: SimpleFT.PackageStoragePath)
    }

    execute {
        log("Signer has a Package.")
    }
}

