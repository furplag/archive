# HTTP/2, SSL ACME challenge on RHEL 7

## RPM repo
```terminal.sh
yum-config-manager --add-repo https://github.com/furplag/archive/raw/rpm/furplag.github.io.el7.repo
```

## install Apache 2.4 (h2 enabled)

### installation
```terminal.sh
yum install -y apr{,-util} httpd mod_{http2,md,ssl} --enablerepo=furplag.github.io
```

### Rewuirement
* [x] http2_module
* [x] md_module
* [x] mpm_event_module
* [x] ssl_module

### configuration
```terminal.sh
# create default cert ( /etc/pki/tls/certs/localhost.crt )
/usr/libexec/httpd-ssl-gencerts
```

### [mod_md](https://httpd.apache.org/docs/trunk/mod/mod_md.html) configuration
#### "STAGING" first .
```ssl.conf
# example for "example.com" in /etc/httpd/conf.d/ssl.conf .

<IfModule md_module>
  MDomain example.com admin.example.com www.example.com
  MDCertificateAuthority https://acme-staging-v02.api.letsencrypt.org/directory
  MDCertificateAgreement accepted
</IfModule>

<VirtualHost *:443>
  ServerName www.example.com
  ServerAlias example.com
  ...
</VirtualHost>

<VirtualHost *:443>
  ServerName admin.example.com
  ...
</VirtualHost>
```

#### ( re ) start Apache twice .
restart after appearing message in error_log .
```terminal.sh
[md:notice] [pid xxxxx:tid xxxxx] AH10059: The Managed Domain example.com has been setup and changes will be activated on next (graceful) server restart.
```

#### Swith staging certificate to production .

```ssl.conf
<IfModule md_module>
  MDomain example.com admin.example.com www.example.com
# MDCertificateAuthority https://acme-staging-v02.api.letsencrypt.org/directory
  MDCertificateAgreement accepted
</IfModule>
```

enable /md-status
```server-status.conf
<IfModule md_module>
  <Location /md-status>
    SetHandler md-status
    <RequireAny>
      Require ip 127.0.0.1
    </RequireAny>
  </Location>
</IfModule>
```

and remove "staging" challenges .
`rm -rf /var/lib/httpd/md/staging`

and restart Apache .
