locals {
  lemmy_backend_config_map = "lemmy-backend-v3"
  lemmy_backend_secrets    = "lemmy-backend-v6"
}

resource "kubernetes_service" "lemmy_backend" {
  spec {
    port {
      port        = 8536
      target_port = 8536
    }

    selector = {
      app = kubernetes_deployment.lemmy_backend.metadata[0].name
    }
  }

  lifecycle {
    ignore_changes = [metadata[0].annotations]
  }

  metadata {
    name      = "lemmy-backend"
    namespace = local.namespace
  }
}

resource "kubernetes_deployment" "lemmy_backend" {
  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "lemmy-backend"
      }
    }

    template {
      spec {
        container {
          image = "dessalines/lemmy:${var.version_lemmy}"
          name  = "lemmy-backend"

          env {
            name  = "TZ"
            value = "UTC"
          }

          env {
            name  = "LEMMY_CORS_ORIGIN"
            value = "https://${var.domain}"
          }

          env {
            name  = "RUST_LOG"
            value = "info"
          }

          env {
            name  = "RUST_BACKTRACE"
            value = "full"
          }

          env_from {
            secret_ref {
              name = kubernetes_secret.lemmy_backend.metadata[0].name
            }
          }

          port {
            container_port = 8536
          }

          volume_mount {
            mount_path = "/config/config.hjson"
            name       = "config"
            sub_path   = "lemmy_backend.hjson"
          }
        }

        volume {
          name = "config"

          config_map {
            name = kubernetes_config_map.lemmy_backend.metadata[0].name
          }
        }
      }

      metadata {
        labels = {
          app = "lemmy-backend"
        }
      }
    }
  }

  metadata {
    name      = "lemmy-backend"
    namespace = local.namespace
  }
}

resource "kubernetes_config_map" "lemmy_backend" {
  data = {
    "lemmy_backend.hjson" = "${templatefile("${path.module}/etc/lemmy.hjson.tftpl", {
      domain         = var.domain,
      namespace      = local.namespace,
      pictrs_api_key = random_password.pictrs_api_key.result
      smtp_host      = var.smtp_host
      smtp_username  = var.smtp_username
    })}"
  }

  metadata {
    name      = local.lemmy_backend_config_map
    namespace = local.namespace
  }
}

resource "kubernetes_secret" "lemmy_backend" {
  data = {
    LEMMY_DATABASE_URL  = "postgres://${var.database_username}:${var.database_password}@${var.database_host}/${var.database_name}?sslmode=require"
    LEMMY_SMTP_PASSWORD = var.smtp_password
  }

  metadata {
    name      = local.lemmy_backend_secrets
    namespace = local.namespace
  }
}
