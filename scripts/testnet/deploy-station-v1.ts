import { ethers, upgrades } from "hardhat"
import path from "path"
import fs from "fs/promises"

import StationContract from "../../abi/testnet/DiiRStation.json"

async function main() {
  const DiiRStationV1 = await ethers.getContractFactory("DiiRStation")
  const diirStationV1 = await upgrades.upgradeProxy(
    StationContract.address,
    DiiRStationV1
  )

  await diirStationV1.deployed()

  console.log("DiiRStationV1 deployed to:", diirStationV1.address)
  // Pull the address and ABI out, since that will be key in interacting with the smart contract later.
  const data = {
    address: diirStationV1.address,
    abi: JSON.parse(diirStationV1.interface.format("json") as string),
  }

  await fs.writeFile(
    path.join(__dirname, "../..", "/abi/testnet/DiiRStation.json"),
    JSON.stringify(data)
  )
}

main().catch((error) => {
  console.error("error: ", error)
  process.exitCode = 1
})
