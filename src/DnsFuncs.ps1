
#With thanks to Script Guy : http://blogs.technet.com/b/heyscriptingguy/archive/2009/02/26/how-do-i-query-and-retrieve-dns-information.aspx
Function Get-DnsEntry($iphost)
{
 If($ipHost -match "^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$")
  {
    [System.Net.Dns]::GetHostEntry($iphost).HostName
  }
 ElseIf( $ipHost -match "^.*\.\.*")
   {
    [System.Net.Dns]::GetHostEntry($iphost).AddressList[0].IPAddressToString
   } 
 ELSE { Throw "Specify either an IP V4 address or a hostname" }
} #end Get-DnsEntry
