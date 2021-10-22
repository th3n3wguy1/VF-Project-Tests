// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 < 0.9.0;

contract StoreString{

    string value;

    function get() public view returns (string memory){

        return value;

    }

    function set(string calldata s) public{

        value = s;

    }
    
}