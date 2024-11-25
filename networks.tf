resource "yandex_vpc_network" "network-1" {
  name = "network-1"
}

#Сеть для app01
resource "yandex_vpc_subnet" "subnet-app01" {
  name = "subnet-app01"
  zone = "ru-central1-a"
  v4_cidr_blocks = ["192.168.1.0/24"]
  network_id  = "${yandex_vpc_network.network-1.id}"
}

#Сеть для app02 
resource "yandex_vpc_subnet" "subnet-app02" {
  name = "subnet-app02"
  zone = "ru-central1-b"
  v4_cidr_blocks = ["192.168.2.0/24"]
  network_id = "${yandex_vpc_network.network-1.id}"
}
#private
resource "yandex_vpc_subnet" "subnet-private" {
  name = "subnet-private"
  zone = "ru-central1-a"
  v4_cidr_blocks = ["192.168.3.0/24"]
  network_id = "${yandex_vpc_network.network-1.id}"
}

#public
resource "yandex_vpc_subnet" "subnet-public" {
  name = "subnet-public"
  zone = "ru-central1-d"
  v4_cidr_blocks = ["192.168.4.0/24"]
  network_id = "${yandex_vpc_network.network-1.id}"
}

resource "yandex_vpc_gateway" "gateway" {
  name = "gateway"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "routetable" {
  network_id = yandex_vpc_network.network-1.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id = yandex_vpc_gateway.gateway.id
  }
}

resource "yandex_alb_http_router" "http-router" {
  name = "http-router"
}

resource "yandex_alb_backend_group" "backend-group" {
  name = "backend-group"

  http_backend {
    name = "backend"
    weight = 1
    port = 80
    target_group_ids = [yandex_alb_target_group.web.id]

    load_balancing_config {
      panic_threshold = 90
    }

    healthcheck {
      timeout = "15s"
      interval = "2s"
      healthy_threshold = 10
      unhealthy_threshold = 15
      http_healthcheck {
        path = "/"
      }
    }
  }
}

resource "yandex_alb_virtual_host" "virtual-host" {
  name           = "virtual-host"
  http_router_id = yandex_alb_http_router.http-router.id
  route {
    name = "root-path"
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
  network_id         = yandex_vpc_network.network-1.id
  security_group_ids = [yandex_vpc_security_group.public-load-balancer-group.id]

  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.subnet-private.id
    }
  }

  listener {
    name = "listener"

    endpoint {
      address {
        external_ipv4_address {
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
