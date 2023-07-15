resource "kubernetes_service" "lemmy_frontend" {
  metadata {
    name      = "lemmy-frontend"
    namespace = local.namespace
  }

  spec {
    port {
      port        = 1234
      target_port = 1234
    }

    selector = {
      app = kubernetes_deployment.lemmy_frontend.metadata[0].name
    }
  }

  lifecycle {
    ignore_changes = [metadata[0].annotations]
  }
}

resource "kubernetes_deployment" "lemmy_frontend" {
  metadata {
    name      = "lemmy-frontend"
    namespace = local.namespace
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "lemmy-frontend"
      }
    }

    template {
      metadata {
        labels = {
          app = "lemmy-frontend"
        }
      }

      spec {
        container {
          image = "dessalines/lemmy-ui:${var.version_lemmy}"
          name  = "lemmy-frontend"

          port {
            container_port = 1234
          }

          env {
            name  = "LEMMY_UI_LEMMY_INTERNAL_HOST"
            value = "lemmy-backend.${local.namespace}.svc.cluster.local:8536"
          }

          env {
            name  = "LEMMY_UI_LEMMY_EXTERNAL_HOST"
            value = var.domain
          }

          env {
            name  = "LEMMY_UI_HTTPS"
            value = "true"
          }

          env {
            name  = "TZ"
            value = "UTC"
          }
        }
      }
    }
  }
}
