module "nexus" {
  source = "../helm"

  release_name     = var.release_name
  repository       = var.repository
  chart            = var.chart
  chart_version    = var.chart_version
  namespace        = kubernetes_namespace.nexus_namespace.metadata[0].name
  create_namespace = false

  depends_on = [
    kubernetes_namespace.nexus_namespace,
    module.nexus_service_account,
    kubernetes_manifest.rds_secret,
    kubernetes_manifest.license_secret,
    kubernetes_manifest.secret_store,
  ]
  values = [<<-YAML
    namespaces:
      nexusNs:
        enabled: false
    statefulset:
      clustered: false
      replicaCount: ${var.replica_count}
      container:
        image:
          repository: ${var.ecr_docker_hub}/sonatype/nexus3
        resources:
        ## TODO: This is just fro test mode increase instance size to run the default limits
          limits:
            cpu: 8
            memory: 8Gi
          requests:
            cpu: 5
            memory: 8Gi
        additionalEnv:
          - name: DB_NAME
            value: nexus
          - name: DB_HOST
            value: ${var.db_endpoint}
          - name: DB_USER
            valueFrom:
              secretKeyRef:
                name: ${local.rds_ext_secret}
                key: username
          - name: DB_PASSWORD
            valueFrom:
              secretKeyRef:
                name: ${local.rds_ext_secret}
                key: password
      requestLogContainer:
        image:
          repository: ${var.ecr_docker_hub}/library/busybox
      auditLogContainer:
        image:
          repository: ${var.ecr_docker_hub}/library/busybox
      taskLogContainer:
        image:
          repository: ${var.ecr_docker_hub}/library/busybox
      initContainers:
        - name: chown-nexusdata-owner-to-nexus-and-init-log-dir
          image: ${var.ecr_docker_hub}/library/busybox:${var.busybox_version}
          command: [/bin/sh]
          args:
            - -c
            - >-
              mkdir -p /nexus-data/etc/logback &&
              mkdir -p /nexus-data/log/tasks &&
              mkdir -p /nexus-data/log/audit &&
              touch -a /nexus-data/log/tasks/allTasks.log &&
              touch -a /nexus-data/log/audit/audit.log &&
              touch -a /nexus-data/log/request.log &&
              chown -R '200:200' /nexus-data
          volumeMounts:
            - name: nexus-data
              mountPath: /nexus-data
    ingress:
      enabled: true
      dockersubdomain: true
      defaultRule: true
      host: ${var.nexus_domain_name}
      ingressClassName: alb
      annotations:
        alb.ingress.kubernetes.io/healthcheck-path: /service/rest/v1/status
        alb.ingress.kubernetes.io/scheme: internal 
        alb.ingress.kubernetes.io/listen-ports: '[{"HTTPS":443}]'
        alb.ingress.kubernetes.io/certificate-arn: ${var.nexus_acm_certificate_arn}
        alb.ingress.kubernetes.io/target-type: ip
    pvc:
      volumeClaimTemplate:
        enabled: true
      storage: 100Gi
    storageClass:
      name: ebs-sc
    service:
      nexus:
        enabled: true
        type: NodePort
        protocol: TCP
        port: 80
        targetPort: 8081
    nexus:
      docker:
        enabled: true
        protocol: TCP
        type: NodePort
        registries: 
          - host: docker.${var.nexus_domain_name}
            port: 9090
            targetPort: 9090
            annotations:
              kubernetes.io/ingress.class: alb
              alb.ingress.kubernetes.io/scheme: internal
              alb.ingress.kubernetes.io/target-type: ip
              alb.ingress.kubernetes.io/listen-ports: '[{"HTTPS":443}]'
              alb.ingress.kubernetes.io/healthcheck-port: '8081'
              alb.ingress.kubernetes.io/certificate-arn: ${var.docker_acm_certificate_arn}
    secret:
      existingDbSecret:
        enabled: true
      nexusAdminSecret:
        enabled: true
      license:
        name: ${var.license_secret_name}
        existingSecret: true
        decodingStrategy: Base64
  YAML
  ]
}
