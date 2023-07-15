resource "kubernetes_service" "lemmy_frontend" {
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

  metadata {
    name      = "lemmy-frontend"
    namespace = local.namespace
  }
}

resource "kubernetes_deployment" "lemmy_frontend" {
  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "lemmy-frontend"
      }
    }

    template {
      spec {
        container {
          image = "dessalines/lemmy-ui:${var.version_lemmy}"
          name  = "lemmy-frontend"

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

          port {
            container_port = 1234
          }
        }
      }

      metadata {
        labels = {
          app = "lemmy-frontend"
        }
      }
    }
  }

  metadata {
    name      = "lemmy-frontend"
    namespace = local.namespace
  }
}
