import { ethers, upgrades } from "hardhat"
import path from "path"
import fs from "fs/promises"

import TipContract from "../../abi/localhost/DiiRTip.json"

async function main() {
  const DiiRTipV1 = await ethers.getContractFactory("DiiRTipV1")
  const diirTipV1 = await upgrades.upgradeProxy(TipContract.address, DiiRTipV1)

  await diirTipV1.deployed()

  console.log("DiiRTipV1 deployed to:", diirTipV1.address)
  // Pull the address and ABI out, since that will be key in interacting with the smart contract later.
  const data = {
    address: diirTipV1.address,
    abi: JSON.parse(diirTipV1.interface.format("json") as string),
  }

  await fs.writeFile(
    path.join(__dirname, "../..", "/abi/localhost/DiiRTipV1.json"),
    JSON.stringify(data)
  )
}

main().catch((error) => {
  console.error("error: ", error)
  process.exitCode = 1
})
