# Original author: mack-a
# Original project: https://github.com/mack-a/v2ray-agent

# v2ray-agent


- [Cloudflare / CDN Optimization Solution](https://github.com/panhuanghe/v2ray-agent/blob/main/docs/optimize_V2Ray.md)
- **Please give a ⭐ support**

* * * 

# Catalog

  - [Script installation](#installation-script)
  - [Features](#Features)
  - [Notes](#Notes)
* * * 

# 1.Eight-in-one coexistence script + Fake Website

- [Cloudflare Getting Started Tutorial (soon)](https://github.com/hostcr1/v2ray-agent/blob/main/docs/cloudflare_init.md)

## Features
- Supports [Xray-core[XTLS]](https ://github.com/XTLS/Xray-core), [v2ray-core](https://github.com/v2fly/v2ray-core)
- Supports VLESS/VMess/trojan protocol
- Supports VLESS/Trojan prepending [VLESS XTLS -> Trojan XTLS], [Trojan XTLS -> VLESS XTLS]
- Supports mutual reading of configuration files between different cores
- Trojan+TCP+xtls-rprx-direct
- Supports Debian, Ubuntu, Centos and mainstream CPU architectures.
- Supports to keep tls certificate after uninstalling the script 
- Supports [WARP](https://1.1.1.1/), IPv6 [IPv6 note](https://github.com/hostcr1/v2ray-agent/blob/main/docs/ipv6_help.md)
- Supports BitTorrent download management, log management, geosite category blacklist management, core management, camouflage site management
- Supports shortcut startup, after installation, enter [**vasma**] in the shell You can open the script, the script execution path [**/etc/v2ray-agent/install.sh**]
- [Supports custom certificate installation](https://github.com/hostcr1/v2ray-agent/blob/main/docs/install_tls.md)

## Supported installation types
- VLESS+TCP+TLS
- VLESS+TCP+xtls-rprx-direct
- VLESS+gRPC+TLS [supports CDN, IPv6, low latency]
- VLESS+WS+TLS [supports CDN, IPv6]
- Trojan+TCP+TLS [**recommended**]
- Trojan+gRPC+TLS [supports CDN, IPv6, low latency]
- VMess+WS+TLS [supports CDN, IPv6]

## Route recommendation

- Cloudflare - Hetzner, Nuremberg 
- DigitalOcean - Amsterdam

## Precautions

- **Modify Cloudflare->SSL/TLS->Overview->Full**
- **Cloudflare ---> Clouds parsed by A record must be gray [if not gray, it will affect the automatic renewal certificate of scheduled tasks]**
- **Use a fresh vps to install, if you have installed it with other scripts and you cannot modify the error yourself, please reinstall the OS and try to install the script again**
- **Not recommended for GCP users**
- **Oracle Cloud has an additional firewall that needs to be set manually**
- **In AWS you need to add an inbound rule to respond to ICMP packets**
- **Centos and lower versions of the system are not recommended, if the Centos installation fails, please switch to Debian10 and try again, the script no longer supports Centos6 , Ubuntu 16.x**
- **[If you don't understand the usage, please check the script usage guide first](https://github.com/hostcr1/v2ray-agent/blob/main/docs/how_to_use.md)**
- ** Oracle Cloud only supports Ubuntu**
- **If you use gRPC to forward through cloudflare, you need to allow gRPC in cloudflare settings, path: cloudflare Network->gRPC**
- **gRPC is currently in beta version and may not compatible for the clients you use, so it depends on your client app if you can't use it, just let go **

## Installation

``` 
wget -P/root -N --no-check-certificate "https://raw.githubusercontent.com/hostcr1/v2ray-agent/main/install.sh" && chmod 700 /root/install.sh &&/root/install.sh
``` 


# example image

<img src="https://raw.githubusercontent.com/hostcr1/v2ray-agent/main/img/vasma.png" width=700>

# licence

[AGPL-3.0](https://github.com/hostcr1/v2ray-agent/blob/main/LICENSE)
## Roadmap

- Add the domain name in the 09_routing.json
- Add suggested optimal routes
- Add an inbound/outbound connection for the tunneling

## Issues
Feel free to open issues or ask questions, describe the problem with a screenshot and detailed configuration and what you are trying to do.