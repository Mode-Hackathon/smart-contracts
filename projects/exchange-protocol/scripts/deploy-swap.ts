import { ethers, network, run } from "hardhat";

import { writeFileSync } from 'fs'

const devAddress = "0x1081cC43D898AaC3ca6D4AABe421ffb3AD88eA77"
const testSFSAddress = "0xBBd707815a7F7eb6897C7686274AFabd7B579Ff6"
const main = async () => {
    // Compile contracts
    // await run("compile");
    // console.log("Compiled contracts.");

    const WETH = await ethers.getContractFactory("WETH")
    const weth = await WETH.deploy()
    await weth.deployed()

    const v2Factory = await ethers.getContractFactory("PancakeFactory")
    const factory = await v2Factory.deploy(devAddress, testSFSAddress)
    await factory.deployed()

    const v2Router = await ethers.getContractFactory("PancakeRouter01")
    const router = await v2Router.deploy(factory.address, weth.address, testSFSAddress)
    await router.deployed()

    const contracts = {
        wrappedETH: weth.address,
        factory: factory.address,
        router: router.address
    }
    console.log(contracts)

    writeFileSync(`./deployments/${network.name}1.json`, JSON.stringify(contracts, null, 2))
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
