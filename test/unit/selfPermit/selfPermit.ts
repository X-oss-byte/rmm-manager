import { parseWei } from 'web3-units'
import expect from '../../shared/expect'
import getPermitSignature from '../../shared/permit'
import { runTest } from '../context'

const value = parseWei('1').raw
const deadline = 999999999999

runTest('selfPermit', function () {
  describe('success cases', function () {
    it('self approves using the signature', async function () {
      const signature = await getPermitSignature(
        this.deployer,
        this.risky.address,
        this.house.address,
        value,
        deadline, {
          name: 'TestToken',
          nonce: '0',
          version: '1',
          chainId: await this.deployer.getChainId(),
        }
      )

      await this.house.selfPermit(
        this.risky.address,
        value,
        deadline,
        signature.v,
        signature.r,
        signature.s,
      )

      expect(
        await this.risky.allowance(this.deployer.address, this.house.address)
      ).to.be.equal(value)
    })
  })

  describe('fail cases', function () {
    it('reverts if the deadline is reached', async function () {
      const signature = await getPermitSignature(
        this.deployer,
        this.risky.address,
        this.house.address,
        value,
        0, {
          name: 'TestToken',
          nonce: '0',
          version: '1',
          chainId: await this.deployer.getChainId(),
        }
      )

      await expect(this.house.selfPermit(
        this.risky.address,
        value,
        0,
        signature.v,
        signature.r,
        signature.s,
      )).to.be.revertedWith('ERC20Permit: expired deadline')
    })

    it('reverts if the signature is invalid', async function () {
      const signature = await getPermitSignature(
        this.deployer,
        this.risky.address,
        this.house.address,
        value,
        deadline, {
          name: 'TestToken',
          nonce: '0',
          version: '1',
          chainId: await this.deployer.getChainId(),
        }
      )

      await expect(this.house.selfPermit(
        this.risky.address,
        value.mul(2),
        deadline,
        signature.v,
        signature.r,
        signature.s,
      )).to.be.revertedWith('ERC20Permit: invalid signature')
    })
  })
})
