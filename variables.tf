variable "password" {
  type = string
  default = "enter password here"
}

variable "bandwidth_name" {
  type = string
  default = "my_bandwidth"
}

variable "loadbalancer_name" {
    type = string
    default = "my_loadbalancer"
}

variable "cert" {
    type = string
    default = "this is certificate"
  
}

variable "pk" {
 default = "this is a PK" 
}

//these are all the variable values which are referenced via main.tf file.