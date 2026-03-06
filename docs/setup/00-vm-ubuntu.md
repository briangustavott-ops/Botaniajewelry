# Setup 00 — Máquina virtual Ubuntu Server

## Requisitos previos

- VMware Workstation (desarrollo) o VMware Player (usuaria final)
- ISO de Ubuntu Server 24.04 LTS: https://ubuntu.com/download/server
- Al menos 4 GB de RAM libre en el host y 25 GB de disco

---

## 1. Crear la VM en VMware

| Parámetro | Valor |
|-----------|-------|
| SO invitado | Ubuntu Linux 64-bit |
| RAM | 2 GB |
| CPU | 2 núcleos |
| Disco | 20 GB (thin provisioned) |
| Red adaptador 1 | NAT |
| Red adaptador 2 | Host-only (VMnet1) |

Pasos:
1. `File → New Virtual Machine → Typical`
2. Seleccionar la ISO de Ubuntu Server
3. Asignar nombre: `BotaniaJewelry`
4. Configurar disco: 20 GB
5. `Customize Hardware` → añadir segundo adaptador de red → Host-only

---

## 2. Instalar Ubuntu Server

Durante la instalación:
- Idioma: English (recomendado para logs y búsqueda de errores)
- Teclado: el que corresponda
- Tipo de instalación: Ubuntu Server (minimized)
- Red: dejar por defecto (se configura después)
- Sin LVM cifrado
- Instalar OpenSSH Server: **sí** (útil para acceder desde Windows con PuTTY o Windows Terminal)
- Snaps adicionales: ninguno

---

## 3. Configurar la red

Ubuntu Server 24.04 usa **Netplan** para la configuración de red.

### 3.1 Identificar las interfaces

```bash
ip link show
```

Resultado típico en VMware:
- `ens33` → NAT (salida a internet)
- `ens37` → Host-only (comunicación host↔VM)

### 3.2 Ver el archivo Netplan existente

```bash
ls /etc/netplan/
cat /etc/netplan/00-installer-config.yaml
```

### 3.3 Editar Netplan

```bash
sudo nano /etc/netplan/00-installer-config.yaml
```

Contenido final del archivo:

```yaml
network:
  version: 2
  ethernets:
    ens33:
      dhcp4: true          # NAT — salida a internet
    ens37:
      dhcp4: no            # Host-only — IP estática fija
      addresses:
        - 192.168.137.10/24
```

> ⚠️ Indentado con **2 espacios**, nunca tabuladores.
> Ajusta `ens33` / `ens37` si tus interfaces tienen nombres distintos.

### 3.4 Aplicar y verificar

```bash
sudo netplan apply
ip a show ens37
```

Debe mostrar `192.168.137.10/24`.

### 3.5 Verificar desde Windows

```powershell
ping 192.168.137.10
```

Respuesta correcta = comunicación host↔VM operativa.

---

## 4. Resultado

| Interfaz | Tipo | IP |
|----------|------|----|
| `ens33` | NAT | DHCP (salida a internet) |
| `ens37` | Host-only | `192.168.137.10` (fija) |

Los servicios de la VM serán accesibles desde Windows en:
- `http://192.168.137.10:3000` → Frontend (panel de control)
- `http://192.168.137.10:5678` → N8N (administración)
