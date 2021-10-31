// SPDX-License-Identifier: MIT 

pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import './dependencies/ISwapRouter.sol';
import './dependencies/TransferHelper.sol';


contract TestPool{
   
    address public constant DAI = 0xaD6D458402F60fD3Bd25163575031ACDce07538D;
    address public constant WETH9 = 0xc778417E063141139Fce010982780140Aa0cD5Ab;
  
    ISwapRouter public immutable swapRouter;
  
    struct Investor{
        IERC20 deposit_token;
        uint256 deposit_amount;
    }
 
    mapping(address => Investor) private Investors;
    
    mapping(address => string) private Tokens;
   
    address[] private InvestorAddre;
   
    uint24 public constant poolFee = 3000;
    uint256 private ID;

    constructor() {
        
        buildTokenAddresses();
        ID = 0;
        swapRouter = ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);
    }
    
    function buildTokenAddresses() private{
        
        Tokens[DAI] = "DAI";
        Tokens[WETH9] = "WETH9";
        
    }
    
    function addInvestor(address address_, address token_, uint256 amount_) public{
        
        Investor storage investor = Investors[address_];
        investor.deposit_token = IERC20(token_);
        investor.deposit_amount = amount_;
        
        InvestorAddre.push(address_);
    }
    
    
    function withdraw(address _address, address _token, uint256 _amount) public payable {
        
        require(Investors[_address].deposit_token == IERC20(_token), "No balance under this token");
        require(Investors[_address].deposit_amount >= _amount, "Not enough balance in Account");
        
        require(IERC20(DAI).balanceOf(address(this)) >= _amount, "Contract does currently not hold enough of this token");
        
        Investors[_address].deposit_amount -= _amount;
        
        IERC20(_token).transfer(_address, _amount);
        
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
