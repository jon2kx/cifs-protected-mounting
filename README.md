# cifs-protected-mounting
Script for managing large amounts of CIFS mounts while protecting plaintext passwords for a single domain
Please ensure you move the cifs.cfg file to /etc/user.cifs/ and make the permissions 0300 for the file.
The configuration file requires population by a base64 hashed password.
