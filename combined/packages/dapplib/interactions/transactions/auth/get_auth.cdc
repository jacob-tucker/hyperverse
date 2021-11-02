import HyperverseAuth from "../../../contracts/Hyperverse/HyperverseAuth.cdc"

transaction() {
    prepare(signer: AuthAccount) {
        signer.save(<- HyperverseAuth.createAuth(), to: HyperverseAuth.AuthStoragePath)
    }

    execute {
        log("Saved a new HyperverseAuth to account storage.")
    }
}