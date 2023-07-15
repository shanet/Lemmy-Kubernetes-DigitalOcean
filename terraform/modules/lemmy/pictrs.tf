resource "kubernetes_service" "pictrs" {
  metadata {
    name      = "pictrs"
    namespace = local.namespace
  }

  spec {
    port {
      port        = 8080
      target_port = 8080
    }

    selector = {
      app = kubernetes_deployment.pictrs.metadata[0].name
    }
  }

  lifecycle {
    ignore_changes = [metadata[0].annotations]
  }
}

resource "kubernetes_deployment" "pictrs" {
  metadata {
    name      = "pictrs"
    namespace = local.namespace
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "pictrs"
      }
    }

    template {
      metadata {
        labels = {
          app = "pictrs"
        }
      }

      spec {
        container {
          image = "asonix/pictrs:${var.version_pictrs}"
          name  = "pictrs"

          port {
            container_port = 8080
          }

          env {
            name  = "PICTRS__MEDIA__GIF__MAX_HEIGHT"
            value = "256"
          }

          env {
            name  = "PICTRS__MEDIA__GIF__MAX_WIDTH"
            value = "256"
          }

          env {
            name  = "PICTRS__MEDIA__GIF__MAX_AREA"
            value = "65536"
          }

          env {
            name  = "PICTRS__MEDIA__GIF__MAX_FRAME_COUNT"
            value = "400"
          }

          env {
            name  = "PICTRS__MEDIA__VIDEO_CODEC"
            value = "vp9"
          }

          env {
            name  = "PICTRS__SERVER__API_KEY"
            value = random_password.pictrs_api_key.result
          }

          env {
            name  = "PICTRS__STORE__TYPE"
            value = "object_storage"
          }

          env {
            name  = "PICTRS__STORE__ENDPOINT"
            value = "https://${digitalocean_spaces_bucket.pictrs.endpoint}"
          }

          env {
            name  = "PICTRS__STORE__BUCKET_NAME"
            value = digitalocean_spaces_bucket.pictrs.name
          }

          env {
            name  = "PICTRS__STORE__REGION"
            value = digitalocean_spaces_bucket.pictrs.region
          }

          env {
            name  = "PICTRS__STORE__ACCESS_KEY"
            value = var.pictrs_storage_access_key
          }

          env {
            name  = "PICTRS__STORE__SECRET_KEY"
            value = var.pictrs_storage_secret_key
          }

          env {
            name  = "PICTRS__STORE__USE_PATH_STYLE"
            value = "false"
          }

          env {
            name  = "RUST_BACKTRACE"
            value = "full"
          }

          env {
            name  = "RUST_LOG"
            value = "info"
          }
        }
      }
    }
  }
}

resource "digitalocean_spaces_bucket" "pictrs" {
  name   = "${var.name_prefix}-${local.namespace}"
  region = var.region
}
