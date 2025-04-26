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

    constructor() {
        governmentAuthority = msg.sender;
    }

    modifier onlyAuthority() {
        require(msg.sender == governmentAuthority, "Not authorized");
        _;
    }

    function issuePassport(
        address citizen,
        string memory fullName,
        string memory nationality,
        uint256 dob
    ) public onlyAuthority {
        require(!passports[citizen].isIssued, "Passport already issued");
        passports[citizen] = Passport(fullName, nationality, dob, true);
    }

    function viewPassport(address citizen) public view returns (string memory, string memory, uint256, bool) {
        Passport memory p = passports[citizen];
        return (p.fullName, p.nationality, p.dob, p.isIssued);
    }

    // New Function: Update existing passport
    function updatePassport(
        address citizen,
        string memory fullName,
        string memory nationality,
        uint256 dob
    ) public onlyAuthority {
        require(passports[citizen].isIssued, "Passport not issued yet");
        passports[citizen] = Passport(fullName, nationality, dob, true);
    }

    // New Function: Revoke a passport
    function revokePassport(address citizen) public onlyAuthority {
        require(passports[citizen].isIssued, "Passport not issued yet");
        passports[citizen].isIssued = false;
    }

    // New Function: Check if passport is valid
    function isPassportValid(address citizen) public view returns (bool) {
        return passports[citizen].isIssued;
    }

    // New Function: Transfer government authority to new address
    function transferAuthority(address newAuthority) public onlyAuthority {
        require(newAuthority != address(0), "Invalid address");
        governmentAuthority = newAuthority;
    }
}// SPDX-License-Identifier: MIT
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

    constructor() {
        governmentAuthority = msg.sender;
    }

    modifier onlyAuthority() {
        require(msg.sender == governmentAuthority, "Not authorized");
        _;
    }

    function issuePassport(
        address citizen,
        string memory fullName,
        string memory nationality,
        uint256 dob
    ) public onlyAuthority {
        require(!passports[citizen].isIssued, "Passport already issued");
        passports[citizen] = Passport(fullName, nationality, dob, true);
    }

    function viewPassport(address citizen) public view returns (string memory, string memory, uint256, bool) {
        Passport memory p = passports[citizen];
        return (p.fullName, p.nationality, p.dob, p.isIssued);
    }
}

