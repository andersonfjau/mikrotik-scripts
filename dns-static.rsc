#Based on TitonBarua script found here: https://www.titonbarua.com/posts/2019-05-23-mikrotik-resolve-local-dhcp-hosts-using-dnc
#Create a global variable lanDomain, for erase entry's at reboot in another script...
:global lanDomain;
#Create a local variable to join hostname with suffix domain name
:local lanHostname;
#This one was a trick! The lease-options are a global array with many values, the second one is named as "15" and has the suffix domain name configured on dhcp server. :)
:set lanDomain (:put $"lease-options"->"15");
#Create some local variables to remove existing DNS entry
:local tHostname;
:local tAddress;

:if ($leaseBound = 1) do={
#Check if the hostname is empty. If it is, skipping erase or add a static entry on DNS...
    :if ($"lease-hostname" = "") do={
    :log info "DNS Static: Empty hostname for $leaseActIP. Ignoring static DNS entry..."
    } else={
#Make the full hostname to search on DNS entry's
        :set lanHostname ($"lease-hostname" . "." . $lanDomain);
#Searching if exists a entry for this hostname. If exists, it will remove it...
        /ip dns static;
        :foreach k,v in=[find] do={
            :set tHostname [get $v "name"];
            :set tAddress [get $v "address"];
            :if ($tHostname = $lanHostname) do={
                remove $v ;
                :log info "DNS Static: Removed old static DNS entry: $tHostname to $tAddress" ;
            };
        };
#Now add the new static entry on DNS...
        /ip dns static add name="$lanHostname" address="$leaseActIP" ;
        :log info "DNS Static: Added new static DNS entry: $lanHostname to $leaseActIP" ;
    };
};
