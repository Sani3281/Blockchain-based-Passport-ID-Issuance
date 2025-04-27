// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PassportID {
    address public governmentAuthority;

    struct Passport {
        string fullName;
        string nationality;
        uint256 dob; // Date of birth as UNIX timestamp
        bool isIssued;
    }

    mapping(address => Passport) public passports;
    address[] public passportHolders; // New array to store citizen addresses

    uint256 public totalIssued; // Track total issued passports

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
        passports[citizen] = Passport(fullName, nationality, dob, true);
        passportHolders.push(citizen);
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

    // New Function: Citizen can request passport revocation
    function requestPassportCancellation() public {
        require(passports[msg.sender].isIssued, "No active passport found");
        passports[msg.sender].isIssued = false;
        totalIssued--;
        emit PassportRevoked(msg.sender);
    }

    // New Function: View total number of active passports
    function totalActivePassports() public view returns (uint256) {
        return totalIssued;
    }

    // New Function: View all passport holders (Only authority)
    function getAllPassportHolders() public view onlyAuthority returns (address[] memory) {
        return passportHolders;
    }
}
