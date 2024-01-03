# seclook

#### Automatic security lookups from your clipboard

seclook is a macOS/Swift app that sits in the background and monitors your clipboard, sending any IP, SHA2/MD5 hash, or domain to VirusTotal and AbuseIPDB. If any scanned item has a bad reputation score, you get a notification!

## Features

* Automatically scan your clipboard for the following string types:
  * IP addresses
  * SHA2 hashes
  * MD5 hashes
  * Domains
* Receive notifications through macOS Notification Center when a scanned item has a bad reputation score
* Send scanned items to the following security lookup services:
  * VirusTotal
  * AbuseIPDB
* Add known-good items to an Ignore List
* Toggle scanning on/off:
  * Universally using menu bar icon
  * By string type

## Installation

Download the latest Mac release [**here**](https://github.com/ackatz/seclook/raw/main/Releases/seclook.dmg). 

## Contributions

I'm happy to merge contributions that fit my vision for the app (simple, background app). Bug fixes and more tests are always welcome.

## FAQ

### Are you planning to release seclook for any other platforms?

No, at the moment this is out of scope, sorry.

### What does seclook send from my clipboard to lookup services?

seclook only sends the regex'ed string that was found (e.g., a single IP address such as `1.1.1.1`). No other data from the clipboard ever leaves your computer.

### What does seclook do if I copy a password?

Generally, you don't have to worry about your passwords being sent to lookup services as people's passwords are *generally not* a qualified string type (i.e., IP address, SHA2/MD5 hash, or domain).

#### A note on Password Managers

##### Autofill

seclook does not detect username/password combinations that are input from **auto fill** functions.

##### Desktop Apps + Manual Copy

If you manually copy a hash value (i.e., API key) from a password manager **desktop app** that sets `org.nspasteboard.ConcealedType` (see [NSPasteboard](http://nspasteboard.org/)) for copied data (i.e., 1Password Desktop app), seclook will ignore the clipboard value and not send anything to lookup services.

##### Browser Extensions + Manual Copy

If you manually copy a hash value from a password manager **browser extension**, there is not currently a way to detect `org.nspasteboard.ConcealedType` in this case, and seclook will send the hash value to lookup services. If you are concerned about this, you can disable scanning for SHA2/MD5 hashes in seclook's Settings pane.


## Thanks

* [VirusTotal](https://www.virustotal.com/) and [AbuseIPDB](https://www.abuseipdb.com/) for their awesome APIs