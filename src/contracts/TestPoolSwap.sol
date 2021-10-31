// SPDX-License-Identifier: MIT 

/*
Erster Entwurf für Contract-Based-Swapping. Logik nicht mal ansatzweise final.

ToDO:
1. Rollen für Zugriffskontrollen müssen hinzugefügt werden
2. Externe Swapper zahlen Gas-Fees
3. Belohnung für Zahlende. ANregung schaffen
4. Arbitrum??
5. Strategie Smart Contract (getInverstmentAdvice)

Erste Deposits in Contract selbst müssen von außerhalb (TypeSkript) erfolgen.

*/

pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import './dependencies/ISwapRouter.sol';
import './dependencies/TransferHelper.sol';


contract VFPool{
   
    address public constant DAI = 0xaD6D458402F60fD3Bd25163575031ACDce07538D;
    address public constant WETH9 = 0xc778417E063141139Fce010982780140Aa0cD5Ab;
  
    ISwapRouter public immutable swapRouter;
   
    // Investoren dokumentieren. 
    struct Investor{
        IERC20 deposit_token;
        uint256 deposit_amount;
    }
    mapping(address => Investor) private Investors;
    
    // Später vlt verwenden um Input zu vereinfachen.
    mapping(address => string) private Tokens;
   
    address[] private InvestorAddre;
   
    uint24 public constant poolFee = 3000;

    constructor() {
        buildTokenAddresses();
        swapRouter = ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);
    }
    
    // Im Moment nur for Fun
    function buildTokenAddresses() private{
        
        Tokens[DAI] = "DAI";
        Tokens[WETH9] = "WETH9";
        
    }
    
    // Neuen Investor erstellen. Muss beim Deposit (TypeSkript) zusätzlich aufgerufen werden
    function addInvestor(address address_, address token_, uint256 amount_) public{
        
        Investor storage investor = Investors[address_];
        investor.deposit_token = IERC20(token_);
        investor.deposit_amount = amount_;
        
        InvestorAddre.push(address_);
    }
    
    // Auszahlen von eingezahlten Token
    function withdraw(address _address, address _token, uint256 _amount) public payable {
        
        // Im Moment nur zu Test-zwecken auf einzelne Punkte geachtet. Nicht final
        require(Investors[_address].deposit_token == IERC20(_token), "No balance under this token");
        require(Investors[_address].deposit_amount >= _amount, "Not enough balance in Account");
        
        require(IERC20(DAI).balanceOf(address(this)) >= _amount, "Contract does currently not hold enough of this token");
        
        Investors[_address].deposit_amount -= _amount;
        
        IERC20(_token).transfer(_address, _amount);
        
    }
    
    
    //Getter Funktionen
    function getCapitalDAI() public view returns (uint256){
        
        return IERC20(DAI).balanceOf(address(this));
        
    }
   
    function getCapitalWETH() public view returns (uint256){
        
        return IERC20(WETH9).balanceOf(address(this));
        
    }
    
    function getETHCapital() public view returns (uint256) {
        
        return address(this).balance;
        
    }
    
    // Hard-Coded Swap funktionen
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
