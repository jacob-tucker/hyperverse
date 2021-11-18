import FlowToken from "../../../contracts/Flow/FlowToken.cdc"
import FungibleToken from "../../../contracts/Flow/FungibleToken.cdc"

pub fun main(account: Address): UFix64 {
    let accountVault = getAccount(account).getCapability(/public/flowTokenBalance)
                            .borrow<&FlowToken.Vault{FungibleToken.Balance}>()
                            ?? panic("Could not borrow the public FlowToken Vault from account.")
    
    return accountVault.balance
}