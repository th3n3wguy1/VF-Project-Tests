// SPDX-License-Identifier: MIT 

pragma solidity ^0.8.7;

import '@openzeppelin/contracts/access/AccessControl.sol';
import '../contracts/dependencies/ISwapRouter.sol';
import '../contracts/dependencies/TransferHelper.sol';

contract VFPool is AccessControl{

    //------ access setup
	bytes32 public constant PROVIDER_ROLE = keccak256("Provider");

	// swapping
    ISwapRouter private swapRouter;
	uint24 private constant poolFee = 3000;

    address private constant DAIRopsten = 0xaD6D458402F60fD3Bd25163575031ACDce07538D;
    address private constant WETH9Ropsten = 0xc778417E063141139Fce010982780140Aa0cD5Ab;
	
	//------ oracle request setup
	Request[] requests;
	uint256 currentId;
	struct Request{
		uint256 id;
		string tknPair;
		uint256 agreedValue;
	}
	
	event requestData(
		uint256 id,
		string tknPair
	);
	
	event requestDone(
		uint256 id,
		uint256 agreedValue
	);

    //------ trading setup
    //Array of prices: volatile coin - stable coin
    uint256[] prices = [10,20,30,40,30,60,12,34,35,38,23,49,23,25,30];

    //algo parameters, these can be fine tuned

    //number of price values to determine average from
    uint256 lastXPrices = 10;

    //minimum numer of price values to determine average from
    uint256 minPrices = 6;

    //comparisson parameters
    uint256 minDifferenceUp = 5;
    uint256 minDifferenceDown = 5;
	
	//------ basic address setup
	constructor() {
	
		currentId = 0;
        
        swapRouter = ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564); // Rinkeby and ropsten
        
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setRoleAdmin(PROVIDER_ROLE, DEFAULT_ADMIN_ROLE);
        
    }

//-----------------------------
// Access control

	modifier onlyAdmin()
    {
        require(isAdmin(msg.sender), "Restricted to admins!");   
        _;
    }

    modifier onlyProvider()
    {
        require(isProvider(msg.sender), "Restricted to user!");
        _;
    }
    
    function isAdmin(address toTest) public view returns(bool)
    {
        return hasRole(DEFAULT_ADMIN_ROLE, toTest);
    }
    
    function isProvider(address toTest) public view returns(bool)
    {
        return hasRole(PROVIDER_ROLE, toTest);
    }
    
    function addProvider(address toAdd) public onlyAdmin
    {
        grantRole(PROVIDER_ROLE, toAdd);
    }
    
    function addAdmin(address toAdd) public onlyAdmin
    {
        grantRole(DEFAULT_ADMIN_ROLE, toAdd);
    }
    
    function removeProvider(address toRemove) public onlyAdmin
    {
        revokeRole(PROVIDER_ROLE, toRemove);
    }
    
    function removeAdmin(address toRemove) public onlyAdmin
    {
        revokeRole(DEFAULT_ADMIN_ROLE, toRemove);
    }
	
//-----------------------------
// Oracle functions

	function execRequest(
		string memory _tknPair
	)
	public 
	onlyProvider
	{
		requests.push(Request(currentId, _tknPair,0));
		
		emit requestData(
			currentId,
			_tknPair
		);
		
		currentId++;
	}
	
	function callback(
		uint256 _id,
		uint256 _value
	)
	public
	payable
	onlyProvider
	{
		Request storage currRequest = requests[_id];
		currRequest.agreedValue = _value;
		
        prices.push(_value);

		emit requestDone(
			_id,
			_value
		);
	}

//-----------------------------
// Pool functions

	function swapExcactInToOut(
        uint256 amountIn, 
        address tokenIN, 
        address tokenOUT
        ) 
        public 
        onlyProvider
        returns (uint256 amountOut) {
    
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

	
	function investmentStrat() public payable onlyProvider returns (
            bool startTransfer, 
            address tokenIN, 
            address tokenOUT, 
            uint256 amount)
        {
        
        string memory recomm = evaluateLatestMovement();

		//to bee continued
        
        return (startTransfer, tokenIN, tokenOUT, 10000000000000 wei);
    }

    // To Be executed by BOT
    function executeCurrentInvestmentAdvices(
        //uint256 fee_for_api_call
        ) public onlyProvider{
        
        // Update API values and pay with LINK
        // depositLinkToAPI(fee_for_api_call);
        // updateVolume();
        
        // Get values from investmentStrat
        (
            bool startTransfer, 
            address tokenIN, 
            address tokenOUT, 
            uint256 amount
            ) = investmentStrat();
        
        if (startTransfer == true) {
            swapExcactInToOut(
                amount,
                tokenIN, 
                tokenOUT
            );
        }
    }

//-----------------------------
// Trading - Strat
    /*
    Add new value to stored values.
    Execute trade evaluation.
    */   
    function addMockValue() public returns (string memory){
        string memory recommendation;
        recommendation = evaluateLatestMovement();
        return recommendation;
    }

    function avg(uint[] memory numberArray) private view returns (uint){
        uint sum = 0;
        for(uint i=0; i<numberArray.length; i++){
            sum += 1000*numberArray[i];
        }
        uint numAvg = sum/numberArray.length;
        numAvg = numAvg/1000;
        return numAvg;
    }

    function lastXValues(uint x, uint[] memory numberArray) private view returns (uint[] memory){
        if(numberArray.length <= x){
            return numberArray;
        }else{
            uint[] memory lastValues = new uint[](x);
            uint iterator=0;
            for(uint i=numberArray.length - x; i<numberArray.length; i++){
                lastValues[iterator] = numberArray[i];
                iterator++;
            }
            return lastValues;
        }
    }

    function compareLatestPriceToRelevantValues()private view returns (uint, bool){
         uint[] memory relevantValues = lastXValues(lastXPrices, prices);
         require(relevantValues.length >= minPrices, "Not enough data.");
         uint latestPrice = prices[prices.length - 1];
         uint relevantAverage = avg(relevantValues);
         //actual comparisson here
         uint difference = 0;
         bool priceIsUp = false;
         if(latestPrice >= relevantAverage){
             difference = latestPrice - relevantAverage;
             priceIsUp = true;
         }else{
             difference = relevantAverage - latestPrice;
         }
         //return difference and price movement
         return (difference, priceIsUp);
    }

    //returns string: buy/sell/hold
    function evaluateLatestMovement() private view returns (string memory){
        bool priceIsUp;
        uint difference;
        (difference, priceIsUp) =  compareLatestPriceToRelevantValues();
        if(priceIsUp){
            if(difference >= minDifferenceUp){
                //recommend sell
                return "sell";
            }else{
                //recommend hold
                return "hold";
            }
        }else{
            if(difference >= minDifferenceDown){
                //recommend buy
                return "buy";
            }else{
                //recommend hold
                return "hold";
            }
        }
    }

        // transferRewardsToExecutor();
}
