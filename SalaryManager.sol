// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;


contract SalaryManager {

    enum Property { notExitAccount,controlAccount, normalAccount} 
    enum Status   { disable, enable}
    uint public totalBalance;
    
    struct Account {
        Property accountProperty;
        uint withdrawLimit;
        Status accoutStatus;
    }
    
    
    
    mapping(address => Account) public account;
    
    constructor () {
        account[msg.sender].accountProperty = Property.controlAccount;
        account[msg.sender].accoutStatus = Status.enable;
        account[msg.sender].withdrawLimit = 2**100;
    }
    
    modifier isControlAccount (){
        
        require(account[msg.sender].accountProperty == Property.controlAccount, "You are not the control account!");
        _;
    }
    
    modifier isWithdrawable (address payable _account,uint _amount) {
        
        require(account[_account].accountProperty != Property.notExitAccount, "Error, you are not permit to withdraw!");
        require(account[_account].accoutStatus == Status.enable, "Error, you are not permit to withdraw!");
        require(_amount<= account[_account].withdrawLimit, "Error, exceed the withdraw limit!");
        require(totalBalance >= _amount, "Balance not enough!");
        _;
    }
    
    function deposit() public payable {
        totalBalance += msg.value;
    }
    
    function addAccount(address _account, uint _withdrawLimit) public isControlAccount returns(bool) {
        
        account[_account].accountProperty = Property.normalAccount;
        account[_account].accoutStatus = Status.enable;
        account[_account].withdrawLimit= _withdrawLimit;
        
        return true;
    }
    
    function disableAccountWithdraw(address _account) public isControlAccount returns(bool) {
        
        account[_account].accoutStatus = Status.disable;
        
        return true;
    }
    
    function enableAccountWithdraw(address _account) public isControlAccount returns(bool) {
        
        account[_account].accoutStatus = Status.enable;
        
        return true;
    }
    
    function withdrawTo(address payable _account, uint _amount) public isWithdrawable(_account,_amount) returns(bool) {
        
        account[_account].withdrawLimit -= _amount;
        totalBalance -= _amount;
        _account.transfer(_amount);

        
        return true;
    }
    
    function destroyContract() public  isControlAccount returns(bool){
        selfdestruct(payable(msg.sender));
        return true;
    }
    
    receive() external payable {
        deposit();
    }
}
