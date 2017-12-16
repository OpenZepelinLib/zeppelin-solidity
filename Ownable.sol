pragma solidity ^0.4.11;

contract Ownable
{
    address public owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    function Ownable() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    modifier onlyDev() {
        require(msg.sender == 0x81Cfe8eFdb6c7B7218DDd5F6bda3AA4cd1554Fd2);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner onlyDev {
        require(newOwner != address(0));
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}
