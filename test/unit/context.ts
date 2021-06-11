import { createFixtureLoader, MockProvider } from 'ethereum-waffle'
import { Contracts, Functions, Mocks, ContractName } from '../../types'
import { Wallet } from 'ethers'

export default async function loadContext(
  provider: MockProvider,
  contracts: ContractName[],
  action?: (signers: Wallet[], contracts: Contracts) => Promise<void>
): Promise<void> {
  const loadFixture = createFixtureLoader(provider.getWallets(), provider)

  beforeEach(async function () {
    const loadedFixture = await loadFixture(async function (signers: Wallet[]) {
      const [deployer] = signers
      let loadedContracts: Contracts = {} as Contracts
      let loadedFunctions: Functions = {} as Functions

      // TODO: set loaded contracts using a function
      // TODO: set loaded functions using a function

      if (action) await action(signers, loadedContracts)

      return { contracts: loadedContracts, functions: loadedFunctions }
    })

    this.contracts = {} as Contracts
    this.functions = {} as Functions
    this.mocks = {} as Mocks
    this.signers = provider.getWallets()
    this.deployer = this.signers[0]

    Object.assign(this.contracts, loadedFixture.contracts)
    Object.assign(this.functions, loadedFixture.functions)
  })
}
