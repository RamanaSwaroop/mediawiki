# RHEL 8.2
kv="${KEY_VAULT}"
echo $kv
groupadd wiki
useradd wiki -s /bin/bash -g wiki

systemctl enable httpd
systemctl start httpd

firewall-cmd --permanent --zone=public --add-service=http
firewall-cmd --permanent --zone=public --add-service=https
systemctl restart firewalld
