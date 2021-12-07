import SimpleToken from "../../../contracts/Project/SimpleToken.cdc"

pub fun main(account: Address, tenantOwner: Address): UFix64 {
    let vault = getAccount(account).getCapability(SimpleToken.VaultPublicPath)
                    .borrow<&SimpleToken.Vault{SimpleToken.VaultPublic}>()
                    ?? panic("Could not get the account SimpleToken.Vault")

    return vault.balance(tenantOwner)
}