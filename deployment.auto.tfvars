

resource_tags = {
  "Environment" = "test"
  "Team"        = "DevOps"
  "Description" = "mediawiki"
}

resource_group_location = "eastus"

resource_group_name = "rg2"

lb_name = "lb1"

vnet_address_space = ["10.10.0.0/16"]

vnet_name = "vnet1"

subnets = [
  {
    address_prefixes = ["10.10.0.0/24"]
    name             = "vm-snet"
  },
  {
    address_prefixes = ["10.10.1.0/24"]
    name             = "agw-snet"
  },
]

nsg = [
  {
    name = "nsg-vmsnet"
    security_rules = [
      {
        name                       = "IBA-Internet-VNET-HTTP"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "Internet"
        destination_address_prefix = "VirtualNetwork"
      },
      {
        name                       = "IBA-Internet-VNET-SSH"
        priority                   = 110
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "Internet"
        destination_address_prefix = "VirtualNetwork"
      }
    ]
  },
  {
    name = "nsg-appgwsnet"
    security_rules = [
      {
        name                       = "IBA-Internet-VNET-HTTP"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "Internet"
        destination_address_prefix = "VirtualNetwork"
      },
      {
        name                       = "IBA-AzureLoadBalancer-Any-Any"
        priority                   = 110
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "AzureLoadBalancer"
        destination_address_prefix = "*"
      },
      {
        name                       = "IBA-GatewayManager-Any-Any"
        priority                   = 120
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "65200-65535"
        source_address_prefix      = "*"
        destination_address_prefix = "GatewayManager"
      }
    ]
  }
]

vm_pip = "fe-pip"

agw_pip = "fe-agw-pip"

vm_subnet = "vm-snet"

vm_image_id = "image-mediawiki-v1.34-0.0.3"

image_rg = "mediawiki-devops-rg"

vm_name = "vm1"

vm_size = "Standard_B2ms"

vm_username = "testadmin"

agw_name = "agw01"

agw_subnet = "agw-snet"

script_path = "install.sh"

mariadb_server_name = "mediawikiserver0403"

mariadb_name = "wikidatabase"

kv_name = "wiki45ded292afkv"

agw_sku = {
  name = "Standard_v2"
  tier = "Standard_v2"
}