# SSL Certificate with [Let's Encrypt](https://letsencrypt.org/) .

## ToC
* ### certbot
  * #### using certbot under the server which without Public IP .
  * #### make a wildcard certificate of the domain, and also includes itself .
  * #### nested subdomains walkthrough .
  * #### access endpoint in Azure VM validly using the url of public DNS name, like a "https://vm.somewhere.cloudapp.azure.com" .
  * #### sharing SSL certs both webserver and database .
* ### mod_md
  * #### install mod_md on RHEL 7 ( RPM ) .
  * #### using ACME challenges in Apache without port 80 .
  * #### wildcard certs under mod_md .
