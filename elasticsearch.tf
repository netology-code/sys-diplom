resource "yandex_compute_instance" "elasticsearch" {
  name = "elasticsearch"
  hostname = "elasticsearch"
  platform_id = "standard-v2"
  zone = "ru-central1-a"

  resources {
    cores = 2
    core_fraction = 20
    memory = 6
  }

  boot_disk {
    initialize_params {
      image_id = "fd830gae25ve4glajdsj"
      size = 10
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-private.id
    security_group_ids = [yandex_vpc_security_group.private-group.id]
  }
  metadata = {
    user-data = file("./meta.yml")
  }
  
  scheduling_policy {
    preemptible = true
  }
}