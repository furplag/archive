# SSL Certificate with [Let's Encrypt](https://letsencrypt.org/) .

## certbot

### using certbot under the server which without Public IP .

<details>
  <summary>A. can edit DNS records ( TXT ) </summary>
  
  using [DNS-01 challenge](https://letsencrypt.org/docs/challenge-types/#dns-01-challenge), e.g. )
  ```certbot.dns-challenge.manually.sh
  certbot certonly --manual --preffered-challenge dns-01 \
  --agree-tos --no-eff-email --keep-until-expiring \
  [ -d { domain } ... ] \
  -m {valid e-mail}
  ```
  and adds the DNS record for validation usually those named as "_acme-challenge.{domain}" .
</details>

<details>
  <summary>B. can edit DNS records ( TXT ), and also API (CLI) callable </summary>
  
  using [DNS-01 challenge](https://letsencrypt.org/docs/challenge-types/#dns-01-challenge) .
  1. create a script to add DNS record for validation ( auth-hook ) , which use the argument below,

      - CERTBOT_DOMAIN: domain name to certificate
      - CERTBOT_VALIDATION: token value for validate certificate
      > Note: do not overwrite, adds a record value even if DNS record name duplicates .  

  2. create a script to remove unnecessary DNS records after validation ( cleanup-hook ) , which use the argument below,

      - CERTBOT_DOMAIN: domain name to certificate

  3. then execute, e.g. )

      ```certbot.dns-challenge.manually.sh
      certbot certonly --manual --preffered-challenge dns-01 \
      --agree-tos --no-eff-email --keep-until-expiring \
      --manual-auth-hook {path to auth-hook script}
      --manual-cleanup-hook {path to cleanup-hook script}
      [ -d { domain } ... ] \
      -m {valid e-mail}
      ```
</details>

<details>
  <summary>C. can not edit DNS records, anyway</summary>

    I have an idea, you create SSL certificate in another place, and then copy them into the server . 
  
</details>

### wildcard certs with nested subdomains walkthrough .

#### Overview
+ root domain, e. g. ) "web.workspace.everywhere" is a web service subscribable .
+ a tenant has subdomain, like "customer-one.web.workspace.everywhere" .
+ employee of tenants have personal workspace, which has a domain like "taro.customer-one.web.workspace.everywhere" .

#### tried out
```
[WiP]
```

### [access endpoint in Azure VM validly using the url of public DNS name, like a "https://vm.somewhere.cloudapp.azure.com"](./certbot.azure.dns.md) .

### sharing SSL certs both webserver and database .

## mod_md

### install mod_md on RHEL 7 ( [RPM](https://github.com/furplag/archive/tree/rpm/) ) ( external ) .

### using ACME challenges in Apache without port 80 .

### wildcard certs under mod_md .
