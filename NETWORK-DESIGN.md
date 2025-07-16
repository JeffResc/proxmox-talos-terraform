# Network Design

## Overview

This configuration creates an isolated VPC-like network for the Talos Kubernetes cluster using a `10.0.0.0/16` subnet, providing `65534` usable IP addresses for future expansion.

## Network Architecture

### Address Space Allocation

```bash
10.0.0.0/16 (65,534 hosts)
├── 10.0.0.1         - Gateway/Bridge Interface
├── 10.0.1.0/24      - Control Plane Subnet
│   ├── 10.0.1.10    - Virtual IP (VIP) for HA
│   ├── 10.0.1.100   - Control Plane Node 1
│   ├── 10.0.1.101   - Control Plane Node 2
│   └── 10.0.1.102   - Control Plane Node 3
├── 10.0.1.200-255   - Worker Nodes
│   ├── 10.0.1.200   - Worker Node 1
│   ├── 10.0.1.201   - Worker Node 2
│   └── 10.0.1.202   - Worker Node 3
└── 10.0.2.0-255.0   - Future Expansion (65,280 IPs)
```

### Network Components

1. **Linux Bridge (`vmbr100`)**

   - Isolated from the main network
   - No physical interfaces attached (fully isolated)
   - VLAN-aware for future segmentation

1. **Resource Pool**

   - Groups all cluster VMs together
   - Simplifies management and resource allocation

1. **Firewall Rules**

   - Kubernetes API (`6443`)
   - Talos API (`50000`)
   - Inter-node communication
   - NodePort services (`30000-32767`)

### Security Configuration

- **Allowed Networks**:

  - `10.0.0.0/8` - All private 10.x networks
  - `192.168.0.0/16` - Local `RFC1918` networks
  - Additional IPs can be added as needed

- **Default Deny**: All other traffic is blocked

### Future Expansion Options

With a `/16` network, you have plenty of room for:

- Multiple Kubernetes clusters
- Different environments (dev, staging, prod)
- Service subnets
- Pod network overlays
- Load balancer IPs

### VLAN Support

The configuration is VLAN-aware, allowing future segmentation:

- VLAN 100: Production cluster
- VLAN 200: Development cluster
- VLAN 300: Management traffic
