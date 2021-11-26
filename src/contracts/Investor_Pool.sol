// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract InvestorPool {
    
    //Events for logging purposes
    event LogString(string _string);
    event LogAddress(address _address);
    event LogNumber(uint256 _number);
    
    //all invested addresses
    address[] public investors;
    
    //stake = 1'000'000'000'000'000'000 equals 100%, stake = 0 
    uint256 totalSupply = 1000000000000000000;
    
    //address -> stake in pool
    mapping(address => uint256) public stakes;
    
    //minimum deposit 10'000'000'000'000'000 wei = 0.01 ether
    uint256 minDeposit = 10000000000000000;
    
    
    //Funktionen werden noch korrekt implementiert
    //CRUD functions for mapping
    function getInvestorStake(address _address) public view returns (uint256){
        return stakes[_address];
    }
    
    
    function removeInvestorAddress(address _address) public{
        //remove stake
        delete stakes[_address];
        //remove address from stored addresses
        uint256 investorsLength = investors.length;
        require(investorsLength > 0, "Cannot remove elements from empty array");
        address[] memory investorsTemp = new address[](investorsLength-1);
        
        uint c=0;
        for(uint i=0; i<investorsLength; i++){
            if(investors[i]!=_address){
                investorsTemp[c] = investors[i];
                c++;
            }
        }
        
        delete investors;
        
        for(uint i=0; i<investorsLength-1; i++){
            investors.push( investorsTemp[i] );
        }
    }
    
    
    
    function addInvestorAddress(address _address) private {
        require(_investorsContainsAddress(_address) == false, "Address already stored.");
        investors.push(_address);
    }
    
    function _investorsContainsAddress(address _address) private view returns (bool){
        for(uint i=0;i<investors.length;i++){
            if(investors[i] == _address){
                return true;
            }
        }
        return false;
    }
    
    function _sumInvestorStakes() public view returns (uint256){
        uint256 sum = 0;
        for(uint i=0; i<investors.length; i++){
            sum = sum + stakes[investors[i]];
        }
        return sum;
    }

    function _smallestInvestorByStake() private view returns (address){
        address investor = investors[0];
        for(uint i=1; i<investors.length; i++){
            if(stakes[investors[i]] < stakes[investor]){
                investor = investors[i];
            }
        }
        return investor;
    }
    
    function _logStoredInvestorInformation()public{
        for(uint i=0; i<investors.length; i++){
            //log address
            emit LogAddress( investors[i] );
            //log corresponding stakes
            emit LogNumber( stakes[ investors[i] ] );
        }
    }
    
    function recalculateAllStakesOnDeposit(uint256 amount) private {
        uint256 oldBalance = this.balance() - amount;
        for(uint i=0; i<investors.length; i++){
            stakes[investors[i]] = (stakes[investors[i]]*oldBalance)/(oldBalance + amount);
        }
    }

    function recalculateAllStakesOnWithdraw(uint256 amount) private {
        if(investors.length == 1){
            //stake = total supply
            stakes[investors[0]] = totalSupply;
        }else{
            if(investors.length > 0){
                //calculate stakes
                uint256 oldBalance = this.balance();
                for(uint i=0; i<investors.length; i++){
                    stakes[investors[i]] = (stakes[investors[i]]*oldBalance)/(oldBalance - amount);
                }
                //divide remainder between investors
                uint256 remainder = totalSupply - _sumInvestorStakes();
                uint256 share = remainder / investors.length;
                if(share > 0){
                    for(uint i=0; i<investors.length; i++){
                        stakes[investors[i]] = stakes[investors[i]] + share;
                    }
                }
                address smallest = _smallestInvestorByStake();
                stakes[smallest] = stakes[smallest] + (remainder - share * investors.length);
            }
        }
    }
    
    function balance() external view returns (uint256){
        return address(this).balance;
    }
    
    
    function deposit() external payable{
        //check if minimum deposit size applies, if yes abort transaction
        require(msg.value >= minDeposit, "Min 0.01eth");
        
        //assign new stakes for everyone, add address to investors on first deposit
        if(investors.length < 1){
            addInvestorAddress(msg.sender);
            stakes[msg.sender] = totalSupply;
        }else{
            if(!_investorsContainsAddress(msg.sender)){
                addInvestorAddress(msg.sender);
            }
            recalculateAllStakesOnDeposit(msg.value);
            stakes[msg.sender] = totalSupply - _sumInvestorStakes() + stakes[msg.sender];
        }
    }
    
    function withdraw() external payable{
        require(_investorsContainsAddress(msg.sender), "Address not investor.");
        uint256 amount = (stakes[msg.sender]*this.balance())/totalSupply;
        removeInvestorAddress(msg.sender);
        recalculateAllStakesOnWithdraw(amount);
        (bool success, ) = msg.sender.call{value:amount}("");
        require(success, "Transfer failed.");
    }
}