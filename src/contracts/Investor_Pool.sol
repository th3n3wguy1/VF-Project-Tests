// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract InvestorPool {
    
    //all invested addresses
    address[] public investors;
    
    //address -> stake in pool
    //stake = 1'000'000'000'000'000'000 equals 100%, stake = 0 
    mapping(address => uint256) public stakes;
    
    
    //Funktionen werden noch korrekt implementiert
    //CRUD functions for mapping
    function getInvestorStake(address _address) public view returns (uint256){
        return stakes[_address];
    }
    
    function setInvestorStake(address _address, uint256 _stake) public {
        stakes[_address] = _stake;
    }
    
    function removeInvestor(address _address) public {
        delete stakes[_address];
    }
}