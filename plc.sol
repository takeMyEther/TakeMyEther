pragma solidity ^0.4.18;

contract ERC20 {
    function totalSupply() public constant returns (uint supply);
    function balanceOf(address who) public constant returns (uint value);
    function allowance(address owner, address spender) public constant returns (uint allowance);

    function transfer(address to, uint value) public returns (bool ok);
    function transferFrom(address from, address to, uint value) public returns (bool ok);
    function approve(address spender, uint value) public returns (bool ok);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract PlayCoin is ERC20{
    uint initialSupply = 100000000000;
    string public constant name = "PlayCoin";
    string public constant symbol = "PLC";
    uint freeCoinsPerUser = 100;
    address ownerAddress;

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    mapping (address => bool) authorizedContracts;
    mapping (address => bool) recievedFreeCoins;

    modifier onlyOwner {
        if (msg.sender == ownerAddress) {
            _;
        }
    }

    function authorizeContract(address authorizedAddress) public onlyOwner {
        authorizedContracts[authorizedAddress] = true;
    }

    function unAuthorizeContract(address authorizedAddress) public onlyOwner {
        authorizedContracts[authorizedAddress] = false;
    }

    function setFreeCoinsPerUser(uint number) public onlyOwner {
        freeCoinsPerUser = number;
    }

    function totalSupply() public constant returns (uint256) {
        return initialSupply;
    }

    function balanceOf(address owner) public constant returns (uint256 balance) {
        return balances[owner];
    }

    function allowance(address owner, address spender) public constant returns (uint allowance) {
        return allowed[owner][spender];
    }

    function authorizedTransfer(address from, address to, uint value) public {
        if (authorizedContracts[msg.sender] == true &&balances[from]>= value) {
            balances[from] -= value;
            balances[to] += value;
            Transfer (from, to, value);
        }
    }

    function transfer(address to, uint256 value) public returns (bool success) {
        if (balances[msg.sender] >= value && value > 0) {
            balances[msg.sender] -= value;
            balances[to] += value;
            Transfer(msg.sender, to, value);
            return true;
        } else {
            return false;
        }
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool success) {
        if (balances[from] >= value && allowed[from][msg.sender] >= value && value > 0) {
            balances[to] += value;
            balances[from] -= value;
            allowed[from][msg.sender] -= value;
            Transfer(from, to, value);
            return true;
        } else {
            return false;
        }
    }

    function approve(address spender, uint256 value) public returns (bool success) {
        allowed[msg.sender][spender] = value;
        Approval(msg.sender, spender, value);
        return true;
    }

    function PlayCoin() public {
        ownerAddress = msg.sender;
        balances[ownerAddress] = initialSupply;
    }

    function () public payable {
        uint valueToPass = msg.value/10**13;
        if (balances[ownerAddress] >= valueToPass && valueToPass > 0) {
            balances[msg.sender] = balances[msg.sender] + valueToPass;
            balances[ownerAddress] = balances[ownerAddress] - valueToPass;
            Transfer(ownerAddress, msg.sender, valueToPass);
        }
    }

    function withdraw(uint amount) public onlyOwner {
        ownerAddress.transfer(amount);
    }

    function getFreeCoins() public {
        if (recievedFreeCoins[msg.sender] == false) {
            recievedFreeCoins[msg.sender] = true;
            balances[msg.sender] = balances[msg.sender] + freeCoinsPerUser;
            balances[ownerAddress] = balances[ownerAddress] - freeCoinsPerUser;
            Transfer(ownerAddress, msg.sender, freeCoinsPerUser);
        }
    }
}