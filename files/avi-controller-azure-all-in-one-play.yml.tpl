---
- hosts: localhost
  connection: local
  gather_facts: no
  roles:
    - role: avinetworks.avisdk
  vars:
    controller: "{{ ansible_host }}"
    username: admin
    cloud_name: "Default-Cloud"
    ansible_become: yes
    ansible_become_password: "{{ password }}"
    subscription_id: ${subscription_id}
    se_resource_group: ${se_resource_group}
    se_vnet_id_path: ${se_vnet_id_path}
    se_mgmt_subnet_name: ${se_mgmt_subnet_name}
    controller_version: ${controller_version}
    region: ${region}
    se_name_prefix: ${se_name_prefix}
    controller_ha: ${controller_ha}
    use_azure_dns: ${use_azure_dns}
  %{ if controller_ha }
    controller_name_1: ${controller_name_1}
    controller_ip_1: ${controller_ip_1}
    controller_name_2: ${controller_name_2}
    controller_ip_2: ${controller_ip_2}
    controller_name_3: ${controller_name_3}
    controller_ip_3: ${controller_ip_3}
  %{ endif }
  tasks:
    - name: Wait for Controller to become ready
      wait_for:
        port: 443
        timeout: 600
        sleep: 5
    - name: Configure System Configurations
      avi_systemconfiguration:
        email_configuration:
          smtp_type: "SMTP_LOCAL_HOST"
          from_email: admin@avicontroller.net
        global_tenant_config:
          se_in_provider_context: true
          tenant_access_to_provider_se: true
          tenant_vrf: false
        ntp_configuration:
          ntp_server_list:
            - "0.us.pool.ntp.org":
              addr: "0.us.pool.ntp.org"
              type: DNS
            - "1.us.pool.ntp.org":
              addr: "1.us.pool.ntp.org"
              type: DNS
            - "2.us.pool.ntp.org":
              addr: "2.us.pool.ntp.org"
              type: DNS
            - "3.us.pool.ntp.org":
              addr: "3.us.pool.ntp.org"
              type: DNS
        portal_configuration:
          allow_basic_authentication: true
          disable_remote_cli_shell: false
          enable_clickjacking_protection: true
          enable_http: true
          enable_https: true
          password_strength_check: false
          redirect_to_https: true
          sslkeyandcertificate_refs:
            - "/api/sslkeyandcertificate?name=System-Default-Portal-Cert"
            - "/api/sslkeyandcertificate?name=System-Default-Portal-Cert-EC256"
          sslprofile_ref: "/api/sslprofile?name=System-Standard-Portal"
          use_uuid_from_input: false
        welcome_workflow_complete: true
        controller: "{{ controller }}"
        username: "{{ username }}"
        password: "{{ password }}"
        state: present
        api_version: "{{ controller_version }}"
    - name: Configure Cloud
      avi_cloud:
        controller: "{{ controller }}"
        username: "{{ username }}"
        password: "{{ password }}"
        state: present
        name: "{{ cloud_name }}"
        api_version: "{{ controller_version }}"
        vtype: CLOUD_GCP
        dhcp_enabled: true
        license_type: "LIC_CORES"
        azure_configuration:
          subscription_id: "{{ subscription_id }}"
          location: "{{ region }}"
          network_info:
            - virtual_network_id: "{{ se_vnet_id_path }}" 
              se_network_id: "{{ se_mgmt_subnet_name }}"
          resource_group: "{{ se_resource_group }}"
          use_azure_dns: "{{ use_azure_dns }}"
          use_enhanced_ha: false
          use_managed_disks: true
          use_standard_alb: false
          dhcp_enabled: true
          
    - name: Configure SE-Group
      avi_serviceenginegroup:
        name: "Default-Group" 
        controller: "{{ controller }}"
        username: "{{ username }}"
        password: "{{ password }}"
        state: present
        api_version: "{{ controller_version }}"
        cloud_ref: "/api/cloud?name={{ cloud_name }}"
        max_se: "10"
        se_name_prefix: "{{ se_name_prefix }}"
        buffer_se: "1"
        instance_flavor: "{{ instance_flavor }}"
        realtime_se_metrics:
          duration: "10080"
          enabled: true
    
    - name: Set Backup Passphrase
      avi_backupconfiguration:
        controller: "{{ controller }}"
        username: "{{ username }}"
        password: "{{ password }}"
        state: present
        api_version: "{{ controller_version }}"
        name: Backup-Configuration
        backup_passphrase: "{{ password }}"
        upload_to_remote_host: false
%{ if controller_ha }
    - name: Controller Cluster Configuration
      avi_cluster:
        controller: "{{ controller }}"
        username: "{{ username }}"
        password: "{{ password }}"
        state: present
        api_version: "{{ controller_version }}"
        #virtual_ip:
        #  type: V4
        #  addr: "{{ controller_cluster_vip }}"
        nodes:
            - name: "{{ controller_name_1 }}" 
              password: "{{ password }}"
              ip:
                type: V4
                addr: "{{ controller_ip_1 }}"
            - name: "{{ controller_name_2 }}"
              password: "{{ password }}"
              ip:
                type: V4
                addr: "{{ controller_ip_2 }}"
            - name: "{{ controller_name_3 }}"
              password: "{{ password }}"
              ip:
                type: V4
                addr: "{{ controller_ip_3 }}"
        name: "cluster01"
        tenant_uuid: "admin"
%{ endif }

