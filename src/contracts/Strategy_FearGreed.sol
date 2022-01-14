// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Strategy_FearGreed {
    //logger statement
    event LogString(string);

    //Maximum Fear: 0, Maximum Greed: 100
    uint[] values = [10,12,34,50,58,70,90,70,30,20,22,34];

    //parameters for buy, sell, hold
    uint sellMargin = 75;
    uint buyMargin = 25;

    /*
    Add new value to stored values.
    Execute trade evaluation.
    */
    function addMockValue(uint256 newFearGreed) public{
        values.push(newFearGreed);
        string memory recommendation;
        recommendation = evaluateLatestValue();
        emit LogString(recommendation);
    }

    function evaluateLatestValue() private view returns (string memory){
        uint latest = values[values.length -1];
        if(latest > sellMargin){
            //recommend sell
            return "sell";
        }else{
            if(latest < buyMargin){
                //recommend buy
                return "buy";
            }else{
                //recommend hold
                return "hold";
            }
        }
    }
}