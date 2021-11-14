import SimpleToken from "../../../contracts/Project/SimpleToken.cdc"

// Will only be run 1 time per user - ever. So even if they need this
// collection as dependencies, etc.
transaction() {

    prepare(signer: AuthAccount) {
        signer.save(<- SimpleToken.getPackage(), to: SimpleToken.PackageStoragePath)
        signer.link<&SimpleToken.Package>(SimpleToken.PackagePrivatePath, target: SimpleToken.PackageStoragePath)
        signer.link<&SimpleToken.Package{SimpleToken.PackagePublic}>(SimpleToken.PackagePublicPath, target: SimpleToken.PackageStoragePath)
    }

    execute {
        log("Signer has a SimpleToken.Package.")
    }
}

