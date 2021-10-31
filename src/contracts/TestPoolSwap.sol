// SPDX-License-Identifier: MIT 

pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import './dependencies/ISwapRouter.sol';
import './dependencies/TransferHelper.sol';


contract TestPool{
   
    address public constant DAI = 0xaD6D458402F60fD3Bd25163575031ACDce07538D;
    address public constant WETH9 = 0xc778417E063141139Fce010982780140Aa0cD5Ab;
   
    address private owner1 = 0x7ba532dDD8Bae59205D4928B5d9aDb9113AA6Cbe;
    address private owner2 = 0x829aDc66aaF720A896447e66a0163f74b09D3FF4;
    
    ISwapRouter public immutable swapRouter;
  
   
    mapping (address => uint256) private Investor;
   
   
    uint24 public constant poolFee = 3000;

    constructor() {
        swapRouter = ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);
    }
    
    
    function deposit() public payable{
        
         Investor[msg.sender] += msg.value;

    }
   
    
    function getCapitalDAI() public view returns (uint256){
        
        return IERC20(DAI).balanceOf(address(this));
        
    }
   
    function getCapitalWETH() public view returns (uint256){
        
        return IERC20(WETH9).balanceOf(address(this));
        
    }
    
    function getETHCapital() public view returns (uint256) {
        
        return address(this).balance;
        
    }
    
    function swapExactDaiToWETH(uint256 amountIn) external payable returns (uint256 amountOut) {
    
        // Approve the router to spend DAI.
        TransferHelper.safeApprove(DAI, address(swapRouter), amountIn);

        // Naively set amountOutMinimum to 0. In production, use an oracle or other data source to choose a safer value for amountOutMinimum.
        // We also set the sqrtPriceLimitx96 to be 0 to ensure we swap our exact input amount.
        ISwapRouter.ExactInputSingleParams memory params =
            ISwapRouter.ExactInputSingleParams({
                tokenIn: DAI,
                tokenOut: WETH9,
                fee: poolFee,
                recipient: address(this),
                deadline: block.timestamp,
                amountIn: amountIn,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        // The call to `exactInputSingle` executes the swap.
        amountOut = swapRouter.exactInputSingle(params);
    }
    
    function swapExactWethToDai(uint256 amountIn) external payable returns (uint256 amountOut) {
    
        // Approve the router to spend DAI.
        TransferHelper.safeApprove(WETH9, address(swapRouter), amountIn);

        // Naively set amountOutMinimum to 0. In production, use an oracle or other data source to choose a safer value for amountOutMinimum.
        // We also set the sqrtPriceLimitx96 to be 0 to ensure we swap our exact input amount.
        ISwapRouter.ExactInputSingleParams memory params =
            ISwapRouter.ExactInputSingleParams({
                tokenIn: WETH9,
                tokenOut: DAI,
                fee: poolFee,
                recipient: address(this),
                deadline: block.timestamp,
                amountIn: amountIn,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        // The call to `exactInputSingle` executes the swap.
        amountOut = swapRouter.exactInputSingle(params);
    }
}
