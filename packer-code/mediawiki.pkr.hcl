
variable "client_id" {
  type    = string
  default = ""
}

variable "client_secret" {
  type    = string
  default = ""
}

variable "image_name" {
  type    = string
  default = ""
}

variable "image_rg" {
  type    = string
  default = ""
}

variable "subscription_id" {
  type    = string
  default = ""
}

variable "tenant_id" {
  type    = string
  default = ""
}

source "azure-arm" "this" {
  azure_tags = {
    dept = "Engineering"
    task = "Image deployment"
  }
  client_id                         = "${var.client_id}"
  client_secret                     = "${var.client_secret}"
  image_offer                       = "RHEL"
  image_publisher                   = "RedHat"
  image_sku                         = "8.1"
  location                          = "East US"
  managed_image_name                = "image-mediawiki-v1.34-0.0.3"
  managed_image_resource_group_name = "mediawiki-devops-rg"
  os_type                           = "Linux"
  subscription_id                   = "${var.subscription_id}"
  tenant_id                         = "${var.tenant_id}"
  vm_size                           = "Standard_DS2_v2"
}

build {
  sources = ["source.azure-arm.this"]

  provisioner "file" {
    destination = "/tmp/httpd.conf"
    source      = "httpd.conf"
  }

  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E sh '{{ .Path }}'"
    inline          = ["dnf upgrade -y", "dnf install telnet openssl jq httpd php php-mysqlnd php-gd php-xml mariadb-server mariadb php-mbstring php-json mod_ssl php-intl php-apcu -y", "cd /root", "wget https://releases.wikimedia.org/mediawiki/1.34/mediawiki-1.34.4.tar.gz", "mkdir /var/www/mediawiki-1.34.4", "ln -s /var/www/mediawiki-1.34.4 /var/www/mediawiki", "cd /var/www", "tar -zxf /root/mediawiki-1.34.4.tar.gz ", "chown -R apache:apache /var/www/mediawiki", "chown -R apache:apache /var/www/mediawiki-1.34.4", "mv /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf_bak", "mv /tmp/httpd.conf /etc/httpd/conf/httpd.conf", "/usr/sbin/waagent -force -deprovision+user && export HISTSIZE=0 && sync"]
    inline_shebang  = "/bin/sh -x"
  }

}
