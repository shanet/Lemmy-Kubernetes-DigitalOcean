locals {
  nginx_config_map = "nginx-v2"
}

resource "kubernetes_service" "nginx" {
  spec {
    type = "LoadBalancer"

    port {
      name        = "http"
      port        = 80
      target_port = 80
    }

    port {
      name        = "https"
      port        = 443
      target_port = 80
    }

    selector = {
      app = kubernetes_deployment.nginx.metadata[0].name
    }
  }

  lifecycle {
    ignore_changes = [metadata[0].annotations["kubernetes.digitalocean.com/load-balancer-id"]]
  }

  metadata {
    name      = "nginx"
    namespace = local.namespace

    annotations = {
      "service.beta.kubernetes.io/do-loadbalancer-certificate-id"                   = var.certificate_id
      "service.beta.kubernetes.io/do-loadbalancer-disable-lets-encrypt-dns-records" = "true"
      "service.beta.kubernetes.io/do-loadbalancer-enable-backend-keepalive"         = "true"
      "service.beta.kubernetes.io/do-loadbalancer-protocol"                         = "http"
      "service.beta.kubernetes.io/do-loadbalancer-redirect-http-to-https"           = "true"
      "service.beta.kubernetes.io/do-loadbalancer-tls-ports"                        = "443"
    }
  }
}

resource "kubernetes_deployment" "nginx" {
  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "nginx"
      }
    }

    template {
      spec {
        container {
          image = "nginx:${var.version_nginx}"
          name  = "nginx"

          port {
            container_port = 80
          }

          volume_mount {
            mount_path = "/etc/nginx/nginx.conf"
            name       = "config"
            sub_path   = "nginx.conf"
          }
        }

        volume {
          name = "config"

          config_map {
            name = kubernetes_config_map.nginx.metadata[0].name
          }
        }
      }

      metadata {
        labels = {
          app = "nginx"
        }
      }
    }
  }

  metadata {
    name      = "nginx"
    namespace = local.namespace
  }
}

resource "kubernetes_config_map" "nginx" {
  data = {
    "nginx.conf" = "${templatefile("${path.module}/etc/nginx.conf.tftpl", {
      domain    = var.domain,
      namespace = local.namespace,
    })}"
  }

  metadata {
    name      = local.nginx_config_map
    namespace = local.namespace
  }
}

output "nginx_ip" {
  value = kubernetes_service.nginx.status[0].load_balancer[0].ingress[0].ip
}
