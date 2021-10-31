// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.0;

/*
Erster Entwurf für Contract-Based-Swapping. Logik nicht mal ansatzweise final.

ToDO:
1. Rollen für Zugriffskontrollen müssen hinzugefügt werden
2. Externe Swapper zahlen Gas-Fees
3. Belohnung für Zahlende. ANregung schaffen
4. Arbitrum??
5. Strategie Smart Contract (getInverstmentAdvice)
6. Capitalpool allgemeine Funktion klären, Anteile, Token auszahlen,...

Erste Deposits in Contract selbst müssen von außerhalb (TypeSkript) erfolgen.

*/


import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import './dependencies/ISwapRouter.sol';
import './dependencies/TransferHelper.sol';

/** @author VF-Team
 *  @title Volatility-Farming-Pool template 
 */ 
contract VFPool{
   
    address public constant DAI = 0xaD6D458402F60fD3Bd25163575031ACDce07538D;
    address public constant WETH9 = 0xc778417E063141139Fce010982780140Aa0cD5Ab;
    uint24 public constant poolFee = 3000;

    ISwapRouter public immutable swapRouter;
  
    mapping(address => Investor) private Investors;

    address[] private InvestorAddre;
    
    struct Investor{
        IERC20 deposit_token;
        uint256 deposit_amount;
    }
 

    /** Sets swap router
     */
    constructor(address _router) {
        
        swapRouter = ISwapRouter(_router);
        
    }
    
    /** Adds a new investor to the memory stored stuct / mapping
     *  @param address_ is the new investors address
     *  @param token_ is the token, the investor deposited in the Contract
     *  @param amount_ is the amount of token, he deposited in the contract
     *  @dev adds the address to the InvestorAddre array
     */
    function addInvestor(address address_, address token_, uint256 amount_) public{
        
        Investor storage investor = Investors[address_];
        investor.deposit_token = IERC20(token_);
        investor.deposit_amount = amount_;
        
        InvestorAddre.push(address_);
    }
    
    
    /**
     * 
     * 
     */
    function withdraw(address _address, address _token, uint256 _amount) public payable {
        
        require(IERC20(DAI).balanceOf(address(this)) >= _amount, "Contract does currently not hold enough of this token");
        
        Investors[_address].deposit_amount -= _amount;
        
        IERC20(_token).transfer(_address, _amount);
        
    }
    
    
    function getTokenCapital(address token) public view returns (uint256){
        
        return IERC20(token).balanceOf(address(this));
    
    }
    
    
     function getInvestors() public view returns (address[] memory) {
        return InvestorAddre;
    }
    
    
    function getEthAmount() public view returns (uint256) {
        return address(this).balance;
    }
    
    
    function investmentStrat() private pure returns (bool startTransfer, address tokenIN, address tokenOUT, uint256 amount){
        
        /*
        bool:
        TRUE, wenn swap ausgeführt werden soll
        FALSE, wenn swap nicht ausgeführt werden soll
        */
        
        return (true, address(0xaD6D458402F60fD3Bd25163575031ACDce07538D), address(0xc778417E063141139Fce010982780140Aa0cD5Ab), 1);
        
    }
    
    
    // To Be executed by BOT
    function executeCurrentInvestmentAdvices() public payable{
        
        (bool startTransfer, address tokenIN, address tokenOUT, uint256 amount) = investmentStrat();
        
        if (startTransfer == true) {
            swapExcactInToOut(
                amount,
                tokenIN, 
                tokenOUT
                );
        }
        
        // transferRewardsToExecutor();
        
    }
    
    
    function swapExcactInToOut(uint256 amountIn, address tokenIN, address tokenOUT) private returns (uint256 amountOut) {
    
        // Approve the router to spend DAI.
        TransferHelper.safeApprove(tokenIN, address(swapRouter), amountIn);

        // Naively set amountOutMinimum to 0. In production, use an oracle or other data source to choose a safer value for amountOutMinimum.
        // We also set the sqrtPriceLimitx96 to be 0 to ensure we swap our exact input amount.
        ISwapRouter.ExactInputSingleParams memory params =
            ISwapRouter.ExactInputSingleParams({
                tokenIn: tokenIN,
                tokenOut: tokenOUT,
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

