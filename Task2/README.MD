# Internal web dashboard (hosted on internal.example.com) is suddenly unreachable from multiple systems

users are experiencing `host not found` issue

## Steps

1. Compare the resolution from /etc/resolv.conf DNS vs. 8.8.8.8.

   ```bash
   dig internal.example.com
   ```

   and

   ```bash
   dig @8.8.8.8 internal.example.com
   ```

   ### Findings

   1. if both return the same IP address, DNS resolution is functioning properly
   2. if they differ, possible causes

      1. curl the server with its IP and put the host `field: internal.example.com`, if it is working properly, it is a DNS issue.
      2. Maybe etc/resolv.conf is not configured properly
      3. Local DNS override (/etc/hosts)
         ```
         grep "internal.example.com" /etc/hosts
         ```
         and the check the IP
      4. Local DNS cache poisoning, we should flush the cash.

         common linux distros

         ```
         sudo systemd-resolve --flush-caches
         sudo systemctl restart systemd-resolved
         ```

         MACOS

         ```
         sudo dscacheutil -flushcache
         sudo killall -HUP mDNSResponder
         ```

2. Diagnose Service Reachability:

   1. Test Network Connectivity
      First, check if the server is reachable at the network level:

      ```
      ping <resolved-ip-address>
      ```

      If ping is successful, the server is reachable at the network layer.
      If ping fails, possible network misconfiguration or firewall blocks ICMP.

   2. Test Port Connectivity
      use `telnet` or `nc` to check if web services are open:

      ```
      telnet <resolved-ip-address> 80
      telnet <resolved-ip-address> 443
      ```

      netcat

      ```
      nc -zv <resolved-ip-address> 80
      nc -zv <resolved-ip-address> 443
      ```

      If connection succeeds, the service is listening and responding.
      If connection fails, the port might be blocked, service down, or firewall blocking.

   3. Verify Local Listening (If You Have Server Access)
      If we can log into the server, check whether the web service (e.g., nginx, apache) is listening on the expected ports:

      using `ss` or `netstat`

      ```
      sudo netstat -tulnp | grep -E ':80|:443'
      ```

      or

      ```
      sudo ss  -tulnp | grep -E ':80|:443'
      ```

      Confirm there is a process actively listening on port 80 and/or 443.

      If the service is behind a firewall, I would:
      Report to the security team or open the necessary ports using ufw or iptables if applicable:

      ```
      sudo ufw allow 80/tcp
      sudo ufw allow 443/tcp
      ```

   4. Check Service Logs
      If you have access to the server, inspect the web service logs to find internal errors:
      apache

      ```
      sudo tail -n 50 /var/log/apache2/error.log
      ```

      nginx

      ```
      sudo tail -n 50 /var/log/nginx/error.log
      ```

      system-managed

      ```bash
      sudo journalctl -u nginx
      sudo journalctl -u apache2
      ```

      Maybe it is
      Service crashes, Misconfiguration errors or Resource exhaustion (CPU throttling, out of memory, disk full).

   5. Check for Abnormal Process Behaviour
      If service logs hint at instability or resource problems, inspect the running process:
      Trace system calls:

      ```bash
          sudo strace -p <pid>
      ```

      Watch for infinite system calls (e.g., open, write loops).

      List open files:

      ```bash
      sudo lsof -p <pid>
      ```

      Detect heavy or infinite file writes.
      Monitor resource usage:

      ```bash
      top
      htop
      ```

      If you observe infinite writing, massive CPU spikes, or abnormal behaviour:

      ```bash
      sudo kill -9 <pid>
      ```

      Then I'll report immediately to the developer with your findings.
      or fix it myself if it’s a simple and authorised change (e.g., remove bad file, fix config).

   6. Diagnose and Report
      if no local issues are found and the service is still unreachable:
      Possible causes:
      Network misconfiguration
      Firewall blocks
      Security policies

      I will prepare a detailed report:
      Resolved IP
      Ping result
      Port connectivity results
      Service listening status
      Logs summary
      Runtime findings (strace/lsof output)
      Steps you took

      Escalate to:
      Network team
      Security team
      Development team (if application bug)

## Bonus

## **Configure a Local /etc/hosts Entry**

1. vim into /etc/hosts to directly map internal.example.com to the resolved IP address, bypassing DNS.

   ```
   sudo vim /etc/hosts
   # Add the following entry:
   resolved_ip_address internal.example.com
   ```

   Now your system will bypass DNS resolution and directly use the IP address from /etc/hosts.

2. Persist DNS Settings: For systemd-resolved:

   ```
   sudo nano /etc/systemd/resolved.conf
   ```

   ```
   # Set DNS server:
   DNS=8.8.8.8
   FallbackDNS=8.8.4.4
   ```

   ```
   sudo systemctl restart systemd-resolved
   ```
