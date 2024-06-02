variable "CIDR" {
  type = string
}

variable "RT_CIDR" {
    type = string
}


variable "Public_Subnets" {
    type = list(object({
      az = string
      cidr = string
    }))
  
}

variable "AZ" {
  type = list(string)
}


variable "Private_Subnets" {
  type = list(object({
    az = string
    cidr = string
  }))
}

