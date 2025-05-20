const { ethers } = require("hardhat");

async function main() {
    const DeAggregatorRouter = await ethers.getContractFactory("DeAggregatorRouter");
    const router = await DeAggregatorRouter.deploy();
    await router.deployed();
    console.log("DeAggregatorRouter deployed to:", router.address);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});

// 部署命令： npx hardhat run scripts/deploy.js --network hardhat