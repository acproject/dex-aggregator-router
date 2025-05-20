# Sample Hardhat Project

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, and a Hardhat Ignition module that deploys that contract.

Try running some of the following tasks:

```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat ignition deploy ./ignition/modules/Lock.ts
```
todo:
➕ 加入 slippage 容错处理逻辑（设定最小接收数）

➕ 加入 SushiSwap 路由测试

➕ 聚合报价模块（getBestDex）→ 初步优化路由选择

🚀 集成前端 UI 模拟 swap（可选）