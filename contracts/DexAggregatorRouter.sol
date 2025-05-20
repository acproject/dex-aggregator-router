// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IUniswapV2Router {
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function getAmountsOut(
        uint amountIn, 
        address[] calldata path) 
        external view returns (uint[] memory amounts);

    function WETH() external pure returns (address);
}

interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract DexAggregatorRouter is Pausable, Ownable {
    enum DEX {
        UNISWAP,
        SUSHISWAP
    }

    // 预定义两个 DEX Router 地址（Ethereum 主网）
    address constant UNISWAP_ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address constant SUSHISWAP_ROUTER = 0xd9e1CE17f2641f24aE83637ab66a2CCA9C378B9F;

    // 事件
    event SwapExecuted(address indexed user, address indexed inputToken, address indexed outputToken, uint amountIn, uint amountOut, DEX dex);

    constructor() Ownable(msg.sender) {
        // 初始化时不暂停合约
    }

    /**
     * @dev 暂停合约，只有合约所有者可以调用
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @dev 恢复合约，只有合约所有者可以调用
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    /**
     * @dev 在不同的 DEX 上执行代币交换
     * @param amountIn 输入代币数量
     * @param amountOutMin 最小输出代币数量
     * @param path 交换路径
     * @param dex 使用的 DEX
     * @param deadline 交易截止时间
     * @return amounts 交换结果数组
     */
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        DEX dex,
        uint deadline
    ) external whenNotPaused returns (uint[] memory amounts) {
        require(path.length >= 2, "Invalid path");
        address inputToken = path[0];
        address outputToken = path[path.length - 1];
        
        // 1. Transfer tokens from user to this contract
        IERC20(inputToken).transferFrom(msg.sender, address(this), amountIn);
        
        // 2. Approve tokens to the router
        address router = getRouterAddress(dex);
        IERC20(inputToken).approve(router, amountIn);
        
        // 3. Call the selected DEX router
        amounts = IUniswapV2Router(router).swapExactTokensForTokens(
            amountIn,
            amountOutMin,
            path,
            msg.sender,
            deadline
        );
        
        // 4. 发出事件
        emit SwapExecuted(msg.sender, inputToken, outputToken, amountIn, amounts[amounts.length - 1], dex);
        
        return amounts;
    }

    /**
     * @dev 获取 DEX 路由器地址
     * @param dex DEX 枚举值
     * @return 路由器地址
     */
    function getRouterAddress(DEX dex) internal pure returns (address) {
        if (dex == DEX.UNISWAP) {
            return UNISWAP_ROUTER;
        } else if (dex == DEX.SUSHISWAP) {
            return SUSHISWAP_ROUTER;
        } else {
            revert("Invalid DEX");
        }
    }

    /**
     * @dev 紧急提取合约中的代币，只有所有者可以调用
     * @param token 要提取的代币地址
     * @param amount 提取数量
     */
    function rescueTokens(address token, uint256 amount) external onlyOwner {
        IERC20(token).transfer(owner(), amount);
    }
}