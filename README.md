# tikinit

## Intro

Mikrotik script to initialize out of the box mikrotiks to something more secure and usable

The script does:

- disables fast-path
- sets package update channel to "long-term"
- updates the packages and firmware
- adds NTP servers
- sets ssh server settings to more secure ones (strong crypto, no passwords if ssh key present etc...)
- adds local users with SSH public keys and either filed passwords or completely random passwords
- creates a self-signed certificate
- disables unsecure/not required  services
- enables ssl webfig with the created certificate

## Prerequisites
1. A new or just resetted mikrotik
2. Working internet connection
3. Updated user table in script. The format is "username";"password";"ssh public key"
   1. SSH key must be either RSA or DSA. Tested with RSA only
   2. If password is set to "random", a random password will be generated for this user, enabling ssh with public key

## Running the script
1. Download the script to a fresh Mikrotik with "/tool fetch", scp, web interface etc...
2. Execute "/import file-name=tikinit.rsc"
3. Wait (certificates take a while to sign)
4. Verify remote access with ssh and web ssl (all other services should be disabled)
5. _Optional:_ Disable "admin" account
6. _Optional:_ Change random passwords to more obscure ones
7. Reboot

