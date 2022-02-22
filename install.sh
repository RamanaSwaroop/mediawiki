# RHEL 8.2
kv="${KEY_VAULT}"
echo $kv
groupadd wiki
useradd wiki -s /bin/bash -g wiki

# Generate password and push it to keyvault - avoid special characters
# Requires access on keyvault
# db_root_password=$(openssl rand -base64 12)

k=$(curl --silent 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fvault.azure.net' -H Metadata:true | jq --raw-output -r '.access_token')

db_root_password=$(curl --silent --request GET https://$kv.vault.azure.net/secrets/wiki?api-version=7.2 -H "Authorization: Bearer $k" | jq --raw-output -r '.value')

mysql --user=root <<_EOF_
  UPDATE mysql.user SET Password=PASSWORD('${db_root_password}') WHERE User='root';
  DELETE FROM mysql.user WHERE User='';
  DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
  CREATE USER 'wiki'@'localhost' IDENTIFIED BY '${db_root_password}';
  CREATE DATABASE wikidatabase;
  GRANT ALL PRIVILEGES ON wikidatabase.* TO 'wiki'@'localhost';
  FLUSH PRIVILEGES;
_EOF_

systemctl enable httpd
systemctl start httpd
systemctl enable mariadb
systemctl start mariadb

firewall-cmd --permanent --zone=public --add-service=http
firewall-cmd --permanent --zone=public --add-service=https
systemctl restart firewalld
