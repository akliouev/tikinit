{
:local users {
              {"usr1k";
               "random";
               "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAAgQD6hNBnovfHMN2aomWYM4mxDhU82CB3svQ+1mEqTP3ehDIEvg++wF3XGVcdaElt69wrGcdKHzBN4oO33l10MGPdVfyGxJumw9T5+EzqP9xbpt2eRAx9K8vfwSuaEaHh3WBZrIB4lGFRGja63u9iNuG1SH+2jMA1ofPHkl6Vk48QjQ== test@system"
              };
              {"usr2k";
               "random";
               "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDor9xZGTVpzXWZT+DgK35vxQzNuB5729cOH11NMOXTTszBivwYIYs5gsW9AglyRgNxf09HcCxr/G29N1kWqbazwHMQ2qKfbrgE8+EeZw/uN2IA1rTTu7moTBZErSyK3QyLSjbtbTSX9aL7cw1bohkBBs7z0f1l41t+qXx+bYTSBsezdCWW46QmwXBJ1NHUm1lsY6MLySvaRIALrgY35zYRDs6e7qmMdtZyxor/LVg+Zd5NdZ6jrbYnF+jNHa1zgP93TdThsknmYnwRKR8JNTU5xIn6pjG4JUrW8P2VlNgo0PhQ0pJUL8O52oxG0/mff3jm1Y0ohLp3l6pFyVKOJCfD test@system"
              };
              {"usr4k";
               "random";
               "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCqQp/E+1Nzn66VqDjKM81wmYCtJyCsUMfs3nwazhGbKU7zXqLkU29KoltRu2wlFz0WzF7g0yZJji2Fhs3RYbhmoxDPDa0diajMresXg3KJS6yq0XNCKg/AwTu4dEvkjHvC1iA13zXi+braj2dLR6GH86PPy8u8P6MLRHvPwN8AYsdR7j6VHyzl+bdPve18mL0dr9ou1iuIK3HWHgr+Do5zlAEp20AhTIQGrAwAVJujGrz2RijPDFD99DqURf1SmO5EQ1fOim73njmjC8tT7XfeN91uB8MG237Us7BXGAzGWTyezvEce86XXKvUBbobujA0KXxeNAvZcaG+ae8pI2PDtfvyEIsaTIRAp2QYAFkXf16/OMOhfA9g0+f0VDA/Zc4yQUq2aeiIQkIzNBdQIhEGXsNwITMe1bSoaJhMQnaDfLwsM82TM1sDlMLHC0j0lA2nf3PYYb3Z9cYFrY5jRxfT5wSQJPuhdtsIyItMXvKpSILa7BfkmBnBiPOurLkV4LiQwEoDcgD0i34uJ0zEsD/CcHvyQMF3tT56Tu+oSD3SHh9wjH0+2LjCLxJNUo1lkajF0rA3m4Jj7GxwfQa1GzoqJzvJDd7EKTs42zn1xaBfPwAMLgTrNBr1cHXJgiG/Pk72ItJ/h0J4b+tDDrNt8C/sD0FfTHeCitXTOzaNDfqM6w== test@system"
              }
};


/ip settings set allow-fast-path=no
#/ip dns set allow-remote-requests=yes servers=8.8.8.8,8.8.4.4,1.1.1.1
/system package update set channel=long-term
/system package update download
/system routerboard upgrade
/system ntp client  set enabled=yes primary-ntp=[:resolve pool.ntp.org]

/ip ssh set strong-crypto=yes allow-none-crypto=no always-allow-password-login=no

:foreach k in=$users do={
    :local key ($k->0)
    :local value ($k->1)
    :local sshkey ($k->2)
    :local password
    :set password $value
    :if ($value = "random") do={
        :set password [:pick ([/cert scep-server otp generate as-value minutes-valid=1]->"password") 0 20]
    }
    :put "$key $value $password $sshkey"
    /user add name="$key" group=full password="$password"
    :put "user $key added"
    /file print file="ssh_$key" where name=""
    :delay 2s
    :put "ssh key created"
    /file set "ssh_$key.txt" content="$sshkey"
    :delay 2s
    :put "ssh key populated"
    /user ssh-keys import user=$key public-key-file="ssh_$key.txt"
    :put "ssh key assigned"
    /file remove "ssh_$key.txt"
}

#
# Certificates
#

/certificate add name=CATemplate common-name=CArouter key-usage=key-cert-sign,crl-sign key-size=4096 days-valid=900
/certificate add name=Server common-name="router.lan" subject-alt-name="IP:192.168.88.1" key-size=2048 days-valid=900
:put "Signing CA certificate. Can take a while"
/certificate sign CATemplate
:put "Signing server certificate. Can take a while"
/certificate sign Server ca=CATemplate

/ip service disable [find where name="telnet"]
/ip service disable [find where name="ftp"]
/ip service disable [find where name="www"]
/ip service disable [find where name="api"]
/ip service disable [find where name="api-ssl"]
/ip service disable [find where name="winbox"]

/ip service set [find where name="www-ssl"] certificate=Server disabled=no

}
