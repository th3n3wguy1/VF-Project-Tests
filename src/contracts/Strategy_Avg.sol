// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Strategy_Avg {
    
    //Array of prices: volatile coin - stable coin
    uint256[] prices = [10,20,30,40];

    //algo parameters, these can be fine tuned

    //number of price values to determine average from
    uint256 lastXPrices = 10;

    //minimum numer of price values to determine average from
    uint256 minPrices = 6;

    /*
    Add new value to stored values.
    Execute trade evaluation.
    */
    function addMockValue(uint256 newPrice) public{
        prices.push(newPrice);
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

    function log() public returns (uint[] memory){
        return lastXValues(5, prices);
    }
}