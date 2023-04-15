package main

# Ngăn chặn việc để nodePort expose ra ngoài
deny[msg] {
  input.kind = "Service"
  not input.spec.type = "NodePort"
  msg = "Service type should be NodePort"
}

# Ngăn chặn việc được cấp quyền root
deny[msg] {
  input.kind = "Deployment"
  not input.spec.template.spec.containers[0].securityContext.runAsNonRoot = true
  msg = "Containers must not run as root - use runAsNonRoot wihin container security context"
}

deny {
    input.kind == "Pod"
    container := input.spec.containers[_]
    container.securityContext.runAsNonRoot != true
    container.securityContext.runAsUser != 1000
}

deny {
    input.kind == "Service"
    port := input.spec.ports[_]
    port.port == 8080
    not any i in input.spec.selector {
        i == "app"
    }
}
