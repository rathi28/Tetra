# HTTPS Server Implementation Documentation

With the switch to using HTTPS for the Tetra Server, some changes needed to be made to how the server was run and what was contained in its stack.

For example, instead of using WEBrick, Tetra now uses {Thin server}[https://github.com/macournoyer/thin/]

## Starting the Server
When inside of the tetra directory call this command: 

```sh
bundle exec thin start --ssl -p 443  --quiet -e production --ssl-key-file server.key --ssl-cert-file server.crt --ssl-disable-verify
```

## Refreshing the configuration

At some point, an admin for Tetra might need to recreate the key or certificate.

> **Note:** It is normal for these to raise warnings in a Web Browser. They are not signed by a CA and have no real validity.

### Generating a new key (RSA)
Run the below commands to generate a new private key

```sh
openssl genrsa -des3 -out server.orig.key 2048
```

```sh
openssl rsa -in server.orig.key -out server.key
```

This will spit out the new .key file for use with Thin

### Generating a new certificate




```sh
openssl req -new -key server.key -out server.csr
```

When prompted for a common name, use the name of tetra.guthy-renker.com (or the new domain if it has been changed)

```sh
openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt
```

## Starting the HTTP redirect application

Tetra comes with a <b>redirecthttp</b> rails application in its repository. This app captures any http requests (which are direct at port 80) and fails the ones that aren't the root directory, and redirects any calls to the root to the HTTPS version of the site.

To start this application, navigate to the root of the redirecthttp directory, and run the following command:

```sh
rails s -p 80 --binding 0.0.0.0 -e production
```
