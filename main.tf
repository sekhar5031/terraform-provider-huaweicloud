data "huaweicloud_availability_zones" "myaz" {}

resource "huaweicloud_vpc" "vpc_demo" {
  name = "vpc-mine"
  cidr = "192.168.0.0/16"
}

#ADD SUBNET

resource "huaweicloud_vpc_subnet" "subnet1" {
  name       = "subnet1"
  cidr       = "192.168.10.0/24"
  gateway_ip = "192.168.10.1"
  vpc_id     = huaweicloud_vpc.vpc_demo.id
}

resource "huaweicloud_vpc_subnet" "subnet2" {
  name       = "subnet2"
  cidr       = "192.168.20.0/24"
  gateway_ip = "192.168.20.1"
  vpc_id     = huaweicloud_vpc.vpc_demo.id
}

resource "huaweicloud_vpc_subnet" "subnet3" {
  name       = "subnet3"
  cidr       = "192.168.30.0/24"
  gateway_ip = "192.168.30.1"
  vpc_id     = huaweicloud_vpc.vpc_demo.id
}

resource "huaweicloud_vpc_subnet" "subnet4" {
  name       = "subnet4"
  cidr       = "192.168.40.0/24"
  gateway_ip = "192.168.40.1"
  vpc_id     = huaweicloud_vpc.vpc_demo.id
}
#CREATE SECURITY GROUP
resource "huaweicloud_networking_secgroup" "sec_group_demo" {
  name        = "secgroup-basic1"
  description = "basic security group"
}

#ADD RULES TO SECURITY GROUP
resource "huaweicloud_networking_secgroup_rule" "allow_https" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = huaweicloud_networking_secgroup.sec_group_demo.id
}
resource "huaweicloud_networking_secgroup_rule" "allow_http" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = huaweicloud_networking_secgroup.sec_group_demo.id
}

data "huaweicloud_images_image" "IMS" {
  name        = var.ims_name
  visibility  = "public"
  most_recent = true
}
resource "huaweicloud_compute_instance" "BST01" { 
#WEB01, WEB02, JKN01, NAT_server
  name              = "BST01"
  image_id          = data.huaweicloud_images_image.IMS.id
  flavor_id         = var.flavor_name
  security_groups   = [huaweicloud_networking_secgroup.sec_group_demo.name]
  admin_pass        = var.password
  availability_zone = data.huaweicloud_availability_zones.myaz.names[0]

  system_disk_type  = var.disk_type
  system_disk_size  = 40

  network {
    uuid  = huaweicloud_vpc_subnet.subnet1.id
  }
}

resource "huaweicloud_compute_instance" "NAT_server" { 
#WEB01, WEB02, JKN01, NAT_server
  name              = "NAT_server"
  image_id          = data.huaweicloud_images_image.IMS.id
  flavor_id         = var.flavor_name
  security_groups   = [huaweicloud_networking_secgroup.sec_group_demo.name]
  admin_pass        = var.password
  availability_zone = data.huaweicloud_availability_zones.myaz.names[0]

  system_disk_type  = var.disk_type
  system_disk_size  = 40

  network {
    uuid  = huaweicloud_vpc_subnet.subnet1.id
  }
}

resource "huaweicloud_compute_instance" "WEB01" { 
#WEB01, WEB02, JKN01, NAT_server
  name              = "WEB01"
  image_id          = data.huaweicloud_images_image.IMS.id
  flavor_id         = var.flavor_name
  security_groups   = [huaweicloud_networking_secgroup.sec_group_demo.name]
  admin_pass        = var.password
  availability_zone = data.huaweicloud_availability_zones.myaz.names[0]

  system_disk_type  = var.disk_type
  system_disk_size  = 40

  network {
    uuid  = huaweicloud_vpc_subnet.subnet1.id
  }
}

resource "huaweicloud_compute_instance" "WEB02" { 
#WEB01, WEB02, JKN01, NAT_server
  name              = "WEB02"
  image_id          = data.huaweicloud_images_image.IMS.id
  flavor_id         = var.flavor_name
  security_groups   = [huaweicloud_networking_secgroup.sec_group_demo.name]
  admin_pass        = var.password
  availability_zone = data.huaweicloud_availability_zones.myaz.names[0]

  system_disk_type  = var.disk_type
  system_disk_size  = 40

  network {
    uuid  = huaweicloud_vpc_subnet.subnet1.id
  }
}

