package main

# Expose NodePort ra ngoài
deny[msg] {
  input.kind = "Service"
  not input.spec.type = "NodePort"
  msg = "Service type should  be NodePort"
}

# Ngăn chặn việc được cấp quyền root
deny[msg] {
  input.kind = "Deployment"
  not input.spec.template.spec.containers[0].securityContext.runAsNonRoot = true
  msg = "Containers must not run as root - use runAsNonRoot wihin container security context"
}

# must use imagePullPolicy: IfNotPresent
deny[msg] {
  input.kind = "Deployment"
  not input.spec.template.spec.containers[0].imagePullPolicy = "IfNotPresent"
  msg = "Deployment must use imagePullPolicy: IfNotPresent"
}

# Set limit and requests resource for pod
deny[msg] {
  input.kind = "Pod"
  not input.spec.containers[0].resources.limits
  not input.spec.containers[0].resources.requests
  msg = "Pod must have resource limits and requests set"
}



# In case deploy pod without deployment, replicaset
deny[msg] {
    input.kind = "Pod"
    container := input.spec.containers[_]
    container.securityContext.runAsNonRoot != true
    container.securityContext.runAsUser != 1000
    msg = "pod of container must not run as root"
}

# Limit access to Kubernetes secrets:
deny[msg] {
  input.kind = "Pod"
  input.spec.containers[_].env[_].valueFrom.secretKeyRef
  not input.metadata.annotations["allowed-secret"] = "true"
  msg = "Access to this secret is not allowed"
}
