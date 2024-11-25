resource "yandex_alb_target_group" "web" {
  name = "web"
  target {
    ip_address = yandex_compute_instance.app02.network_interface.0.ip_address
    subnet_id = yandex_vpc_subnet.subnet-app02.id
  }
  
  target {
    ip_address = yandex_compute_instance.app01.network_interface.0.ip_address
    subnet_id = yandex_vpc_subnet.subnet-app01.id
  }
}

resource "yandex_compute_instance" "app01" {
  name = "app-01"
  allow_stopping_for_update = true
  platform_id = "standard-v2"
  zone = "ru-central1-a"

  resources {
    cores = 2
    core_fraction = 20
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd830gae25ve4glajdsj"
      size = 10
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-app01.id
    security_group_ids = [yandex_vpc_security_group.private-group.id, yandex_vpc_security_group.bastion-group.id]
  }

  metadata = {
    user-data = file("./meta.yml")
  }

  scheduling_policy {
    preemptible = true
  }
}

resource "yandex_compute_instance" "app02" {
  name = "app-02"
  allow_stopping_for_update = true
  platform_id = "standard-v2"
  zone = "ru-central1-b"

  resources {
    cores = 2
    core_fraction = 20
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd830gae25ve4glajdsj"
      size = 10
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-app02.id
    security_group_ids = [yandex_vpc_security_group.private-group.id, yandex_vpc_security_group.bastion-group.id]
  }
  metadata = {
    user-data = file("./meta.yml")
  }

  scheduling_policy {
    preemptible = true
  }
}