resource "huaweicloud_compute_instance" "JKN01" { 
#WEB01, WEB02, JKN01, NAT_server
  name              = "JKN01"
  image_id          = data.huaweicloud_images_image.IMS.id
  flavor_id         = var.flavor_name
  security_groups   = [huaweicloud_networking_secgroup.sec_group_demo.name]
  admin_pass        = var.password
  availability_zone = data.huaweicloud_availability_zones.myaz.names[0]

  system_disk_type  = var.disk_type
  system_disk_size  = 40

  network {
    uuid  = huaweicloud_vpc_subnet.subnet1.id
  }
}


#DECLARE IMAGE
variable "ims_name" {
  type    = string
  default = "Ubuntu 20.04 server 64bit"
}

#DECLARE FLAVOR
variable "flavor_name" {
  type    = string
  default = "s3.large.2"
}

#DECLARE DISK
variable "disk_type" {
  type = string
  default = "SAS" # or SSD
}

resource "huaweicloud_vpc_eip" "EIP_demo" {
publicip {
    type = "5_bgp"
  }
  bandwidth {
    name        = var.bandwidth_name #set name of bandwidth
    size        = 5
    share_type  = "PER" #dedicated bandwidth
    charge_mode = "traffic" 
  }
}
resource "huaweicloud_compute_eip_associate" "associated" {
  public_ip   = huaweicloud_vpc_eip.EIP_demo.address
  instance_id = huaweicloud_compute_instance.NAT_server.id
}

resource "huaweicloud_lb_loadbalancer" "elb_demo" {
  name          = var.loadbalancer_name 
  vip_subnet_id = huaweicloud_vpc_subnet.subnet1.subnet_id
}

# associate eip with loadbalancer
resource "huaweicloud_networking_eip_associate" "associate_1" {
  public_ip = huaweicloud_vpc_eip.EIP_demo.address
  port_id   = huaweicloud_lb_loadbalancer.elb_demo.vip_port_id
}

# ADD LISTENER TO LOADBALANCER
resource "huaweicloud_lb_listener" "listener_1" {
  name            = "listener_https"
  protocol        = "TERMINATED_HTTPS"
  protocol_port   = 443
  loadbalancer_id = huaweicloud_lb_loadbalancer.elb_demo.id
  default_tls_container_ref = huaweicloud_lb_certificate.certificate_1.id
}

#DECLARE ALGORITHM USED BY LOADBALANCER
resource "huaweicloud_lb_pool" "group_1" {
  name        = "group_1"
  protocol    = "HTTP"
  lb_method   = "ROUND_ROBIN"
  listener_id = huaweicloud_lb_listener.listener_1.id
}

#HEALTH CHECK
resource "huaweicloud_lb_monitor" "health_check" {
  name           = "health_check"
  type           = "HTTP"
  url_path       = "/"
  expected_codes = "200-202"
  delay          = 10
  timeout        = 5
  max_retries    = 3
  pool_id        = huaweicloud_lb_pool.group_1.id
}

#ASSOCIATE MEMBERS (ECS)
resource "huaweicloud_lb_member" "member_1" {
  address       = huaweicloud_compute_instance.WEB01.access_ip_v4
  protocol_port = 80
  weight        = 1
  pool_id       = huaweicloud_lb_pool.group_1.id
  subnet_id     = huaweicloud_vpc_subnet.subnet2.subnet_id
}

resource "huaweicloud_lb_member" "member_2" {
  address       = huaweicloud_compute_instance.WEB02.access_ip_v4
  protocol_port = 80
  weight        = 1
  pool_id       = huaweicloud_lb_pool.group_1.id
  subnet_id     = huaweicloud_vpc_subnet.subnet3.subnet_id
}

#ADD CERTIFICATE FOR HTTPS
resource "huaweicloud_lb_certificate" "certificate_1" {
  name        = "certificate_1"
  description = "terraform test certificate"
  type        = "server"
  certificate = var.cert
  private_key = var.pk
}
