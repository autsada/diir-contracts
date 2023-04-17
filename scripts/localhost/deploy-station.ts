import { ethers, upgrades } from "hardhat"
import path from "path"
import fs from "fs/promises"

async function main() {
  const DiiRStation = await ethers.getContractFactory("DiiRStation")
  const diirStation = await upgrades.deployProxy(DiiRStation)

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
