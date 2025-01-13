resource "yandex_vpc_network" "network-main" {
  name        = "network-main"
  description = "Общая сеть"
}
resource "yandex_vpc_subnet" "subnet-vm1" {
  name           = "subnet-web1"
  description    = "Подсеть ВМ vm1"
  zone           = "ru-central1-a"
  v4_cidr_blocks = ["192.168.10.0/24"]
  network_id     = yandex_vpc_network.network-main.id
  route_table_id = yandex_vpc_route_table.route_table.id
}
resource "yandex_vpc_subnet" "subnet-vm2" {
  name           = "subnet-web2"
  description    = "Подсеть ВМ vm2"
  zone           = "ru-central1-b"
  v4_cidr_blocks = ["192.168.20.0/24"]
  network_id     = yandex_vpc_network.network-main.id
  route_table_id = yandex_vpc_route_table.route_table.id
}
resource "yandex_vpc_subnet" "subnet-inside" {
  name           = "subnet-inside"
  description    = "Подсеть балансировщика"
  zone           = "ru-central1-d"
  v4_cidr_blocks = ["192.168.30.0/24"]
  network_id     = yandex_vpc_network.network-main.id
  route_table_id = yandex_vpc_route_table.route_table.id
}

resource "yandex_vpc_subnet" "subnet-bastion" {
  name           = "subnet-bastion"
  description    = "Подсеть ВМ bastion"
  zone           = "ru-central1-d"
  v4_cidr_blocks = ["192.168.40.0/24"]
  network_id     = yandex_vpc_network.network-main.id
  
}

resource "yandex_vpc_gateway" "nat_gateway" {
  name = "nat-gateway"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "route_table" {
  name = "route-table"
  network_id = yandex_vpc_network.network-main.id
  
  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id = yandex_vpc_gateway.nat_gateway.id
    
  }
}


resource "yandex_compute_instance" "bastion" {
  name        = "bastion"
  hostname    = "bastion"
  platform_id = "standard-v3"
  zone        = "ru-central1-d"

  resources {
    core_fraction = 20
    cores         = 2
    memory        = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8o41nbel1uqngk0op2"
      size = 10
    }
  }

  scheduling_policy {
    preemptible = true
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet-bastion.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.bastion.id]
    ip_address         = "192.168.40.100"
  }
  metadata = {
    user-data = "${file("./metadata.yaml")}"
  }
}

resource "yandex_compute_instance" "elasticsearch" {
  name        = "elasticsearch"
  hostname    = "elasticsearch"
  platform_id = "standard-v3"
  zone        = "ru-central1-d"
  
  resources {
    core_fraction = 20
    cores         = 2
    memory        = 2
  }
  
  boot_disk {
    initialize_params {
      image_id = "fd8o41nbel1uqngk0op2"
      size = 10
    }
  }

  scheduling_policy {
    preemptible = true
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet-inside.id
    security_group_ids = [yandex_vpc_security_group.zabbix.id, yandex_vpc_security_group.inside.id]
    ip_address         = "192.168.30.101"
  }
  metadata = {
    user-data = "${file("./metadata.yaml")}"
  }
}
resource "yandex_compute_instance" "zabbix" {
  name        = "zabbix"
  hostname    = "zabbix"
  platform_id = "standard-v3"
  zone        = "ru-central1-d"
  
  resources {
    core_fraction = 20
    cores         = 2
    memory        = 2
  }
  boot_disk {
    initialize_params {
      image_id = "fd8o41nbel1uqngk0op2"
      size = 10
    }
  }

  scheduling_policy {
    preemptible = true
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet-inside.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.zabbix.id, yandex_vpc_security_group.inside.id]
    ip_address         = "192.168.30.102"
  }
  metadata = {
    user-data = "${file("./metadata.yaml")}"
  }
}

resource "yandex_compute_instance" "kibana" {
  name        = "kibana"
  hostname    = "kibana"
  platform_id = "standard-v3"
  zone        = "ru-central1-d"
  
  resources {
    core_fraction = 20
    cores         = 2
    memory        = 2
  }
  boot_disk {
    initialize_params {
      image_id = "fd8o41nbel1uqngk0op2"
      size = 10
    }
  }

  scheduling_policy {
    preemptible = true
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet-inside.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.kibana.id, yandex_vpc_security_group.inside.id]
    ip_address         = "192.168.30.103"
  }
  metadata = {
    user-data = "${file("./metadata.yaml")}"
  }
}


