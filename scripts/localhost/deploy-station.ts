import { ethers, upgrades } from "hardhat"
import path from "path"
import fs from "fs/promises"

const { NODE_ENV, PRICE_FEED_ADDRESS_TESTNET, PRICE_FEED_ADDRESS_MAINNET } =
  process.env

const priceFeedAddress =
  NODE_ENV === "production"
    ? PRICE_FEED_ADDRESS_MAINNET
    : PRICE_FEED_ADDRESS_TESTNET

async function main() {
  const DiiRStation = await ethers.getContractFactory("DiiRStation")
  const diirStation = await upgrades.deployProxy(DiiRStation, [
    priceFeedAddress,
  ])

  await diirStation.deployed()

  console.log("DiiRStation deployed to:", diirStation.address)
  // Pull the address and ABI out, since that will be key in interacting with the smart contract later.
  const data = {
    address: diirStation.address,
    abi: JSON.parse(diirStation.interface.format("json") as string),
  }

  await fs.writeFile(
    path.join(__dirname, "../..", "/abi/localhost/DiiRStation.json"),
    JSON.stringify(data)
  )
}

main().catch((error) => {
  console.error("error: ", error)
  process.exitCode = 1
})
