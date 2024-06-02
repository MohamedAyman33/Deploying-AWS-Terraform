#My Infrastructure Variables

#VPC CIDR
variable "My-CIDR" {
  type = string
  default = "10.0.0.0/16"
}


variable "My_AZ" {
    type = list(string)
    default = [ "A", "B" ]
  
}


variable "My_Public_Subnet" {
 type = list(object({
   az = string
   cidr= string
 }))
 default = [ {
   az = "eu-central-1a"
   cidr = "10.0.1.0/24"
 },
 {
    az = "eu-central-1b"
    cidr = "10.0.2.0/24"
 } ]
}


variable "My_Private_Subnet" {
 type = list(object({
   az = string
   cidr= string
 }))
 default = [ {
   az = "eu-central-1a"
   cidr = "10.0.3.0/24"
 },
 {
    az = "eu-central-1b"
    cidr = "10.0.4.0/24"
 } ]
}

# RouteTable CIDR
variable "My_RT_CIDR" {
    type = string
    default = "0.0.0.0/0"
}


#-----------------------------------------------------------------------------------------------------------------
#My Ec2 Variables

variable "My_ControlIp" {
  type = string
  default = "10.0.3.33"
}


#SG CIDR
variable "My_Local_CIDR" {
  type = string
  default = "10.0.0.0/8"
}

variable "MY_PC2_IP" {
  type = string
  default = "10.0.3.34"
}

#-----------------------------------------------------------------------------------------------------------------

variable "My_s3_Name" {
  type = string
  default = "acpcs3.acpc.global"
}



