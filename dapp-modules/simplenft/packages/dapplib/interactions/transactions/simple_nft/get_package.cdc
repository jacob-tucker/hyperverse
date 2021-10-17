import SimpleNFT from "../../../contracts/Project/SimpleNFT.cdc"

// Will only be run 1 time per user - ever. So even if they need this
// collection as dependencies, etc.
transaction() {

    prepare(signer: AuthAccount) {
        signer.save(<- SimpleNFT.getPackage(), to: /storage/SimpleNFTPackage)
        signer.link<&SimpleNFT.Package{SimpleNFT.PackagePublic}>(SimpleNFT.PackagePublicPath, target: SimpleNFT.PackageStoragePath)
    }

    execute {
        log("Signer has a Package.")
    }
}

