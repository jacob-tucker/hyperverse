New shit:

If it's a resource, must have the tenant's id in it (the tenant defined in that contract)
If it's a public function inside the contract and you're passing it a parameter that is the Tenant.IState, just move the function inside the Tenant itself, remove the parameter and expose it in IState.

