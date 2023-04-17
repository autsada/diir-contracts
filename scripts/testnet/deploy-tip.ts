import { ethers, upgrades } from "hardhat"
import path from "path"
import fs from "fs/promises"

import ProfileContract from "../../abi/testnet/DiiRProfile.json"

const { NODE_ENV, PRICE_FEED_ADDRESS_TESTNET, PRICE_FEED_ADDRESS_MAINNET } =
  process.env

const priceFeedAddress =
  NODE_ENV === "production"
    ? PRICE_FEED_ADDRESS_MAINNET
    : PRICE_FEED_ADDRESS_TESTNET

async function main() {
  const DiiRTip = await ethers.getContractFactory("DiiRTip")
  const diirTip = await upgrades.deployProxy(DiiRTip, [
    ProfileContract.address,
    priceFeedAddress,
  ])

  await diirTip.deployed()

  console.log("DiiRTip deployed to:", diirTip.address)
  // Pull the address and ABI out, since that will be key in interacting with the smart contract later.
  const data = {
    address: diirTip.address,
    abi: JSON.parse(diirTip.interface.format("json") as string),
  }

  await fs.writeFile(
    path.join(__dirname, "../..", "/abi/testnet/DiiRTip.json"),
    JSON.stringify(data)
  )
}

main().catch((error) => {
  console.error("error: ", error)
  process.exitCode = 1
})
