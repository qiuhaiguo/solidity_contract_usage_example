// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract ERC20 {
    
    uint   public totalSupply;
    uint   public decimals;
    string public name;
    string public symbol;
    address isOwner;
    mapping(address => uint) balances;
    
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Received(address indexed from, uint indexed amount);
    
    
    /**
     * Constrctor function
     *
     * Initializes contract with initial supply tokens to the creator of the contract
     */
    constructor (){
        isOwner = msg.sender;
        totalSupply = 1000*10**18;
        name = "Litentry";
        symbol = "LIT";
        decimals = 18;
        balances[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender,totalSupply);
    }
    
    modifier isTheOwner () {
        require(msg.sender == isOwner, "You are not the owner!");
        _;
    } 
    
    
    /**
     * Check balance 
     *
     * Check the balance of specified address
     */
    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }
    
    /**
     * Transfer token  
     *
     * Transfer erc20 token from sender to receiver with token amount
     */
    function transfer(address _to, uint amount) public returns(bool){
        
        require(balances[msg.sender]>= amount, "Not enough balance!");
        balances[msg.sender] -= amount;
        balances[_to] += amount;
        
        emit Transfer(msg.sender, _to, amount);
        return true;
    }
    
    function transferFrom(address _from, address _to, uint amount) public isTheOwner returns(bool) {
        
        require(_from == address(this), "Can not move token from other address, except contract itself");
        require(balances[_from]>= amount, "Not enough balance!");
        balances[_from] -= amount;
        balances[_to] += amount;
        
        emit Transfer(_from, _to, amount);
        return true;
    }
    
    function  destroyContract() public payable isTheOwner {
        selfdestruct(payable(isOwner));
    }
    
    receive() payable external {
        emit Received(msg.sender, msg.value);
    }
}
