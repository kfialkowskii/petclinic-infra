###############################################################################
# variables.tf — wszystkie parametry projektu w jednym miejscu
###############################################################################

variable "location" {
  type    = string
  default = "polandcentral"
}

variable "project" {
  type    = string
  default = "petclinic"
}

# --- VM ---

variable "vm_size" {
  type    = string
  default = "Standard_B2s_v2" # 2 vCPU, 4 GB RAM
}

variable "vm_admin_username" {
  type    = string
  default = "azureuser"
}

variable "vm_ssh_public_key" {
  type = string
}

variable "allowed_ssh_cidr" {
  type        = string
  description = "Twoje publiczne IP w formacie x.x.x.x/32"
}

# --- Baza danych ---

variable "mysql_admin_username" {
  type    = string
  default = "petclinic"
}

variable "mysql_admin_password" {
  type      = string
  sensitive = true
}
