// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PassportID {0x1eCE951ac7420ccb9248fe284ac4533152E4Ea07
    address public governmentAuthority;

    struct Passport {
        string fullName;
        string nationality;
        uint256 dob; // Date of birth as UNIX timestamp
        bool isIssued;
    }

    mapping(address => Passport) public passports;
    mapping(address => bool) private isHolder;
    address[] public passportHolders; 

    uint256 public totalIssued; 

    constructor() {
        governmentAuthority = msg.sender;
    }

    modifier onlyAuthority() {
        require(msg.sender == governmentAuthority, "Not authorized");
        _;
    }

    event PassportIssued(address indexed citizen);
    event PassportUpdated(address indexed citizen);
    event PassportRevoked(address indexed citizen);
    event AuthorityTransferred(address indexed oldAuthority, address indexed newAuthority);

    function issuePassport(
        address citizen,
        string memory fullName,
        string memory nationality,
        uint256 dob
    ) public onlyAuthority {
        require(!passports[citizen].isIssued, "Passport already issued");
        require(dob <= block.timestamp, "Invalid date of birth");
        passports[citizen] = Passport(fullName, nationality, dob, true);
        if (!isHolder[citizen]) {
            passportHolders.push(citizen);
            isHolder[citizen] = true;
        }
        totalIssued++;
        emit PassportIssued(citizen);
    }

    function viewPassport(address citizen) public view returns (string memory, string memory, uint256, bool) {
        Passport memory p = passports[citizen];
        return (p.fullName, p.nationality, p.dob, p.isIssued);
    }

    function updatePassport(
        address citizen,
        string memory fullName,
        string memory nationality,
        uint256 dob
    ) public onlyAuthority {
        require(passports[citizen].isIssued, "Passport not issued yet");
        require(dob <= block.timestamp, "Invalid date of birth");
        passports[citizen] = Passport(fullName, nationality, dob, true);
        emit PassportUpdated(citizen);
    }

    function revokePassport(address citizen) public onlyAuthority {
        require(passports[citizen].isIssued, "Passport not issued yet");
        passports[citizen].isIssued = false;
        totalIssued--;
        emit PassportRevoked(citizen);
    }

    function isPassportValid(address citizen) public view returns (bool) {
        return passports[citizen].isIssued;
    }

    function transferAuthority(address newAuthority) public onlyAuthority {
        require(newAuthority != address(0), "Invalid address");
        address oldAuthority = governmentAuthority;
        governmentAuthority = newAuthority;
        emit AuthorityTransferred(oldAuthority, newAuthority);
    }

    function requestPassportCancellation() public {
        require(passports[msg.sender].isIssued, "No active passport found");
        passports[msg.sender].isIssued = false;
        totalIssued--;
        emit PassportRevoked(msg.sender);
    }

    function totalActivePassports() public view returns (uint256) {
        return totalIssued;
    }

    function getAllPassportHolders() public view onlyAuthority returns (address[] memory) {
        return passportHolders;
    }

    // ----------------------- NEW FUNCTIONS -----------------------

    // View only active passport holders
    function getActivePassportHolders() public view onlyAuthority returns (address[] memory) {
        uint256 activeCount = 0;
        for (uint256 i = 0; i < passportHolders.length; i++) {
            if (passports[passportHolders[i]].isIssued) {
                activeCount++;
            }
        }

        address[] memory activeHolders = new address[](activeCount);
        uint256 index = 0;
        for (uint256 i = 0; i < passportHolders.length; i++) {
            if (passports[passportHolders[i]].isIssued) {
                activeHolders[index] = passportHolders[i];
                index++;
            }
