// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Strategy_Avg {
    
    //logger statement
    event LogString(string);

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

    /*
    Add new value to stored values.
    Execute trade evaluation.
    */
    function addMockValue(uint256 newPrice) public{
        prices.push(newPrice);
        string memory recommendation;
        recommendation = evaluateLatestMovement();
        emit LogString(recommendation);

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

    function logValues() public returns (uint[] memory){
        return prices;
    }
}