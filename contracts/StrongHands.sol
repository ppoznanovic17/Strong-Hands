pragma solidity >=0.7.0 <0.9.0;

contract StrongHands{

    string name;
    address owner;
    

    struct Deposit{
        uint userBalance;
        uint time;
        uint bonus;
        
    }
    
     mapping(address => Deposit) public deposits;
     address[] private users;
     
     constructor () {
         name = "Strong Hands";
         owner = msg.sender;
     }
     
    function deposit() payable public {
        
        Deposit storage deposit = deposits[msg.sender];
        users.push(payable(msg.sender));
        if(deposit.userBalance == 0){
            deposit.time = block.timestamp;
            deposit.userBalance = msg.value;
            deposit.bonus = 0; 
        }else{
            deposit.userBalance += msg.value;
            deposit.time = block.timestamp;
        }
    }
    
    
    function withdraw() external{
        // belezim trenutno vreme
        uint time = block.timestamp;
        Deposit storage deposit = deposits[msg.sender];
        // ako je balans korisnika koji je pozvao ovu funkciju jednak nuli, zaustavlja se izvrsavanje
        require(deposit.userBalance != 0);
        // vreme potrebno da se pare izvuku bez penala je 25 minuta (ta vrednost je stavljena radi lakseg testiranja)
        if(time - deposit.time > 25 minutes){
            //salju se pare korisniku i edituje se njegov Deposit
            payable(msg.sender).transfer(deposit.userBalance + deposit.bonus);
            deposit.bonus = 0;
            deposit.userBalance = 0;
            deposit.time = 0;
        }else{
            //racunam razliku u dizanju i ostavljanju para na deposit (u minutima)
            uint timeDiff = (time - deposit.time) / 60;
            // racunam procenat vrednosti od ukupne vrednosti koju korisnik dize
            uint reducedPercent = 100 - 50 + timeDiff * 25;
            // racunam vrednost koju korisnik dize
            uint withdrawValue = (reducedPercent* deposit.userBalance + deposit.bonus) / 100;
            // racunam vrednost penala koji se placa
            uint reducedValue = (100 - reducedPercent) * deposit.userBalance / 100;
            payable(msg.sender).transfer(withdrawValue);
            for(uint40 i = 0; i < users.length; i++){
                if(deposits[users[i]].userBalance != 0){
                    // racunam koliko koji korisnik dobija bonusa
                    deposits[users[i]].bonus = (reducedValue * (deposits[users[i]].userBalance + deposits[users[i]].bonus)) / (address(this).balance - reducedValue);
                }
            }
            // korisniku koji je podigao pare restartujem vrednosti
            deposit.bonus = 0;
            deposit.userBalance = 0;
            deposit.time = 0;
        }
    }
    
    
    function withdrawBonus() public{
        require(deposits[msg.sender].bonus != 0);
        payable(msg.sender).transfer(deposits[msg.sender].bonus);
        deposits[msg.sender].bonus = 0;
    }
    
    function seeDeposit() external view  returns (uint) {
        return deposits[msg.sender].userBalance;
    }
    
    function seeBonus() external view  returns (uint) {
        return deposits[msg.sender].bonus;
    }
     function seeBalance() external view  returns (uint) {
        return address(this).balance;
    }
    
    function getName() public view  returns (string memory) {
        return name;
    }

    function getOwner() public view  returns (address) {
        return owner;
    }

    event depositEvent();
    event withdrawEvent();
    
} 