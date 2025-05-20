const { ethers } = require("hardhat");
const { expect } = require("chai");

const USDC = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eb48";
const WETH = "0xC02aaa39b223FE8D0A0e5C4F27eAD9083C756Cc2";
const USDC_HOLDER = "0x55fe002aeff02f77364de339a1292923a15844b8"; // 富有鲸鱼账户

describe("DexAggregatorRouter Swap Test", function () {
    let router, usdc, weth, user;

    beforeEach(async () => {
        [user] = await ethers.getSigners();

        // 部署 Router 合约
        const Router = await ethers.getContractFactory("DexAggregatorRouter");
        router = await Router.deploy();
        await router.deployed();

        // 获取 token 合约实例
        usdc = await ethers.getContractAt("IERC20", USDC);
        weth = await ethers.getContractAt("IERC20", WETH);

        // impersonate 一个富有的 USDC 持有者账户
        await ethers.provider.send("hardhat_impersonateAccount", [USDC_HOLDER]);
        const whale = await ethers.getSigner(USDC_HOLDER);

        // 给 user 一些 USDC
        const amount = ethers.utils.parseUnits("1000", 6);
        await usdc.connect(whale).transfer(user.address, amount);

        // user 授权 Router 使用 USDC
        await usdc.connect(user).approve(router.address, amount);
    });

    it("should swap USDC to WETH using Uniswap", async () => {
        const amountIn = ethers.utils.parseUnits("500", 6);
        const path = [USDC, WETH];
        const deadline = Math.floor(Date.now() / 1000) + 60;

        const wethBefore = await weth.balanceOf(user.address);

        await router.connect(user).swapExactTokensForTokens(
            amountIn,
            0, // 不设 slippage（测试方便）
            path,
            0, // 0 = UNISWAP
            deadline
        );

        const wethAfter = await weth.balanceOf(user.address);
        console.log("💰 Received WETH:", ethers.utils.formatEther(wethAfter.sub(wethBefore)));

        expect(wethAfter).to.be.gt(wethBefore);
    });
});
// npx hardhat test