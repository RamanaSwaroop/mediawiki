

resource_tags = {
  "Environment" = "test"
  "Team"        = "DevOps"
  "Description" = "mediawiki"
}

resource_group_location = "eastus"

resource_group_name = "rg2"

lb_name = "lb1"

# nsg_name = "nsg1"

# subnet_address_prefix = ["10.10.0.0/24"]

# subnet_name = "vm-snet"

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
    name = "nsg1"
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
    name = "nsg2"
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
      }
    ]
  }
]

vm_subnet = "vm-snet"

vm_image_id = "image-mediawiki-v1.34-0.0.3"

image_rg = "mediawiki-devops-rg"

vm_name = "vm1"

vm_size = "Standard_B2ms"

vm_username = "testadmin"

agw_name = "agw01"

agw_subnet = "agw-snet"

script_path = "install.sh"
