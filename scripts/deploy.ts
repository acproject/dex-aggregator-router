import { ethers } from "hardhat";
import { Contract } from "ethers";

async function main(): Promise<void> {
    const DeAggregatorRouter = await ethers.getContractFactory("DexAggregatorRouter");
    const router = await DeAggregatorRouter.deploy();
    await router.deployed();
    console.log("DexAggregatorRouter deployed to:", router.address);
}

main().catch((error: Error) => {
    console.error(error);
    process.exitCode = 1;
});

// 部署命令： npx hardhat run scripts/deploy.ts --network hardhat