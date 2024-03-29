"use client"

import React, { useState } from "react"
import Link from "next/link"

const CourseSearch = ({ getSearchResults }) => {
  const [query, setQuery] = useState("")
  const [repos, setRepos] = useState([])
  const [selectedRepo, setSelectedRepo] = useState(null)
  const [errorMessage, setErrorMessage] = useState(null)
  const [selectedLanguage, setSelectedLanguage] = useState(null)
  const [languages, setLanguages] = useState({
    cpp: false,
    csharp: false,
    go: false,
    java: false,
    javascript: false,
    python: false,
    ruby: false,
    swift: false,
  })
  // CWE 항목에 대한 체크 상태를 관리하는 상태 변수 추가
  const [cweCheckboxes, setCWECheckboxes] = useState({})

  const handleCheckboxChange = (language) => {
    setSelectedLanguage((prevLanguage) =>
      prevLanguage === language ? null : language
    )
  }

  const handleCWECheckboxChange = (cweCode) => {
    setCWECheckboxes((prevCheckboxes) => ({
      ...prevCheckboxes,
      [cweCode]: !prevCheckboxes[cweCode],
    }))
  }

  // CWE 코드와 설명을 객체로 정의
  const cppCWEs = {
    "CWE-014": "Compiler Removal of Code to Clear Buffers",
    "CWE-022":
      'Improper Limitation of a Pathname to a Restricted Directory ("Path Traversal")',
    "CWE-078":
      'Improper Neutralization of Special Elements used in an OS Command ("OS Command Injection")',
    "CWE-079":
      'Improper Neutralization of Input During Web Page Generation ("Cross-site Scripting")',
    "CWE-089":
      'Improper Neutralization of Special Elements used in an SQL Command ("SQL Injection")',
    "CWE-114": "Process Control",
    "CWE-119":
      "Improper Restriction of Operations within the Bounds of a Memory Buffer",
    "CWE-120":
      'Buffer Copy without Checking Size of Input ("Classic Buffer Overflow")',
    "CWE-121": "Stack-based Buffer Overflow",
    "CWE-129": "Improper Validation of Array Index",
    "CWE-131": "Incorrect Calculation of Buffer Size",
    "CWE-134": "Use of Externally-Controlled Format String",
    "CWE-170": "Improper Null Termination",
    "CWE-190": "Integer Overflow or Wraparound",
    "CWE-191": "Integer Underflow (Wrap or Wraparound)",
    "CWE-193": "Off-by-one Error",
    "CWE-253": "Incorrect Check of Function Return Value",
    "CWE-290": "Authentication Bypass by Spoofing",
    "CWE-295": "Improper Certificate Validation",
    "CWE-311": "Missing Encryption of Sensitive Data",
    "CWE-313": "Cleartext Storage of Sensitive Information",
    "CWE-319": "Cleartext Transmission of Sensitive Information",
    "CWE-326": "Inadequate Encryption Strength",
    "CWE-327": "Use of a Broken or Risky Cryptographic Algorithm",
    "CWE-367": "Time-of-check Time-of-use (TOCTOU) Race Condition",
    "CWE-416": "Use After Free",
    "CWE-428": "Unquoted Search Path or Element",
    "CWE-457": "Use of Uninitialized Variable",
    "CWE-468": "Incorrect Pointer Scaling",
    "CWE-497": "Exposure of System Data to an Unauthorized Control Sphere",
    "CWE-570": "Expression is Always False",
    "CWE-611": "Improper Restriction of XML External Entity Reference",
    "CWE-676": "Use of Potentially Dangerous Function",
    "CWE-704": "Incorrect Type Conversion or Cast",
    "CWE-732": "Incorrect Permission Assignment for Critical Resource",
    "CWE-764": "Multiple Locks of a Critical Resource",
    "CWE-807": "Reliance on Untrusted Inputs in a Security Decision",
    "CWE-835": 'Loop with Unreachable Exit Condition ("Infinite Loop")',
    "CWE-843": 'Access of Resource Using Incompatible Type ("Type Confusion")',
  }

  const csharpCWEs = {
    "CWE-011": "Improper Check for Dropped Privileges",
    "CWE-016": "Configuration",
    "CWE-020": "Improper Input Validation",
    "CWE-022":
      'Improper Limitation of a Pathname to a Restricted Directory ("Path Traversal")',
    "CWE-078":
      'Improper Neutralization of Special Elements used in an OS Command ("OS Command Injection")',
    "CWE-079":
      'Improper Neutralization of Input During Web Page Generation ("Cross-site Scripting")',
    "CWE-089":
      'Improper Neutralization of Special Elements used in an SQL Command ("SQL Injection")',
    "CWE-090":
      'Improper Neutralization of Special Elements used in an LDAP Query ("LDAP Injection")',
    "CWE-091":
      'Improper Neutralization of Special Elements used in an XPath Expression ("XPath Injection")',
    "CWE-094": "Code Injection",
    "CWE-099": "Resource Management Errors",
    "CWE-112": "Missing XML Validation",
    "CWE-114": "Process Control",
    "CWE-117": "Improper Output Neutralization for Logs",
    "CWE-119":
      "Improper Restriction of Operations within the Bounds of a Memory Buffer",
    "CWE-134": "Use of Externally-Controlled Format String",
    "CWE-201": "Information Exposure",
    "CWE-209": "Information Exposure Through an Error Message",
    "CWE-248": "Uncaught Exception",
    "CWE-285": "Improper Authorization",
    "CWE-312": "Cleartext Storage of Sensitive Information in a Cookie",
    "CWE-321": "Use of Hard-coded Cryptographic Key",
    "CWE-352": "Cross-Site Request Forgery (CSRF)",
    "CWE-359": "Privacy Violation",
    "CWE-384": "Session Fixation",
    "CWE-451": "User Interface (UI) Misrepresentation of Critical Information",
    "CWE-502": "Deserialization of Untrusted Data",
    "CWE-548": "Uncontrolled Search Path Element",
    "CWE-601": "URL Redirection to Untrusted Site",
    "CWE-611": "Improper Restriction of XML External Entity Reference",
    "CWE-614": 'Sensitive Cookie Without "HttpOnly" Flag',
    "CWE-639": "Authorization Bypass Through User-Controlled Key",
    "CWE-643": "Improper Neutralization of Data within XPath Expressions",
    "CWE-730": "Exposure of Sensitive Information to an Unauthorized Actor",
    "CWE-798": "Use of Hard-coded Credentials",
    "CWE-807": "Reliance on Untrusted Inputs in a Security Decision",
    "CWE-838": "Inappropriate Encoding for Output Context",
    ETC: "",
  }

  const goCWEs = {
    "CWE-020": "Improper Input Validation",
    "CWE-022":
      'Improper Limitation of a Pathname to a Restricted Directory ("Path Traversal")',
    "CWE-078":
      'Improper Neutralization of Special Elements used in an OS Command ("OS Command Injection")',
    "CWE-079":
      'Improper Neutralization of Input During Web Page Generation ("Cross-site Scripting")',
    "CWE-089":
      'Improper Neutralization of Special Elements used in an SQL Command ("SQL Injection")',
    "CWE-117": "Improper Output Neutralization for Logs",
    "CWE-190": "Integer Overflow or Wraparound",
    "CWE-209": "Information Exposure Through an Error Message",
    "CWE-295": "Improper Certificate Validation",
    "CWE-312": "Cleartext Storage of Sensitive Information in a Cookie",
    "CWE-322": "Use of a Hard-coded Cipher Key",
    "CWE-326": "Inadequate Encryption Strength",
    "CWE-327": "Use of a Broken or Risky Cryptographic Algorithm",
    "CWE-338": "Use of Cryptographically Weak PRNG",
    "CWE-347": "Improper Verification of Cryptographic Signature",
    "CWE-352": "Cross-Site Request Forgery (CSRF)",
    "CWE-601": "URL Redirection to Untrusted Site",
    "CWE-640": "Weak Password Recovery Mechanism for Forgotten Password",
    "CWE-643": "Improper Neutralization of Data within XPath Expressions",
    "CWE-681": "Incorrect Conversion between Numeric Types",
    "CWE-770": "Allocation of Resources Without Limits or Throttling",
    "CWE-789": "Uncontrolled Memory Allocation",
    "CWE-918": "Server-Side Request Forgery (SSRF)",
  }

  const javaCWEs = {
    "CWE-020": "Improper Input Validation",
    "CWE-022":
      'Improper Limitation of a Pathname to a Restricted Directory ("Path Traversal")',
    "CWE-023": "Relative Path Traversal",
    "CWE-074":
      "Improper Neutralization of Special Elements in Output Used by a Downstream Component",
    "CWE-078":
      'Improper Neutralization of Special Elements used in an OS Command ("OS Command Injection")',
    "CWE-079":
      'Improper Neutralization of Input During Web Page Generation ("Cross-site Scripting")',
    "CWE-089":
      'Improper Neutralization of Special Elements used in an SQL Command ("SQL Injection")',
    "CWE-090":
      "Improper Neutralization of Special Elements used in an LDAP Query",
    "CWE-094":
      'Improper Control of Generation of Code ("Generated Code Injection")',
    "CWE-104":
      "Failure to Constrain Operations within the Bounds of a Memory Buffer",
    "CWE-113": "Improper Neutralization of CRLF Sequences in HTTP Headers",
    "CWE-117": "Improper Output Neutralization for Logs",
    "CWE-120":
      'Buffer Copy without Checking Size of Input ("Classic Buffer Overflow")',
    "CWE-129": "Improper Validation of Array Index",
    "CWE-134": "Use of Externally-Controlled Format String",
    "CWE-190": "Integer Overflow or Wraparound",
    "CWE-200": "Exposure of Sensitive Information to an Unauthorized Actor",
    "CWE-209": "Information Exposure Through an Error Message",
    "CWE-266": "Incorrect Privilege Assignment",
    "CWE-273": "Improper Check for Dropped Privileges",
    "CWE-295": "Improper Certificate Validation",
    "CWE-297": "Improper Validation of Certificate with Host Mismatch",
    "CWE-312": "Cleartext Storage of Sensitive Information in a Cookie",
    "CWE-326": "Inadequate Encryption Strength",
    "CWE-327": "Use of a Broken or Risky Cryptographic Algorithm",
    "CWE-330": "Use of Insufficiently Random Values",
    "CWE-335":
      "Incorrect Usage of Seeds in Pseudo-Random Number Generator (PRNG)",
    "CWE-338": "Use of Cryptographically Weak PRNG",
    "CWE-347": "Improper Verification of Cryptographic Signature",
    "CWE-352": "Cross-Site Request Forgery (CSRF)",
    "CWE-367": "Time-of-check Time-of-use (TOCTOU) Race Condition",
    "CWE-421": "Race Condition During Access to Critical Section",
    "CWE-441": 'Unintended Proxy or Intermediary ("Man-in-the-Middle")',
    "CWE-470":
      'Use of Externally-Controlled Input to Select Classes or Code ("Unsafe Reflection")',
    "CWE-489": "Leftover Debug Code",
    "CWE-501": "Trust Boundary Violation",
    "CWE-502": "Deserialization of Untrusted Data",
    "CWE-522": "Insufficiently Protected Credentials",
    "CWE-524": "Use of a Key Past its Expiration Date",
    "CWE-532": "Insertion of Sensitive Information into Log File",
    "CWE-601": "URL Redirection to Untrusted Site",
    "CWE-611": "Improper Restriction of XML External Entity Reference",
    "CWE-614": "Sensitive Cookie Without Secure Attribute",
    "CWE-643": "Improper Neutralization of Data within XPath Expressions",
    "CWE-676": "Use of Potentially Dangerous Function",
    "CWE-681": "Incorrect Conversion between Numeric Types",
    "CWE-730": "Exposed to Web",
    "CWE-732": "Incorrect Permission Assignment for Critical Resource",
    "CWE-749": "Exposed Dangerous Method or Function",
    "CWE-780": "Use of RSA Algorithm without OAEP",
    "CWE-789": "Uncontrolled Memory Allocation",
    "CWE-807": "Reliance on Untrusted Inputs in a Security Decision",
    "CWE-829": "Inclusion of Functionality from Untrusted Control Sphere",
    "CWE-833": "Deadlock",
    "CWE-835": 'Loop with Unreachable Exit Condition ("Infinite Loop")',
    "CWE-917":
      "Improper Neutralization of Special Elements used in an Expression Language Statement",
    "CWE-918": "Server-Side Request Forgery (SSRF)",
    "CWE-925":
      "Improper Verification of Cryptographic Signature with Key Recovery",
    "CWE-926": "Improper Export of Android Application Components",
    "CWE-927": "Use of Implicit Intent for Sensitive Communication",
    "CWE-940": "Improper Verification of Source of a Communication Channel",
  }

  const javascriptCWEs = {
    "CWE-020": "Improper Input Validation",
    "CWE-022": "Path Traversal",
    "CWE-073": "External Control of File Name or Path",
    "CWE-078": "OS Command Injection",
    "CWE-079": "Cross-site Scripting (XSS)",
    "CWE-089": "SQL Injection",
    "CWE-094": "Code Injection",
    "CWE-1004": "Sensitive Cookie Without 'httponly' Flag",
    "CWE-116": "Improper Encoding or Escaping of Output",
    "CWE-117": "Improper Output Neutralization for Logs",
    "CWE-1275": "Insufficiently Protected Credentials",
    "CWE-134": "Use of Externally-Controlled Format String",
    "CWE-178": "Improper Handling of Case Sensitivity",
    "CWE-200": "Exposure of Sensitive Information to an Unauthorized Actor",
    "CWE-201": "Information Exposure Through Sent Data",
    "CWE-209": "Information Exposure Through an Error Message",
    "CWE-295": "Improper Certificate Validation",
    "CWE-300": "Channel Accessible by Non-Endpoint",
    "CWE-312": "Cleartext Storage of Sensitive Information",
    "CWE-313": "Cleartext Storage in a File or on Disk",
    "CWE-326": "Inadequate Encryption Strength",
    "CWE-327": "Use of a Broken or Risky Cryptographic Algorithm",
    "CWE-338":
      "Use of Cryptographically Weak Pseudo-Random Number Generator (PRNG)",
    "CWE-346": "Origin Validation Error",
    "CWE-347": "Improper Verification of Cryptographic Signature",
    "CWE-352": "Cross-Site Request Forgery (CSRF)",
    "CWE-367": "Time-of-check Time-of-use (TOCTOU) Race Condition",
    "CWE-377": "Insecure Temporary File",
    "CWE-384": "Session Fixation",
    "CWE-400": "Uncontrolled Resource Consumption",
    "CWE-451": "User Interface (UI) Misrepresentation of Critical Information",
    "CWE-502": "Deserialization of Untrusted Data",
    "CWE-506": "Embedded Malicious Code",
    "CWE-598": "Information Exposure Through Query Strings in GET Request",
    "CWE-601": "URL Redirection to Untrusted Site ('Open Redirect')",
    "CWE-611": "Improper Restriction of XML External Entity Reference",
    "CWE-614": "Sensitive Cookie in HTTPS Session Without 'Secure' Attribute",
    "CWE-640": "Weak Password Recovery Mechanism for Forgotten Password",
    "CWE-643": "XPath Injection",
    "CWE-730": "OWASP Top Ten 2007 Category A1 - Cross Site Scripting (XSS)",
    "CWE-754": "Improper Check for Unusual or Exceptional Conditions",
    "CWE-770": "Allocation of Resources Without Limits or Throttling",
    "CWE-776":
      'Improper Restriction of Recursive Entity References in DTDs ("XML Entity Expansion")',
    "CWE-798": "Use of Hard-coded Credentials",
    "CWE-807": "Reliance on Untrusted Inputs in a Security Decision",
    "CWE-829": "Inclusion of Functionality from Untrusted Control Sphere",
    "CWE-830": "Inclusion of Web Script or HTML in a Non-Script Element",
    "CWE-834": "Omission of Security-relevant Information",
    "CWE-843": "Access of Resource Using Incompatible Type",
    "CWE-862": "Missing Authorization",
    "CWE-912": "Hidden Functionality",
    "CWE-915":
      "Improperly Controlled Modification of Dynamically-Determined Object Attributes",
    "CWE-916": "Use of Password Hash With Insufficient Computational Effort",
    "CWE-918": "Server-Side Request Forgery (SSRF)",
  }

  const pythonCWEs = {
    "CVE-2018-1281": "Apache MXNet Public Exposure Vulnerability",
    "CWE-020-ExternalAPIs": "Improper Validation of External APIs",
    "CWE-022": "Path Traversal",
    "CWE-078": "OS Command Injection",
    "CWE-079": "Cross-site Scripting (XSS)",
    "CWE-089": "SQL Injection",
    "CWE-090": "LDAP Injection",
    "CWE-094": "Code Injection",
    "CWE-116": "Improper Encoding or Escaping of Output",
    "CWE-117": "Improper Output Neutralization for Logs",
    "CWE-209": "Information Exposure Through an Error Message",
    "CWE-215": "Exposure of Sensitive Information Through Debug Information",
    "CWE-285": "Improper Authorization",
    "CWE-295": "Improper Certificate Validation",
    "CWE-312": "Cleartext Storage of Sensitive Information",
    "CWE-326": "Inadequate Encryption Strength",
    "CWE-327": "Use of a Broken or Risky Cryptographic Algorithm",
    "CWE-352": "Cross-Site Request Forgery (CSRF)",
    "CWE-377": "Insecure Temporary File",
    "CWE-502": "Deserialization of Untrusted Data",
    "CWE-601": "URL Redirection to Untrusted Site (Open Redirect)",
    "CWE-611": "Improper Restriction of XML External Entity Reference",
    "CWE-643": "XPath Injection",
    "CWE-730": "OWASP Top Ten 2007 Category A1 - Cross Site Scripting (XSS)",
    "CWE-732": "Incorrect Permission Assignment for Critical Resource",
    "CWE-776":
      "Improper Restriction of Recursive Entity References in DTDs (XML Entity Expansion)",
    "CWE-798": "Use of Hard-coded Credentials",
    "CWE-918": "Server-Side Request Forgery (SSRF)",
    "CWE-943":
      "Improper Neutralization of Special Elements in Data Query Logic",
  }

  const rubyCWEs = {
    "CWE-020": "Improper Input Validation",
    "CWE-022": "Path Traversal",
    "CWE-078": "OS Command Injection",
    "CWE-079": "Cross-site Scripting (XSS)",
    "CWE-089": "SQL Injection",
    "CWE-094": "Code Injection",
    "CWE-116": "Improper Encoding or Escaping of Output",
    "CWE-117": "Improper Output Neutralization for Logs",
    "CWE-1333": "Insufficient Encryption Strength",
    "CWE-134": "Use of Externally-Controlled Format String",
    "CWE-209": "Information Exposure Through an Error Message",
    "CWE-295": "Improper Certificate Validation",
    "CWE-300": "Channel Accessible by Non-Endpoint",
    "CWE-312": "Cleartext Storage of Sensitive Information",
    "CWE-327": "Use of a Broken or Risky Cryptographic Algorithm",
    "CWE-352": "Cross-Site Request Forgery (CSRF)",
    "CWE-502": "Deserialization of Untrusted Data",
    "CWE-506": "Embedded Malicious Code",
    "CWE-598": "Information Exposure Through Query Strings in GET Request",
    "CWE-601": "URL Redirection to Untrusted Site (Open Redirect)",
    "CWE-611": "Improper Restriction of XML External Entity Reference",
    "CWE-732": "Incorrect Permission Assignment for Critical Resource",
    "CWE-798": "Use of Hard-coded Credentials",
    "CWE-829": "Inclusion of Functionality from Untrusted Control Sphere",
    "CWE-912": "Hidden Functionality",
    "CWE-918": "Server-Side Request Forgery (SSRF)",
  }

  const swiftCWEs = {
    "CWE-020": "Improper Input Validation",
    "CWE-022": "Path Traversal",
    "CWE-078": "OS Command Injection",
    "CWE-079": "Cross-site Scripting (XSS)",
    "CWE-089": "SQL Injection",
    "CWE-094": "Code Injection",
    "CWE-116": "Improper Encoding or Escaping of Output",
    "CWE-1204": "General Description Not Found", // 이 항목은 표준 CWE 리스트에 명시되지 않았습니다.
    "CWE-1333": "General Description Not Found", // 이 항목은 표준 CWE 리스트에 명시되지 않았습니다.
    "CWE-134": "Use of Externally-Controlled Format String",
    "CWE-135": "Access Restriction Bypass", // 정확한 설명을 찾기 어려울 수 있습니다.
    "CWE-259": "Use of Hard-coded Password",
    "CWE-311": "Missing Encryption of Sensitive Data",
    "CWE-312": "Cleartext Storage of Sensitive Information",
    "CWE-321": "Use of Hard-coded Cryptographic Key",
    "CWE-327": "Use of a Broken or Risky Cryptographic Algorithm",
    "CWE-328": "Use of Weak Hash",
    "CWE-611": "Improper Restriction of XML External Entity Reference",
    "CWE-730": "OWASP Top Ten 2007 Category A1 - Cross Site Scripting (XSS)", // 정확한 설명을 찾기 어려울 수 있습니다.
    "CWE-757":
      'Selection of Less-Secure Algorithm During Negotiation ("Algorithm Downgrade")', // 정확한 설명을 찾기 어려울 수 있습니다.
    "CWE-760": "Use of a One-Way Hash without a Salt", // 정확한 설명을 찾기 어려울 수 있습니다.
    "CWE-916": "Use of Password Hash With Insufficient Computational Effort",
    "CWE-943":
      "Improper Neutralization of Special Elements in Data Query Logic",
  }

  return (
    <div
      className="flex justify-center flex-col mt-12"
      style={{ position: "absolute", left: 200 }}
    >
      <div>
        <p className="font-bold text-5xl">codeQL</p>
        <br />
        <br />
        <br />
        <div className="flex items-center mb-2">
          <p className="font-bold text-2xl mr-60">Languages</p>
          <div className="flex flex-row">
            <p className="font-bold text-2xl mr-80">CWE</p>
            <p className="font-bold text-2xl">Explanation</p>
          </div>
        </div>
        <br />
        <div style={{ display: "flex", alignItems: "flex-start" }}>
          <div>
            {Object.keys(languages).map((language) => (
              <div
                className="flex items-center mb-2"
                key={language}
                onClick={() => handleCheckboxChange(language)}
              >
                <div
                  className={`hover:cursor-pointer h-4 w-4 mr-2 border-2 ${
                    selectedLanguage === language
                      ? "border-blue-500 bg-blue-500"
                      : "border-gray-400"
                  }`}
                />
                <label htmlFor={language} className="text-lg cursor-pointer">
                  {language.charAt(0).toUpperCase() + language.slice(1)}
                </label>
              </div>
            ))}
          </div>
          {selectedLanguage === "cpp" && (
            <div
              className="ml-60"
              style={{ maxHeight: "400px", overflowY: "auto" }}
            >
              <Link href="/">
                <div
                  style={{ position: "absolute", right: 100, top: 20 }}
                  className="w-10 h-10 bg-blue-500 hover:bg-blue-700 font-bold text-white px-10 flex justify-center items-center rounded-lg"
                >
                  next
                </div>
              </Link>
              <div className="bg-white px-4 rounded-md">
                {Object.entries(cppCWEs).map(([cweCode, cweDescription]) => (
                  <div key={cweCode} className="flex items-center mb-2">
                    <div className="w-80 mr-40">
                      <div className="items-center flex">
                        <input
                          type="checkbox"
                          id={`cweCheckbox-${cweCode}`}
                          checked={cweCheckboxes[cweCode] || false}
                          onChange={() => handleCWECheckboxChange(cweCode)}
                          className="h-4 w-4 mr-4 border-gray-400 rounded focus:ring-gray-400 hover:cursor-pointer"
                        />
                        <label
                          htmlFor={`cweCheckbox-${cweCode}`}
                          className="text-lg hover:cursor-pointer"
                        >
                          {cweCode}
                        </label>
                      </div>
                    </div>
                    <div className="w-full ">
                      <div className="flex items-center">
                        <p>{cweDescription}</p>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}
          {selectedLanguage === "csharp" && (
            <div
              className="ml-60"
              style={{ maxHeight: "400px", overflowY: "auto" }}
            >
              <Link href="/">
                <div
                  style={{ position: "absolute", right: 100, top: 20 }}
                  className="w-10 h-10 bg-blue-500 hover:bg-blue-700 font-bold text-white px-10 flex justify-center items-center rounded-lg"
                >
                  next
                </div>
              </Link>
              <div className="bg-white px-4 rounded-md">
                {Object.entries(csharpCWEs).map(([cweCode, cweDescription]) => (
                  <div key={cweCode} className="flex items-center mb-2">
                    <div className="w-80 mr-40">
                      <div className=" ">
                        <input
                          type="checkbox"
                          id={`cweCheckbox-${cweCode}`}
                          checked={cweCheckboxes[cweCode] || false}
                          onChange={() => handleCWECheckboxChange(cweCode)}
                          className="h-4 w-4 mr-4 border-gray-400 rounded focus:ring-gray-400 hover:cursor-pointer"
                        />
                        <label
                          htmlFor={`cweCheckbox-${cweCode}`}
                          className="text-lg hover:cursor-pointer"
                        >
                          {cweCode}
                        </label>
                      </div>
                    </div>
                    <div className="w-full ">
                      <div className="">
                        <p>{cweDescription}</p>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}
          {selectedLanguage === "go" && (
            <div
              className="ml-60"
              style={{ maxHeight: "400px", overflowY: "auto" }}
            >
              <Link href="/">
                <div
                  style={{ position: "absolute", right: 100, top: 20 }}
                  className="w-10 h-10 bg-blue-500 hover:bg-blue-700 font-bold text-white px-10 flex justify-center items-center rounded-lg"
                >
                  next
                </div>
              </Link>
              <div className="bg-white px-4 rounded-md">
                {Object.entries(goCWEs).map(([cweCode, cweDescription]) => (
                  <div key={cweCode} className="flex items-center mb-2">
                    <div className="w-80 mr-40">
                      <div className=" ">
                        <input
                          type="checkbox"
                          id={`cweCheckbox-${cweCode}`}
                          checked={cweCheckboxes[cweCode] || false}
                          onChange={() => handleCWECheckboxChange(cweCode)}
                          className="h-4 w-4 mr-4 border-gray-400 rounded focus:ring-gray-400 hover:cursor-pointer"
                        />
                        <label
                          htmlFor={`cweCheckbox-${cweCode}`}
                          className="text-lg hover:cursor-pointer"
                        >
                          {cweCode}
                        </label>
                      </div>
                    </div>
                    <div className="w-full ">
                      <div className="">
                        <p>{cweDescription}</p>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}
          {selectedLanguage === "java" && (
            <div
              className="ml-60"
              style={{ maxHeight: "400px", overflowY: "auto" }}
            >
              <Link href="/">
                <div
                  style={{ position: "absolute", right: 100, top: 20 }}
                  className="w-10 h-10 bg-blue-500 hover:bg-blue-700 font-bold text-white px-10 flex justify-center items-center rounded-lg"
                >
                  next
                </div>
              </Link>
              <div className="bg-white px-4 rounded-md">
                {Object.entries(javaCWEs).map(([cweCode, cweDescription]) => (
                  <div key={cweCode} className="flex items-center mb-2">
                    <div className="w-80 mr-40">
                      <div className=" ">
                        <input
                          type="checkbox"
                          id={`cweCheckbox-${cweCode}`}
                          checked={cweCheckboxes[cweCode] || false}
                          onChange={() => handleCWECheckboxChange(cweCode)}
                          className="h-4 w-4 mr-4 border-gray-400 rounded focus:ring-gray-400 hover:cursor-pointer"
                        />
                        <label
                          htmlFor={`cweCheckbox-${cweCode}`}
                          className="text-lg hover:cursor-pointer"
                        >
                          {cweCode}
                        </label>
                      </div>
                    </div>
                    <div className="w-full ">
                      <div className="">
                        <p>{cweDescription}</p>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}
          {selectedLanguage === "javascript" && (
            <div
              className="ml-60"
              style={{ maxHeight: "400px", overflowY: "auto" }}
            >
              <Link href="/">
                <div
                  style={{ position: "absolute", right: 100, top: 20 }}
                  className="w-10 h-10 bg-blue-500 hover:bg-blue-700 font-bold text-white px-10 flex justify-center items-center rounded-lg"
                >
                  next
                </div>
              </Link>
              <div className="bg-white px-4 rounded-md">
                {Object.entries(javascriptCWEs).map(
                  ([cweCode, cweDescription]) => (
                    <div key={cweCode} className="flex items-center mb-2">
                      <div className="w-80 mr-40">
                        <div className=" ">
                          <input
                            type="checkbox"
                            id={`cweCheckbox-${cweCode}`}
                            checked={cweCheckboxes[cweCode] || false}
                            onChange={() => handleCWECheckboxChange(cweCode)}
                            className="h-4 w-4 mr-4 border-gray-400 rounded focus:ring-gray-400"
                          />
                          <label
                            htmlFor={`cweCheckbox-${cweCode}`}
                            className="text-lg"
                          >
                            {cweCode}
                          </label>
                        </div>
                      </div>
                      <div className="w-full ">
                        <div className="">
                          <p>{cweDescription}</p>
                        </div>
                      </div>
                    </div>
                  )
                )}
              </div>
            </div>
          )}
          {selectedLanguage === "python" && (
            <div
              className="ml-60"
              style={{ maxHeight: "400px", overflowY: "auto" }}
            >
              <Link href="/">
                <div
                  style={{ position: "absolute", right: 100, top: 20 }}
                  className="w-10 h-10 bg-blue-500 hover:bg-blue-700 font-bold text-white px-10 flex justify-center items-center rounded-lg"
                >
                  next
                </div>
              </Link>
              <div className="bg-white px-4 rounded-md">
                {Object.entries(pythonCWEs).map(([cweCode, cweDescription]) => (
                  <div key={cweCode} className="flex items-center mb-2">
                    <div className="w-80 mr-40">
                      <div className=" ">
                        <input
                          type="checkbox"
                          id={`cweCheckbox-${cweCode}`}
                          checked={cweCheckboxes[cweCode] || false}
                          onChange={() => handleCWECheckboxChange(cweCode)}
                          className="h-4 w-4 mr-4 border-gray-400 rounded focus:ring-gray-400 hover:cursor-pointer"
                        />
                        <label
                          htmlFor={`cweCheckbox-${cweCode}`}
                          className="text-lg hover:cursor-pointer"
                        >
                          {cweCode}
                        </label>
                      </div>
                    </div>
                    <div className="w-full ">
                      <div className="">
                        <p>{cweDescription}</p>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}
          {selectedLanguage === "ruby" && (
            <div
              className="ml-60"
              style={{ maxHeight: "400px", overflowY: "auto" }}
            >
              <Link href="/">
                <div
                  style={{ position: "absolute", right: 100, top: 20 }}
                  className="w-10 h-10 bg-blue-500 hover:bg-blue-700 font-bold text-white px-10 flex justify-center items-center rounded-lg"
                >
                  next
                </div>
              </Link>
              <div className="bg-white px-4 rounded-md">
                {Object.entries(rubyCWEs).map(([cweCode, cweDescription]) => (
                  <div key={cweCode} className="flex items-center mb-2">
                    <div className="w-80 mr-40">
                      <div className=" ">
                        <input
                          type="checkbox"
                          id={`cweCheckbox-${cweCode}`}
                          checked={cweCheckboxes[cweCode] || false}
                          onChange={() => handleCWECheckboxChange(cweCode)}
                          className="h-4 w-4 mr-4 border-gray-400 rounded focus:ring-gray-400 hover:cursor-pointer"
                        />
                        <label
                          htmlFor={`cweCheckbox-${cweCode}`}
                          className="text-lg hover:cursor-pointer"
                        >
                          {cweCode}
                        </label>
                      </div>
                    </div>
                    <div className="w-full ">
                      <div className="">
                        <p>{cweDescription}</p>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}
          {selectedLanguage === "swift" && (
            <div
              className="ml-60"
              style={{ maxHeight: "400px", overflowY: "auto" }}
            >
              <Link href="/">
                <div
                  style={{ position: "absolute", right: 100, top: 20 }}
                  className="w-10 h-10 bg-blue-500 hover:bg-blue-700 font-bold text-white px-10 flex justify-center items-center rounded-lg"
                >
                  next
                </div>
              </Link>
              <div className="bg-white px-4 rounded-md">
                {Object.entries(swiftCWEs).map(([cweCode, cweDescription]) => (
                  <div key={cweCode} className="flex items-center mb-2">
                    <div className="w-80 mr-40">
                      <div className=" ">
                        <input
                          type="checkbox"
                          id={`cweCheckbox-${cweCode}`}
                          checked={cweCheckboxes[cweCode] || false}
                          onChange={() => handleCWECheckboxChange(cweCode)}
                          className="h-4 w-4 mr-4 border-gray-400 rounded focus:ring-gray-400 hover:cursor-pointer"
                        />
                        <label
                          htmlFor={`cweCheckbox-${cweCode}`}
                          className="text-lg hover:cursor-pointer"
                        >
                          {cweCode}
                        </label>
                      </div>
                    </div>
                    <div className="w-full ">
                      <div className="">
                        <p>{cweDescription}</p>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  )
}

export default CourseSearch
