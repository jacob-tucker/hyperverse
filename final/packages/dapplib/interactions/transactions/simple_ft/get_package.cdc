import SimpleFT from 0x26a365de6d6237cd

// Will only be run 1 time per user - ever. So even if they need this
// collection as dependencies, etc.
transaction() {

    prepare(signer: AuthAccount) {
        signer.save(<- SimpleFT.getPackage(), to: SimpleFT.PackageStoragePath)
        signer.link<&SimpleFT.Package>(SimpleFT.PackagePrivatePath, target: SimpleFT.PackageStoragePath)
        signer.link<&SimpleFT.Package{SimpleFT.PackagePublic}>(SimpleFT.PackagePublicPath, target: SimpleFT.PackageStoragePath)
    }

    execute {
        log("Signer has a SimpleFT.Package.")
    }
}

