function Invoke-Ignorer {
	[CmdletBinding()]
	Param()

	# Add Member Defition for LogonUser
	$api = Add-Type -Name Ignore -MemberDefinition @"
		[DllImport("advapi32.dll", SetLastError = true)] 
		public static extern bool LogonUser(string lpszUsername, string lpszDomain, string lpszPassword, int dwLogonType, int dwLogonProvider, ref IntPtr phToken);
"@ -passthru

	# Get Credentals. Use \DOMAIN\User for username
	$creds = Get-Credential
	$user = $($creds.GetNetworkCredential().UserName)
	$password = $($creds.GetNetworkCredential().Password)
	$domain = $($creds.GetNetworkCredential().Domain)
	$plain = "$($user):$($password)"

	# Impersonate the new user
	[IntPtr]$token = [Security.Principal.WindowsIdentity]::GetCurrent().Token
	$api::LogonUser($user, $domain, $password, 9, 0, [ref]$token) | Out-Null
	$identity = New-Object Security.Principal.WindowsIdentity $token
	$context = $Identity.Impersonate()

	
	while($True) {
		try {
			Write-Verbose "Mapping Drive"
			New-PSDrive -name X -PSProvider FileSystem -root \\$($domain)\C$ -Credential $creds -ErrorAction Ignore -ErrorVariable $err
			
			Write-Verbose "Requesting http://$($domain).local with Basic Auth"
			$headers = @{
				Authorization = "Basic " + [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($plain))
			}

			Invoke-WebRequest "http://$($domain).local" -Headers $headers
		}
		catch {
			
		}
				
		Start-Sleep -s 5
	}
	
}
