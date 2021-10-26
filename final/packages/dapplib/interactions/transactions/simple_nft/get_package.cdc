import SimpleNFT from 0x26a365de6d6237cd

// Will only be run 1 time per user - ever. So even if they need this
// collection as dependencies, etc.
transaction() {

    prepare(signer: AuthAccount) {
        signer.save(<- SimpleNFT.getPackage(), to: SimpleNFT.PackageStoragePath)
        signer.link<&SimpleNFT.Package>(SimpleNFT.PackagePrivatePath, target: SimpleNFT.PackageStoragePath)
        signer.link<&SimpleNFT.Package{SimpleNFT.PackagePublic}>(SimpleNFT.PackagePublicPath, target: SimpleNFT.PackageStoragePath)
    }

    execute {
        log("Signer has a SimpleNFT.Package.")
    }
}

