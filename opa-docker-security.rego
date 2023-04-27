package main

# Do Not store secrets in ENV variables
secrets_env = [
    "passwd",
    "password",
    "pass",
    "secret",
    "key",
    "access",
    "api_key",
    "apikey",
    "token",
    "tkn"
]

# Do not use 'ADD' or 'COPY' to copy sensitive files
deny[msg] {
    input[i].Cmd == "add" or input[i].Cmd == "copy"
    val := input[i].Value
    contains(lower(val[_]), secrets_env[_])
    msg = sprintf("Line %d: Potential sensitive file being copied with ADD or COPY command: %s", [i, val])
}

# Do not use 'RUN' with 'chmod 777'
deny[msg] {
    input[i].Cmd == "run"
    val := input[i].Value
    contains(val[_], "chmod") and contains(val[_], "777")
    msg = sprintf("Line %d: Do not use 'RUN' with 'chmod 777'", [i])
}

# Do not use 'EXPOSE' with default ports
deny[msg] {
    input[i].Cmd == "expose"
    val := input[i].Value
    contains(val[_], "80") or contains(val[_], "443") or contains(val[_], "8443")
    msg = sprintf("Line %d: Do not use 'EXPOSE' with default ports (80, 443)", [i])
}

deny[msg] {
    input[i].Cmd == "env"
    val := input[i].Value
    contains(lower(val[_]), secrets_env[_])
    msg = sprintf("Line %d: Potential secret in ENV key found: %s", [i, val])
}

# Only use trusted base images
# deny[msg] {
#   input[i].Cmd == "from"
#     val := split(input[i].Value[0], "/")
#    count(val) > 1
#    msg = sprintf("Line %d: use a trusted base image", [i])
# }

# Do not use 'latest' tag for base imagedeny[msg] {
deny[msg] {
    input[i].Cmd == "from"
    val := split(input[i].Value[0], ":")
    contains(lower(val[1]), "latest")
    msg = sprintf("Line %d: do not use 'latest' tag for base images", [i])
}

# Avoid curl bashing
deny[msg] {
    input[i].Cmd == "run"
    val := concat(" ", input[i].Value)
    matches := regex.find_n("(curl|wget)[^|^>]*[|>]", lower(val), -1)
    count(matches) > 0
    msg = sprintf("Line %d: Avoid curl bashing", [i])
}

# Do not upgrade your system packages
warn[msg] {
    input[i].Cmd == "run"
    val := concat(" ", input[i].Value)
    matches := regex.match(".*?(apk|yum|dnf|apt|pip).+?(install|[dist-|check-|group]?up[grade|date]).*", lower(val))
    matches == true
    msg = sprintf("Line: %d: Do not upgrade your system packages: %s", [i, val])
}

# Do not use ADD if possible
deny[msg] {
    input[i].Cmd == "add"
    msg = sprintf("Line %d: Use COPY instead of ADD", [i])
}

# Any user...
any_user {
    input[i].Cmd == "user"
 }

deny[msg] {
    not any_user
    msg = "Do not run as root, use USER instead"
}

# ... but do not root
forbidden_users = [
    "root",
    "toor",
    "0"
]

# Do not sudo
deny[msg] {
    input[i].Cmd == "run"
    val := concat(" ", input[i].Value)
    contains(lower(val), "sudo")
    msg = sprintf("Line %d: Do not use 'sudo' command", [i])
}

# Use multi-stage builds
default multi_stage = false
multi_stage = true {
    input[i].Cmd == "copy"
    val := concat(" ", input[i].Flags)
    contains(lower(val), "--from=")
}
