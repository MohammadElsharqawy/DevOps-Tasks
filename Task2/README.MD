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

Since it is a private (internal) service, it should be hosted on internal DNS, however Google DNS is a public DNS, though it is technically feasible.

### Findings

1.  if both return the same IP address, DNS resolution is functioning properly
2.  if they differ, we need to confirm that the DNS is the problem, so we will
        curl the server with its IP and put the `host field: internal.example.com`, if it is working properly, it is a DNS issue.
    possible causes   
       1. Maybe etc/resolv.conf is not configured properly
       2. Local DNS override (/etc/hosts)
          ```
          grep "internal.example.com" /etc/hosts
          ```
          and the check the IP
       3. Local DNS cache update issue, we should flush the cash.
   
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

3.  Diagnose Service Reachability:

    1.  Test Network Connectivity
        First, check if the server is reachable at the network level:

        ```
        traceroute <resolved-ip-address>
        ```

        If traceroute reached the destination, it is not a network issue.
        If traceroute fails, Report to the netwoek team

    2. Check if the machine (server) is up

        ```
        ping <server-ip-or-hostname> 
        ```
        If ping fails, the machine need to be up.  

    3.  Test Port Connectivity
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

        If connection succeeds, the post is open.
        If connection fails, the port might be firewall blocking check the Security team.
       
         
    5. Check is the service is up, assuming the service is nginx

       ```
       systemctl status nginx  
       ```  
       if it is not running, start it.  
       
    6.  Verify Local Listening (If You Have Server Access)
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


    7.  Check Service Logs
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
    5. If logs indicate any abnormal behavior, Report to the Development team, if not 
        Maybe it is Service crashes, Misconfiguration errors or Resource exhaustion (CPU throttling, out of memory, disk full).

    6.  Check for Abnormal Process Behaviour
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

        Then I'll report immediately to the developer with my findings.
        or fix it myself if it’s a simple and authorised change (e.g., remove bad file, fix config).

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
