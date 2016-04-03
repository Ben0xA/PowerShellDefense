function Invoke-Ignorer {
	Param()

	$creds = Get-Credential


	while($True) {
		try {
			New-PSDrive -name X -PSProvider FileSystem -root \\FAKEDOMAIN\C$ -Credential $creds -ErrorAction Ignore -ErrorVariable $err
			Invoke-WebRequest fakedomain.local -Credential $creds -ErrorAction Ignore -ErrorVariable $err

			$headers = @{
				Authorization = "Basic " + [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("dave:ILoveBen!"))
			}

			Invoke-WebRequest fakedomain.local -Credential $creds -Headers $headers -ErrorAction Ignore -ErrorVariable $err	
		}
		catch {
			
		}
				
		Start-Sleep -s 5
	}
	
}