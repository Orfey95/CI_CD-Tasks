provider "google" {
  credentials = "${file("bash-task-346afa48839d.json")}"
  project = "bash-task"
  region = "europe-west3"
  zone = "europe-west3-a"
}

# SONAR

resource "google_compute_address" "sonar-static-ip-address" {
  name = "sonar-static-ip-address"
}

resource "google_compute_instance" "vm_instance_sonar" {
  name = "sonar-instance"
  machine_type = "n1-standard-1"
  
  tags = ["sonar"]
  
  boot_disk {
    initialize_params {
	  image = "centos-cloud/centos-7"
	}
  }
  
  metadata_startup_script = "yum install -y wget; curl https://raw.githubusercontent.com/Orfey95/Install-Jenkins-Sonar-Artifactory/master/install_sonar.sh | bash -s 12345678"
  
  network_interface {
    network = "default"
    access_config {
	  nat_ip = "${google_compute_address.sonar-static-ip-address.address}"
	}
  }
  
  metadata = {
    sshKeys = "Aleksandr:${file("id_rsa.pub")}"
  }
}

resource "google_compute_firewall" "sonar-firewall" {
  name    = "sonar-firewall"
  network = "default"
 
  allow {
    protocol = "tcp"
    ports    = ["9000"]
  }
 
  allow {
    protocol = "icmp"
  }
  
  target_tags = ["sonar"]
}

# ARTIFACTORY

resource "google_compute_address" "artifactory-static-ip-address" {
  name = "artifactory-static-ip-address"
}

resource "google_compute_instance" "vm_instance_artifactory" {
  name = "artifactory-instance"
  machine_type = "n1-standard-1"
  
  tags = ["artifactory"]
  
  boot_disk {
    initialize_params {
	  image = "centos-cloud/centos-7"
	}
  }
  
  metadata_startup_script = "yum install -y wget; curl https://raw.githubusercontent.com/Orfey95/Install-Jenkins-Sonar-Artifactory/master/install_artifactory.sh | bash -s 12345678"
  
  network_interface {
    network = "default"
    access_config {
	  nat_ip = "${google_compute_address.artifactory-static-ip-address.address}"
	}
  }
  
  metadata = {
    sshKeys = "Aleksandr:${file("id_rsa.pub")}"
  }
}

resource "google_compute_firewall" "artifactory-firewall" {
  name    = "artifactory-firewall"
  network = "default"
 
  allow {
    protocol = "tcp"
    ports    = ["8081", "8082"]
  }
 
  allow {
    protocol = "icmp"
  }
  
  target_tags = ["artifactory"]
}

# JENKINS NODE

resource "google_compute_address" "node1-static-ip-address" {
  name = "node1-static-ip-address"
}

resource "google_compute_instance" "vm_instance_node1" {
  name = "node1-instance"
  machine_type = "n1-standard-1"
  
  tags = ["node1"]
  
  boot_disk {
    initialize_params {
	  image = "ubuntu-os-cloud/ubuntu-1804-lts"
	}
  }

  metadata_startup_script = "apt update; apt install -y openjdk-11-jdk" 
	
  
  network_interface {
    network = "default"
    access_config {
	  nat_ip = "${google_compute_address.node1-static-ip-address.address}"
	}
  }
  
  metadata = {
    sshKeys = "Aleksandr:${file("id_rsa.pub")}"
  }
}

resource "google_compute_firewall" "node1-firewall" {
  name    = "node1-firewall"
  network = "default"
 
  allow {
    protocol = "tcp"
    ports    = ["8080", "25", "465"]
  }
 
  allow {
    protocol = "icmp"
  }
  
  target_tags = ["node1"]
}

# JENKINS

resource "google_compute_address" "jenkins-static-ip-address" {
  name = "jenkins-static-ip-address"
}

resource "google_compute_instance" "vm_instance_jenkins" {
  name = "jenkins-instance"
  machine_type = "n1-standard-1"
  
  tags = ["jenkins"]
  
  boot_disk {
    initialize_params {
	  image = "ubuntu-os-cloud/ubuntu-1804-lts"
	}
  }

  metadata_startup_script = "apt update; curl https://raw.githubusercontent.com/Orfey95/Install-Jenkins-Sonar-Artifactory/master/install_jenkins.sh | bash -s 2.222.3 sasha 1234 ${google_compute_address.sonar-static-ip-address.address} my-sonar ${google_compute_address.artifactory-static-ip-address.address} my-artifactory" 
	
  
  network_interface {
    network = "default"
    access_config {
	  nat_ip = "${google_compute_address.jenkins-static-ip-address.address}"
	}
  }
  
  metadata = {
    sshKeys = "Aleksandr:${file("id_rsa.pub")}"
  }
}

resource "google_compute_firewall" "jenkins-firewall" {
  name    = "jenkins-firewall"
  network = "default"
 
  allow {
    protocol = "tcp"
    ports    = ["8080","50000", "25", "465"]
  }
 
  allow {
    protocol = "icmp"
  }
  
  target_tags = ["jenkins"]
}
