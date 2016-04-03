function Find-MaliciousAccount {
	Param(
        [String]$AccountName
    )

	while($True) {
		$starttime = $(Get-Date).ToString("MM/dd/yyyy hh:mm tt")

		Start-Sleep 5
		$events = Get-EventLog -LogName Security -InstanceId 4648 -After $starttime | Where-Object { $_.Message -Like "*Account Name:*$($AccountName)*" }

		$events | ForEach-Object { 
			$_.Message -match "Account Name:(?<content>.*)$($AccountName)" | Out-Null
            $PSAlert.Add("Malcousiusous Account Detected", 0)
			New-Object -Type PSObject -Property @{
				Time = $_.TimeGenerated.ToString()
				Account = $Matches[0]
			}
		}
	}
}