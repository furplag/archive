# access endpoint in Azure VM validly using the url of public DNS name, like a "https://vm.somewhere.cloudapp.azure.com" .

## Requirement
- [ ] enable `certbot`
- [ ] enable `python3` and [python http.server](https://docs.python.org/3/library/http.server.html#http.server.SimpleHTTPRequestHandler)
- Virtual machine running, and which have both of:
  - [ ] Azure DNS name
  - [ ] public IP address
- [ ] no listener with port 80 ( all HTTP server are inactive ) .

## Important Notice
unfortunately, could not automate this solution yet .

## Getting start

### Step 1. execute certbot manually
> `--dry-run`, first .
```certbot.certonly.sh
certbot certonly --manual --agree-tos --no-eff-email --keep-until-expiring \
-d {Azure DNS name} \
-m {valid e-mail}
```
starts certificate request, and show massages below,
```certbot.prompt.sh
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Create a file containing just this data:

{validation-token-key}.{validation-token}

And make it available on your web server at this URL:

http://origin.japaneast.cloudapp.azure.com/.well-known/acme-challenge/{validation-token-key}

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Press Enter to Continue
```
DO NOT continue before next step .

### Step 2. start python HTTPServer in "Another" ssh terminal .
```python.http.server.sh
[[ -d '~/.authenticator/.well-known/acme-challenge' ]] || mkdir -p '~/.authenticator/.well-known/acme-challenge'
echo '{validation-token-key}.{validation-token}' >~/.authenticator/.well-known/acme-challenge/{validation-token-key} && \
cat <<_EOT_|bash
cd "$(pwd)/.authenticator" && python3 -m http.server 80
_EOT_

```

### Step 3. continue processing of certificate request

### Step 4. post process
- [ ] stop python http.server
- [ ] cleanup '~/.authenticator' directory
- [ ] start web server .
