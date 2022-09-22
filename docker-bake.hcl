group "default" {
  targets = ["release"]
}

target "defaults" {
  context = "."
  dockerfile = "Dockerfile"
  tags = [
    "quay.io/bitski/oathkeeper:latest",
    "quay.io/bitski/oathkeeper:v0.40.0"
  ]
}

target "docker-metadata-action" {}

target "local" {
  inherits = [
    "defaults",
    "docker-metadata-action"
  ]
}

target "release" {
  inherits = [
    "defaults",
    "docker-metadata-action"
  ]
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
}
