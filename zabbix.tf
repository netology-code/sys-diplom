resource "yandex_compute_instance" "zabbix" {
    name = "zabbix"
    hostname = "zabbix"
    allow_stopping_for_update = true
    platform_id = "standard-v2"
    zone = "ru-central1-d"
    

    resources {
        cores = 2
        core_fraction = 20
        memory = 2
    }

    boot_disk {
        initialize_params {
            image_id ="fd830gae25ve4glajds"
            size = 10
        }
    }

    network_interface {
        subnet_id = yandex_vpc_subnet.subnet-public.id
        nat = true
        security_group_ids = [yandex_vpc_security_group.zabbix.id, yandex_vpc_security_group.private-group.id]
    }

    metadata = {
        user-data = file("./meta.yml")
    }

    scheduling_policy {
        preemptible = true
    }
}
