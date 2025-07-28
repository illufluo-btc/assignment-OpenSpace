#!/usr/bin/env node
require('dotenv').config()
const ethers = require('ethers')
const RPC_URL = process.env.RPC_URL
if (!RPC_URL) { console.error('请在 .env 中设置 RPC_URL'); process.exit(1) }
const provider = new ethers.JsonRpcProvider(RPC_URL)
const ERC20_ABI = [
  'function balanceOf(address) view returns (uint256)',
  'function transfer(address to, uint256 amount) returns (bool)'
]
async function gen() {
  const w = ethers.Wallet.createRandom()
  console.log(w.mnemonic.phrase)
  console.log(w.privateKey)
  console.log(w.address)
}
async function balance(pk) {
  try {
    const w = new ethers.Wallet(pk, provider)
    const b = await provider.getBalance(w.address)
    console.log(ethers.formatEther(b))
  } catch (e) {
    console.error(e.message)
  }
}
async function transfer(pk, token, to, amt) {
  try {
    const w = new ethers.Wallet(pk, provider)
    const c = new ethers.Contract(token, ERC20_ABI, w)
    const fees = await provider.getFeeData()
    const tx = await c.transfer(
      to,
      ethers.parseUnits(amt, 18),
      { type: 2, maxPriorityFeePerGas: fees.maxPriorityFeePerGas, maxFeePerGas: fees.maxFeePerGas }
    )
    console.log(tx.hash)
    const r = await tx.wait()
    console.log(r.blockNumber)
  } catch (e) {
    console.error(e.message)
  }
}
async function tokenbalance(pk, token) {
  try {
    const w = new ethers.Wallet(pk, provider)
    const c = new ethers.Contract(token, ERC20_ABI, provider)
    const b = await c.balanceOf(w.address)
    console.log(ethers.formatUnits(b, 18))
  } catch (e) {
    console.error(e.message)
  }
}
;(async () => {
  const [, , cmd, ...a] = process.argv
  if (cmd === 'gen') return gen()
  if (cmd === 'balance' && a.length === 1) return balance(a[0])
  if (cmd === 'transfer' && a.length === 4) return transfer(a[0], a[1], a[2], a[3])
  if (cmd === 'tokenbalance' && a.length === 2) return tokenbalance(a[0], a[1])
  console.log(`Usage:
  node wallet.js gen
  node wallet.js balance <privateKey>
  node wallet.js transfer <privateKey> <tokenAddress> <toAddress> <amount>
  node wallet.js tokenbalance <privateKey> <tokenAddress>`)
})()