resource "yandex_compute_instance" "vm1" {
  name                      = "web1"
  hostname                  = "web1"
  platform_id               = "standard-v3"
  zone                      = "ru-central1-a"
  allow_stopping_for_update = true
  
  resources {
    core_fraction = 20
    cores         = 2
    memory        = 2
  }
  boot_disk {
    initialize_params {
      image_id = "fd8o41nbel1uqngk0op2"
      size     = 10
    }
  }

  scheduling_policy {
    preemptible = true
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet-vm1.id
    security_group_ids = [yandex_vpc_security_group.inside.id]
    ip_address         = "192.168.10.100"
  }
  metadata = {
    user-data = "${file("./metadata.yaml")}"
  }
}

resource "yandex_compute_instance" "vm2" {
  name                      = "web2"
  hostname                  = "web2"
  platform_id               = "standard-v3"
  zone                      = "ru-central1-b"
  allow_stopping_for_update = true

  resources {
    core_fraction = 20
    cores         = 2
    memory        = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8o41nbel1uqngk0op2"
      size = 10
    }
  }

  scheduling_policy {
    preemptible = true
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet-vm2.id
    security_group_ids = [yandex_vpc_security_group.inside.id]
    ip_address         = "192.168.20.100"
  }
  metadata = {
    user-data = "${file("./metadata.yaml")}"
  }
}

resource "yandex_vpc_address" "address" {
  name = "vpc_address"

  external_ipv4_address {
    zone_id = "ru-central1-d"
  }
}

resource "yandex_alb_target_group" "target-group" {
  name = "target-group"

  target {
    subnet_id  = yandex_compute_instance.vm1.network_interface.0.subnet_id
    ip_address = yandex_compute_instance.vm1.network_interface.0.ip_address
  }
  target {
    subnet_id  = yandex_compute_instance.vm2.network_interface.0.subnet_id
    ip_address = yandex_compute_instance.vm2.network_interface.0.ip_address
  }
}

resource "yandex_alb_backend_group" "backend-group" {
  name = "backend-group"
  http_backend {
    name             = "backend"
    weight           = 1
    port             = 80
    target_group_ids = [yandex_alb_target_group.target-group.id]
    
    load_balancing_config {
      panic_threshold = 9
    }
    
    healthcheck {
    #  healthcheck_port    = 80
      timeout             = "5s"
      interval            = "2s"
      healthy_threshold   = 2
      unhealthy_threshold = 15
      http_healthcheck {
        path = "/"
      }
    }
  }
}

resource "yandex_alb_http_router" "http-router" {
  name = "http-router"
}

resource "yandex_alb_virtual_host" "virtual-host" {
  name           = "virtual-host"
  http_router_id = yandex_alb_http_router.http-router.id
  route {
    name = "route"
    http_route {
      http_match {
        path {
          prefix = "/"
        }
      }
      http_route_action {
        backend_group_id = yandex_alb_backend_group.backend-group.id
        timeout          = "3s"
      }
    }
  }
}

resource "yandex_alb_load_balancer" "load-balancer" {
  name               = "load-balancer"
  network_id         = yandex_vpc_network.network-main.id
  security_group_ids = [yandex_vpc_security_group.inside.id, yandex_vpc_security_group.balancer.id]
  
  allocation_policy {
    
    location {
      zone_id   = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.subnet-vm1.id
    }
    
    location {
      zone_id   = "ru-central1-b"
      subnet_id = yandex_vpc_subnet.subnet-vm2.id
    }

  }


  listener {
    name = "listener"
    endpoint {
      address {
        external_ipv4_address {
          address = yandex_vpc_address.address.external_ipv4_address[0].address
        }
      }
      ports = [80]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.http-router.id
      }
    }
  }
}

resource "yandex_compute_snapshot_schedule" "snapshot" {
  name = "snapshot"
  schedule_policy {
    expression = "0 5 ? * *"
  }
  snapshot_count = 7
  snapshot_spec {
    description = "daily-snapshot"
  }
  
  disk_ids = [
    yandex_compute_instance.bastion.boot_disk.0.disk_id,
    yandex_compute_instance.zabbix.boot_disk.0.disk_id,
    yandex_compute_instance.elasticsearch.boot_disk.0.disk_id,
    yandex_compute_instance.kibana.boot_disk.0.disk_id,
    yandex_compute_instance.vm1.boot_disk.0.disk_id,
    yandex_compute_instance.vm2.boot_disk.0.disk_id
    ]
}
