# Setup 01 — Docker + Docker Compose

## Requisitos previos

- VM Ubuntu Server 24.04 LTS operativa (ver [Setup 00](00-vm-ubuntu.md))
- Conexión a internet activa desde la VM (verificar: `ping google.com`)

---

## 1. Instalar Docker Engine

```bash
# Actualizar paquetes e instalar dependencias
sudo apt update && sudo apt install -y ca-certificates curl

# Añadir clave GPG oficial de Docker
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Añadir repositorio oficial de Docker
echo "deb [arch=$(dpkg --print-architecture) \
  signed-by=/etc/apt/keyrings/docker.asc] \
  https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Instalar Docker Engine + Docker Compose plugin
sudo apt update && sudo apt install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin
```

---

## 2. Configurar permisos de usuario

Permite usar Docker sin `sudo`:

```bash
sudo usermod -aG docker $USER
newgrp docker
```

> Si cierras sesión y vuelves a entrar, `newgrp docker` ya no es necesario — el grupo se aplica automáticamente.

---

## 3. Verificar la instalación

```bash
docker --version
docker compose version
docker run hello-world
```

Salida esperada:
```
Docker version 27.x.x, build ...
Docker Compose version v2.x.x
Hello from Docker!
```

---

## 4. Configurar arranque automático

Docker debe arrancar con la VM para que los servicios estén disponibles sin intervención manual:

```bash
sudo systemctl enable docker
sudo systemctl enable containerd
```

Verificar estado:

```bash
sudo systemctl status docker
```

---

## 5. Resultado

- Docker Engine instalado y activo
- Docker Compose disponible como plugin (`docker compose`)
- El usuario puede ejecutar comandos Docker sin `sudo`
- Docker arranca automáticamente con la VM
